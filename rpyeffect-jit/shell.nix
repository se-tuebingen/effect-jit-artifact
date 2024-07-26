# First, define an overlay to fix some incompatibilities with current nixpkgs
# TODO: Cleanup and move some fixes to nixpkgs. For now, this works
let
  patchPypy = pypy: pypy.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ [
        ./nix-patches/find_library-gcc10_pypy.patch
      ];
    });
  pytest2 = ps: ps.buildPythonPackage rec {
    pname = "pytest";
    version = "2.9.2";

    src = ps.fetchPypi {
      inherit pname version;
      sha256 = "EsGKu5oJpbKALbp1x6LX1sjA8SWKvYJD52iEFdh60dg=";
    };

    propagatedBuildInputs = with ps; [ py ];

    doCheck = false;
  };
  overlay = final: prev: {
    pypy27 = prev.pypy27;
    pypy = final.pypy27;
    python27Packages.pytest = pytest2 final.python27Packages;
    pypyPackages.pytest = pytest2 final.pypy27Packages;
  };
  pkgs = import (builtins.fetchGit {
         name = "pkgs-release-21.05";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/release-21.05";
         rev = "1a7c2f41c3bf6d7fd443e2453e7b840cdc413375";
  }) { overlays = [overlay]; };
in
# Start of actual package
with pkgs;
let
  pygame2 = ps: ps.buildPythonPackage rec {
    pname = "pygame";
    version = "2.0.1";

    src = ps.fetchPypi {
      inherit pname version;
      sha256 = "8b1e7b63f47aafcdd8849933b206778747ef1802bd3d526aca45ed77141e4001";
    };

    patches = [
      # Patch pygame's dependency resolution to let it find build inputs
      (substituteAll {
        src = ./nix-patches/fix-dependency-finding.patch;
        buildinputs_include = builtins.toJSON (builtins.concatMap (dep: [
          "${lib.getDev dep}/"
          "${lib.getDev dep}/include"
        ]) buildInputs);
        buildinputs_lib = builtins.toJSON (builtins.concatMap (dep: [
          "${lib.getLib dep}/"
          "${lib.getLib dep}/lib"
        ]) buildInputs);
      })
    ];

    postPatch = ''
              substituteInPlace src_py/sysfont.py \
                --replace 'path="fc-list"' 'path="${fontconfig}/bin/fc-list"' \
                --replace /usr/X11/bin/fc-list ${fontconfig}/bin/fc-list
                '';

    nativeBuildInputs = [
      pkg-config SDL2
    ];

    buildInputs = [
      SDL2 SDL2_image SDL2_ttf libpng libjpeg
      xorg.libX11 freetype
    ] ++ (if stdenv.isDarwin 
      then with pkgs.darwin.apple_sdk.frameworks; [ Carbon AppKit ] 
      else [SDL2_mixer portmidi]);

    preConfigure = ''
     LOCALBASE=/ ${python.interpreter} buildconfig/config.py
    '';

    pythonImportsCheck = [ "pygame" ];
   };
  rply = ps: ps.buildPythonPackage rec {
    pname = "rply";
    version = "0.7.8";

    src = fetchFromGitHub {
      owner = "alex";
      repo = "rply";
      rev = "v${version}";
      sha256 = "0kn8vikyf95mr8l9g3324b7gk4cgxlvvy1abqpl1h803idqg1vwq";
    };

    doCheck = false;

    propagatedBuildInputs = [ ps.appdirs ];
  };
  pythonDeps = ps: (with ps; [
    simplejson
    pygments
    (pygame2 ps)
    setuptools
  ] ++ lib.optionals (!stdenv.isDarwin) [
    flask
    jinja2
  ]);
  # `withPackages` commented out bc it breaks patch and does not work anyway
  myPypy = patchPypy pypy; #.withPackages pythonDeps;
  myPython2 = python2.withPackages pythonDeps;
in
mkShell {
  nativeBuildInputs = [
    pkg-config
    libffi
    hyperfine
    graphviz
  ] ++ lib.optionals (!stdenv.isDarwin) [
    myPypy
  ] ++ lib.optionals (stdenv.isDarwin) [
    myPython2
  ];
  # Hack to make pypy find packages
  shellHook = ''
    export PYTHONPATH=".:./pypy:${myPython2.out}/${myPython2.sitePackages}"
  '';
}
