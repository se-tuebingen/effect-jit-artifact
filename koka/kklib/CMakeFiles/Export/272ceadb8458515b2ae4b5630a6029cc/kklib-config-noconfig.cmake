#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "kklib" for configuration ""
set_property(TARGET kklib APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(kklib PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "C"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib64/libkklib.a"
  )

list(APPEND _cmake_import_check_targets kklib )
list(APPEND _cmake_import_check_files_for_kklib "${_IMPORT_PREFIX}/lib64/libkklib.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
