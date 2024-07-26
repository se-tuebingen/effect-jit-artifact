cmake_minimum_required(VERSION 3.8)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

set(This HeliumVirtualMachineLib)

project(${This} CXX)

set(CMAKE_CXX_STANDARD 20)

enable_testing()

add_subdirectory(googletest)
add_subdirectory(persistent_data_structures)

set(Headers
  value.h
  instruction_set.h
  machine.h
  parse.h
  pretty_print.h
  extern_call.h
)

set(Sources
  value.cc
  machine.cc
  parse.cc
  pretty_print.cc
  extern_call.cc
)

add_library(${This} STATIC ${Sources} ${Headers})
target_link_libraries(${This} PUBLIC
  PersistentDataStructures
)

add_subdirectory(test)

add_executable(HeliumVirtualMachine main.cc)
target_link_libraries(HeliumVirtualMachine PUBLIC
  ${This}
)