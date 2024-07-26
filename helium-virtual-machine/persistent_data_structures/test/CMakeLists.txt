cmake_minimum_required(VERSION 3.8)

set(This PersistentDataStructuresTest)

set(Sources
  list_test.cc
)

add_executable(${This} ${Sources})

target_link_libraries(${This} PUBLIC
  gtest_main
  PersistentDataStructures
)

add_test(
  NAME ListTest
  COMMAND ${This}
)