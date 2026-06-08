$ErrorActionPreference = "Stop"

$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $testDir "..\..")
$toolchain = (Join-Path $repoRoot "cmake\wdk7.cmake").Replace("\", "/")
$readObj = "C:\usr\local\llvm\bin\llvm-readobj.exe"

foreach ($arch in @("amd64", "i386")) {
    $buildDir = Join-Path $repoRoot ".local-tests\wdk7-compile-build-$arch"
    $runtimeDll = ""
    $runtimeCandidates = @(
        (Join-Path $repoRoot "..\_wdk_z3_package_staging\bin\$arch\libz3.dll"),
        (Join-Path $repoRoot "local-runtime\$arch\libz3.dll")
    )

    foreach ($candidate in $runtimeCandidates) {
        if (Test-Path $candidate) {
            $runtimeDll = (Resolve-Path $candidate).Path
            break
        }
    }

    $configureArgs = @(
        "-S", $testDir,
        "-B", $buildDir,
        "-G", "NMake Makefiles",
        "-DCMAKE_TOOLCHAIN_FILE=$toolchain",
        "-DWDK7_ARCH=$arch",
        "-DZ3_INSTALL=OFF"
    )
    if ($runtimeDll -ne "") {
        $configureArgs += "-DZ3_RUNTIME_DLL=$runtimeDll"
    }

    cmake @configureArgs

    cmake --build $buildDir

    foreach ($name in @("wdk7_z3_compile_c.exe", "wdk7_z3_compile_cpp.exe")) {
        $exe = Join-Path $buildDir $name
        if (Test-Path $readObj) {
            $imports = & $readObj --coff-imports $exe
            if (-not ($imports | Select-String -Pattern "Name: libz3.dll" -Quiet)) {
                throw "$name for $arch does not import libz3.dll."
            }
            if ($imports | Select-String -Pattern "Ordinal:" -Quiet) {
                throw "Unexpected ordinal import found in $name for $arch."
            }
        }

        if ($runtimeDll -ne "") {
            & $exe
            if ($LASTEXITCODE -ne 0) {
                throw "$name failed for $arch with exit code $LASTEXITCODE."
            }
        }
    }

    if ($runtimeDll -ne "") {
        Write-Host "WDK7 Z3 C API compile/link/runtime test passed for $arch."
    } else {
        Write-Host "WDK7 Z3 C API compile/link test passed for $arch. Runtime skipped; set Z3_RUNTIME_DLL or local-runtime\\$arch\\libz3.dll to run."
    }
}
