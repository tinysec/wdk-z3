# wdk-z3

[![WDK](https://img.shields.io/badge/WDK-7.1-blue)](#)
[![Z3](https://img.shields.io/badge/Z3-4.16.0-informational)](#)
[![CMake](https://img.shields.io/badge/CMake-package-064f8c)](#usage)
[![API](https://img.shields.io/badge/API-C-064f8c)](#features)

## Introduction

`wdk-z3` is a WDK 7 compatible header and import-library package for the
Z3 C API. Repository tags follow upstream Z3 versions; for example, `v4.16.0`
packages Z3 `4.16.0`.

## Features

- WDK 7 friendly Z3 C API headers.
- `amd64` and `i386` `z3.lib` import libraries for `libz3.dll`.
- CMake package target: `z3::z3`.
- No bundled Z3 source tree.
- No runtime DLLs committed to git.

## Usage

Use `FetchContent` and always pin `GIT_TAG`:

```cmake
include(FetchContent)

FetchContent_Declare(
    z3
    GIT_REPOSITORY https://github.com/tinysec/wdk-z3.git
    GIT_TAG v4.16.0)
FetchContent_MakeAvailable(z3)

target_link_libraries(your_target PRIVATE z3::z3)
```

Use an installed package:

```cmake
find_package(z3 4.16 CONFIG REQUIRED)

target_link_libraries(your_target PRIVATE z3::z3)
```

The selected architecture follows `WDK7_ARCH`; otherwise pass
`-DZ3_ARCH=amd64` or `-DZ3_ARCH=i386`.

If CMake should copy an external runtime DLL next to an executable:

```cmake
set(Z3_RUNTIME_DLL "D:/path/to/libz3.dll" CACHE FILEPATH "")
target_link_libraries(your_target PRIVATE z3::z3)
z3_copy_runtime(your_target)
```
