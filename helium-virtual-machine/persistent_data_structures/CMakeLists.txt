cmake_minimum_required(VERSION 3.8)

set(This PersistentDataStructures)

set(Headers
  list.h
)

set(Sources
  list.cc
)

add_library(${This} STATIC ${Sources} ${Headers})

add_subdirectory(test)

#target_include_directories (${This} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})