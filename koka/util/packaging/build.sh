#!/bin/bash

SUPPORTED_TARGETS="rhel ubuntu arch alpine opensuse"
SUPPORTED_ARCHITECTURES="amd64" # arm64

#---------------------------------------------------------
# Variables
#---------------------------------------------------------

MODE=""
QUIET=""
BUILD_TARGETS=""
BUILD_ARCHITECTURES=""
REBUILD_CONTAINERS=""
AGRESSIVE_EXPORT=""

#---------------------------------------------------------
# Helper functions
#---------------------------------------------------------

LOG_PREFIX="[KOKA BUILDER] "
source "$(dirname "$0")/util.sh"

#---------------------------------------------------------
# Main
#---------------------------------------------------------

build_docker_images() {
  build_arch="$1"

  info "Building docker images for $build_arch"

  quiet_param=""
  if [ -n "$QUIET" ]; then
    quiet_param=$(docker_generate_quiet_flags build)
  fi

  # For each target
  for target in $BUILD_TARGETS; do
    info "Building docker image for $target"

    arch_opt=$(docker_generate_arch_flags build "$build_arch")
    selinux_opt=$(docker_generate_selinux_flags build)

    rebuild_opt=""
    if [ "$REBUILD_CONTAINERS" == "yes" ]; then
      rebuild_opt="--no-cache"
    fi

    # Build the docker image, subshell to help with buildkit
    (
      cd ./distros
      docker build $quiet_param -t localhost/koka-$target \
        $arch_opt $selinux_opt $rebuild_opt \
        -f "./$target.Dockerfile" .
    )

    if [ $? -ne 0 ]; then
      stop "Failed to build docker image for $target"
    fi
  done

  info "Docker images built successfully"
}

run_docker_images() {
  build_arch="$1"

  info "Compiling os specific packages for $build_arch"

  quiet_param=""
  if [ -n "$QUIET" ]; then
    quiet_param=$(docker_generate_quiet_flags run)
  fi

  arch_opt=$(docker_generate_arch_flags run "$build_arch")
  selinux_opt=$(docker_generate_selinux_flags run)

  # For each target
  for target in $BUILD_TARGETS; do
    info "Compiling $target"

    # Build the docker image
    # (Maybe properly fix SELINUX here?)
    docker run $quiet_param -it --rm $arch_opt \
      --privileged $selinux_opt \
      --tmpfs /tmp/overlay \
      -v "$(pwd)/$KOKA_SOURCE_LOCATION":/code:ro \
      -v "$TEMP_DIR:/output:z" \
      localhost/koka-$target

    if [ $? -ne 0 ]; then
      stop "Failed to compile os specific package for $target"
    fi

    if [ "$AGGRESSIVE_EXPORT" == "yes" ]; then
      move_outputs
    fi

    info "Compiled $target"
  done

  info "Compiled os specific packages successfully"
}

move_outputs() {
  info "Moving bundles to output dir"

  mkdir -p "$CALLER_DIR/bundle"
  # For each file in the temp dir
  for file in $TEMP_DIR/*; do
    file_bundle_version=$(tar -Oxf "$file" meta/version)
    if [ -z "$file_bundle_version" ]; then
      stop "Failed to extract version from bundle while moving"
    fi

    move_target_dir="$CALLER_DIR/bundle/$file_bundle_version"
    mkdir -p "$move_target_dir"
    mv "$file" "$move_target_dir"
  done

  if [ $? -ne 0 ]; then
    stop "Failed to move output"
  fi

  info "Bundles moved successfully"
}

package_outputs() {
  info "Packaging bundles"

  foundbundles="$CALLER_DIR/bundle/**/*.tar.gz"

  bundlecount=$(ls -1 $foundbundles | wc -l)
  if [ $bundlecount -gt 30 ]; then
    warn "You have a lot of bundles, $bundlecount in fact. To reduce packaging time please move old bundles somewhere else."
  fi

  for bundleloc in $foundbundles; do
    # Check if the bundle exists
    if [ ! -f $bundleloc ]; then
      stop "Bundle not found at $bundleloc"
    fi

    file_bundle_distro=$(tar -Oxf "$bundleloc" meta/distro 2>/dev/null || true)
    file_bundle_builddate=$(tar -Oxf "$bundleloc" meta/builddate 2>/dev/null || true)
    file_bundle_arch=$(tar -Oxf "$bundleloc" meta/arch 2>/dev/null || true)
    file_bundle_arch=$(normalize_osarch_docker "$file_bundle_arch")

    # Check build time, warn if missing or older than 2 weeks
    if [ -z "$file_bundle_builddate" ]; then
      warn "$bundleloc has incomplete metadata but enough to package"
      continue
    else
      file_bundle_builddate=$(date -d "$file_bundle_builddate" +%s)
      now=$(date +%s)
      diff=$((now - file_bundle_builddate))
      if [ $diff -gt 1209600 ]; then
        warn "$bundleloc is older than 2 weeks, consider moving or rebuilding it"
      fi
    fi

    # Skip if file bundle distro not in build targets
    if [ -z "$file_bundle_distro" ]; then
      warn "$bundleloc is probably a manual build, these are not supported"
      continue
    fi
    if [[ ! "$BUILD_TARGETS" =~ "$file_bundle_distro" ]]; then continue; fi
    # Skip if file bundle arch not in build archs
    if [ -z "$file_bundle_arch" ]; then
      warn "$bundleloc does not have expected metadata"
      continue
    fi
    if [[ ! "$BUILD_ARCHITECTURES" =~ "$file_bundle_arch" ]]; then continue; fi

    info "Packaging $bundleloc for $file_bundle_distro"
    ./package.sh --calldir="$CALLER_DIR" -t="$file_bundle_distro" $bundleloc

    if [ $? -ne 0 ]; then
      stop "Failed to package $bundleloc"
    fi
  done

  info "Bundles packaged successfully"
}

main_build() {
  info "Starting builds"
  switch_workdir_to_script
  verify_ran_from_reporoot

  if [ "$MODE" == "setupqemu" ]; then
    ensure_docker
    install_docker_multiarch # Force an install
  fi

  if [ "$MODE" == "build" ] || [ "$MODE" == "buildpackage" ]; then
    ensure_tar
    #ensure_kvm # Not necessary, virtualization is userspace
    ensure_docker
    ensure_docker_multiarch "$BUILD_ARCHITECTURES"

    for architecture in $BUILD_ARCHITECTURES; do
      build_docker_images $architecture
    done

    auto_temp_dir

    for architecture in $BUILD_ARCHITECTURES; do
      run_docker_images $architecture
    done

    # With aggressive export, all the files should already be moved
    if [ "$AGGRESSIVE_EXPORT" == "no" ]; then
      move_outputs
    fi
  fi

  # If mode is package or packageonly
  if [ "$MODE" == "buildpackage" ] || [ "$MODE" == "packageonly" ]; then
    package_outputs
  fi

  info "Builds finished successfully"
}

#---------------------------------------------------------
# Parse arguments
#---------------------------------------------------------

process_options() {
  while :; do
    flag="$1"
    case "$flag" in
    *=*) flag_arg="${flag#*=}" ;;
    *) flag_arg="yes" ;;
    esac
    # info "option: $flag, arg: $flag_arg"
    case "$flag" in
    "") break ;;
    -t=* | --targets=* | --target=*)
      BUILD_TARGETS=$(echo "$flag_arg" | tr "," "\n")
      ;;
    -a=* | --architectures=* | --architecture=*)
      BUILD_ARCHITECTURES=$(echo "$flag_arg" | tr "," "\n")
      ;;
    -p=* | --package=*)
      if [ "$flag_arg" == "yes" ]; then
        MODE="buildpackage"
      elif [ "$flag_arg" == "no" ]; then
        MODE="build"
      elif [ "$flag_arg" == "only" ]; then
        MODE="packageonly"
      else
        stop "Invalid package option: $flag_arg"
      fi
      ;;
    -b | --rebuild)
      REBUILD_CONTAINERS="yes"
      ;;
    -x | --aggressive-export)
      AGGRESSIVE_EXPORT="yes"
      ;;
    --configqemu)
      MODE="setupqemu"
      ;;
    --en-arm)
      SUPPORTED_ARCHITECTURES="$SUPPORTED_ARCHITECTURES arm64"
      ;;
    -q | --quiet)
      QUIET="yes"
      ;;
    -h | --help | -\? | help | \?)
      MODE="help"
      ;;
    *) case "$flag" in
      -*) warn "warning: unknown option \"$1\"." ;;
      *) BUNDLE_LOCATION="$1" ;;
      esac ;;
    esac
    shift
  done

  if [ "$MODE" == "help" ]; then return; fi

  # Default mode is package
  if [ -z "$MODE" ]; then MODE="buildpackage"; fi
  # Default rebuild is no
  if [ -z "$REBUILD_CONTAINERS" ]; then REBUILD_CONTAINERS="no"; fi
  # Default aggressive export is no
  if [ -z "$AGGRESSIVE_EXPORT" ]; then AGGRESSIVE_EXPORT="no"; fi
  # Default targets is all
  if [ -z "$BUILD_TARGETS" ]; then BUILD_TARGETS="$SUPPORTED_TARGETS"; fi

  # Check if BUILD_TARGETS is in SUPPORTED_TARGETS
  for target in $BUILD_TARGETS; do
    if [ -z "$(echo $SUPPORTED_TARGETS | grep $target)" ]; then
      stop "Invalid target: $target"
    fi
  done

  # Default architectures is all
  if [ -z "$BUILD_ARCHITECTURES" ]; then BUILD_ARCHITECTURES="$SUPPORTED_ARCHITECTURES"; fi

  # map build_archtectures with the normalize_osarch_docker() funciton
  tempvar="$BUILD_ARCHITECTURES"
  BUILD_ARCHITECTURES=""
  for build_arch in $tempvar; do
    BUILD_ARCHITECTURES="$BUILD_ARCHITECTURES $(normalize_osarch_docker $build_arch)"
  done

  # Check if BUILD_ARCHITECTURES is in SUPPORTED_ARCHITECTURES
  for arch in $BUILD_ARCHITECTURES; do
    if [ -z "$(echo $SUPPORTED_ARCHITECTURES | grep $arch)" ]; then
      stop "Invalid architecture: $arch"
    fi
  done

  ### Warnings

  # If arm64 is enabled
  if [[ "$BUILD_ARCHITECTURES" =~ "arm64" ]]; then
    warn "ARM64 is not yet supported, it will probably fail!"
  fi
}

main_help() {
  info "command:"
  info "  ./build.sh [options] <bundle file>"
  info ""
  info "options:"
  info "  -t, --targets=<target,target>   Specify the targets to build for"
  info "                                  ($SUPPORTED_TARGETS)"
  info "  -a, --architectures=<arch,arch> Specify the architectures to build for"
  info "                                  ($SUPPORTED_ARCHITECTURES)"
  info "  -p, --package=<yes|no|only>     Package the bundle after building"
  info "  -b, --rebuild                   Rebuild the container images"
  info "  -x, --aggressive-export         Export the bundle immidiately after building"
  info "  -q, --quiet                     Suppress output"
  info "  -h, --help                      Show this help message"
  info ""
  info "dev options:"
  info "  --configqemu                    Configure just the qemu docker emulator for other architectures"
  info "  --en-arm                        Enable ARM64 building"
  info ""
  info "important:"
  info "  All docker containers run with full root privileges right now"
  info "  This is because docker/linux refuses to properly implement scoped privileges"
  info "notes:"
  info "  This script can only build linux packages right now"
  info "  If older archives are present, they may be accidentally repackaged"
}

main_start() {
  # Make sure we ignore case in string comparisons
  shopt -s nocasematch

  process_options $@
  if [ "$MODE" = "help" ]; then
    main_help
  else
    main_build
  fi
}

main_start "$@"
