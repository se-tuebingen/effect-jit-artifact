cmake_minimum_required(VERSION 3.8)

set(This HeliumVirtualMachineTest)

set(Sources
  machine_test.cc
  parse_test.cc
)

add_executable(${This} ${Sources})

target_link_libraries(${This} PUBLIC
  gtest_main
  HeliumVirtualMachineLib
)

add_test(
  NAME MachineTest
  COMMAND ${This}
)