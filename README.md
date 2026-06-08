# wdk-z3

[![WDK](https://img.shields.io/badge/WDK-7.1-blue)](#)
[![Z3](https://img.shields.io/badge/Z3-4.16.0-informational)](#)
[![API](https://img.shields.io/badge/API-C-064f8c)](#cmake-usage)

## Introduction

`wdk-z3` is a standalone WDK 7 compatible header + import library package for
the Z3 4.16.0 C API. It is not a Z3 source tree and does not build Z3 with the
WDK 7 compiler.

Z3 4.16.0 itself is C++20, so the WDK 7 compiler cannot build the solver body.
This package instead provides WDK 7 friendly C headers and import libraries
built from the `z3-4.16.0` tag. Runtime `libz3.dll` files are intentionally not
stored in this source repository.

## Features

- C API headers only. `z3++.h` is intentionally not included.
- WDK 7 friendly `stdbool.h` and `stdint.h` compatibility headers.
- `amd64` and `i386` `z3.lib` import libraries.
- No bundled Z3 source code, generated source tree, submodules, or configure-time
  downloads.
- Installable CMake package with the `z3::z3` target.

The import libraries target the `libz3.dll` runtime name. Put the matching
runtime DLL next to your executable, in `PATH`, or pass it as
`-DZ3_RUNTIME_DLL=...` if you want CMake to copy it for a target.

## CMake Usage

Use `FetchContent`. Always pin `GIT_TAG`; package tags track upstream Z3
versions one-for-one.

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

`z3::z3` links the selected `lib/<arch>/z3.lib`. The selected architecture
follows `WDK7_ARCH` when present; otherwise set `-DZ3_ARCH=amd64` or
`-DZ3_ARCH=i386`.

If an external runtime DLL is available, CMake can copy it next to an
executable:

```cmake
set(Z3_RUNTIME_DLL "D:/path/to/libz3.dll" CACHE FILEPATH "")
target_link_libraries(your_target PRIVATE z3::z3)
z3_copy_runtime(your_target)
```

## Versioning

`wdk-z3` tags follow upstream Z3 tags with a `v` prefix. For example,
`wdk-z3` tag `v4.16.0` packages headers and import libraries built from
upstream Z3 tag `z3-4.16.0`.

## Official Binaries

The upstream Z3 GitHub release for 4.16.0 provides Windows prebuilt packages,
including `z3-4.16.0-x64-win.zip`. Upstream also notes that Windows binary
distributions include C++ runtime redistributables. Keep those DLLs as external
release/runtime artifacts, not as files committed to this source repository.
