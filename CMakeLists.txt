cmake_minimum_required(VERSION 3.20)

project(z3 VERSION 4.16.0 LANGUAGES NONE)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(_z3_is_top_level TRUE)
else()
    set(_z3_is_top_level FALSE)
endif()

if(NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
    set(CMAKE_INSTALL_INCLUDEDIR "include" CACHE PATH "Header install directory")
endif()
if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR "lib" CACHE PATH "Library install directory")
endif()

include(GNUInstallDirs)

option(Z3_INSTALL "Install the wdk-z3 CMake package" "${_z3_is_top_level}")
set(Z3_ARCH "" CACHE STRING "Z3 binary arch override (amd64|i386); empty follows WDK7_ARCH or pointer size")
set_property(CACHE Z3_ARCH PROPERTY STRINGS "" amd64 i386)
set(Z3_RUNTIME_DLL "" CACHE FILEPATH "Optional external libz3.dll path used by z3_copy_runtime()")

function(_z3_normalize_arch out_var input_arch)
    if(input_arch STREQUAL "x64")
        set(_arch "amd64")
    elseif(input_arch STREQUAL "x86" OR input_arch STREQUAL "Win32")
        set(_arch "i386")
    else()
        set(_arch "${input_arch}")
    endif()

    if(NOT (_arch STREQUAL "amd64" OR _arch STREQUAL "i386"))
        message(FATAL_ERROR "Unsupported Z3 arch '${input_arch}'. Use amd64 or i386.")
    endif()

    set("${out_var}" "${_arch}" PARENT_SCOPE)
endfunction()

function(_z3_select_arch out_var)
    if(NOT Z3_ARCH STREQUAL "")
        set(_arch "${Z3_ARCH}")
    elseif(DEFINED WDK7_ARCH AND NOT WDK7_ARCH STREQUAL "")
        set(_arch "${WDK7_ARCH}")
    elseif(DEFINED CMAKE_SIZEOF_VOID_P AND CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(_arch "i386")
    else()
        set(_arch "amd64")
    endif()

    _z3_normalize_arch(_normalized_arch "${_arch}")
    set("${out_var}" "${_normalized_arch}" PARENT_SCOPE)
endfunction()

_z3_select_arch(Z3_BINARY_ARCH)

set(Z3_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(Z3_LIBRARY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/${Z3_BINARY_ARCH}")
set(Z3_IMPORT_LIBRARY "${Z3_LIBRARY_DIR}/z3.lib")

if(NOT EXISTS "${Z3_IMPORT_LIBRARY}")
    message(FATAL_ERROR "Missing Z3 import library: ${Z3_IMPORT_LIBRARY}")
endif()
if(NOT Z3_RUNTIME_DLL STREQUAL "" AND NOT EXISTS "${Z3_RUNTIME_DLL}")
    message(FATAL_ERROR "Z3_RUNTIME_DLL does not exist: ${Z3_RUNTIME_DLL}")
endif()

if(NOT TARGET z3::z3)
    add_library(z3::z3 UNKNOWN IMPORTED GLOBAL)
    set_target_properties(z3::z3 PROPERTIES
        IMPORTED_LOCATION "${Z3_IMPORT_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Z3_INCLUDE_DIR}")
    if(NOT Z3_RUNTIME_DLL STREQUAL "")
        set_target_properties(z3::z3 PROPERTIES
            Z3_RUNTIME_DLL "${Z3_RUNTIME_DLL}")
    endif()
endif()

function(z3_copy_runtime target_name)
    if(NOT TARGET "${target_name}")
        message(FATAL_ERROR "z3_copy_runtime target does not exist: ${target_name}")
    endif()

    get_target_property(_z3_runtime_dll z3::z3 Z3_RUNTIME_DLL)
    if(NOT _z3_runtime_dll)
        message(FATAL_ERROR "Set -DZ3_RUNTIME_DLL=/path/to/libz3.dll before calling z3_copy_runtime().")
    endif()

    add_custom_command(
        TARGET "${target_name}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${_z3_runtime_dll}"
            "$<TARGET_FILE_DIR:${target_name}>/libz3.dll")
endfunction()

if(Z3_INSTALL)
    install(
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

    install(
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib/"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        FILES_MATCHING
            PATTERN "*.lib")

    include(CMakePackageConfigHelpers)

    write_basic_package_version_file(
        "${PROJECT_BINARY_DIR}/z3ConfigVersion.cmake"
        VERSION "${PROJECT_VERSION}"
        COMPATIBILITY SameMajorVersion)

    configure_package_config_file(
        "${PROJECT_SOURCE_DIR}/cmake/Config.cmake.in"
        "${PROJECT_BINARY_DIR}/z3Config.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/z3")

    install(
        FILES
            "${PROJECT_BINARY_DIR}/z3Config.cmake"
            "${PROJECT_BINARY_DIR}/z3ConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/z3")
endif()
