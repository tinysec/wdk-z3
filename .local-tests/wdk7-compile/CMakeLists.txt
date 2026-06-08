cmake_minimum_required(VERSION 3.20)

project(wdk_z3_wdk7_compile LANGUAGES C CXX)

get_filename_component(WDK_Z3_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

set(Z3_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory("${WDK_Z3_ROOT}" "${CMAKE_BINARY_DIR}/z3")

add_executable(wdk7_z3_compile_c compile.c)
target_link_libraries(wdk7_z3_compile_c PRIVATE z3::z3)
if(NOT Z3_RUNTIME_DLL STREQUAL "")
    z3_copy_runtime(wdk7_z3_compile_c)
endif()

add_executable(wdk7_z3_compile_cpp compile.cpp)
target_link_libraries(wdk7_z3_compile_cpp PRIVATE z3::z3)
if(NOT Z3_RUNTIME_DLL STREQUAL "")
    z3_copy_runtime(wdk7_z3_compile_cpp)
endif()
