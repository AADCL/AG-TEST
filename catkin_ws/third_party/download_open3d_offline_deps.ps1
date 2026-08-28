$ErrorActionPreference = "Stop"

$cacheRoot = Join-Path $PSScriptRoot "offline-aarch64\open3d-3rdparty"

$archives = @(
    @{ Dir = "assimp"; Name = "v5.0.1.tar.gz"; Url = "https://github.com/assimp/assimp/archive/refs/tags/v5.0.1.tar.gz" },
    @{ Dir = "nanoflann"; Name = "v1.3.2.tar.gz"; Url = "https://github.com/jlblancoc/nanoflann/archive/refs/tags/v1.3.2.tar.gz" },
    @{ Dir = "jsoncpp"; Name = "1.9.4.tar.gz"; Url = "https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.4.tar.gz" },
    @{ Dir = "tinygltf"; Name = "72f4a55edd54742bca1a71ade8ac70afca1d3f07.tar.gz"; Url = "https://github.com/syoyo/tinygltf/archive/72f4a55edd54742bca1a71ade8ac70afca1d3f07.tar.gz" },
    @{ Dir = "tinyobjloader"; Name = "v2.0.0rc8.tar.gz"; Url = "https://github.com/tinyobjloader/tinyobjloader/archive/refs/tags/v2.0.0rc8.tar.gz" },
    @{ Dir = "fmt"; Name = "6.0.0.tar.gz"; Url = "https://github.com/fmtlib/fmt/archive/refs/tags/6.0.0.tar.gz" },
    @{ Dir = "poisson"; Name = "fd273ea8c77a36973d6565a495c9969ccfb12d3b.tar.gz"; Url = "https://github.com/isl-org/Open3D-PoissonRecon/archive/fd273ea8c77a36973d6565a495c9969ccfb12d3b.tar.gz" },
    @{ Dir = "zeromq"; Name = "zeromq-4.3.3.tar.gz"; Url = "https://codeload.github.com/zeromq/libzmq/tar.gz/refs/tags/v4.3.3" },
    @{ Dir = "cppzmq"; Name = "v4.7.1.tar.gz"; Url = "https://github.com/zeromq/cppzmq/archive/v4.7.1.tar.gz" },
    @{ Dir = "msgpack-c"; Name = "msgpack-3.3.0.tar.gz"; Url = "https://codeload.github.com/msgpack/msgpack-c/tar.gz/refs/tags/cpp-3.3.0" },
    @{ Dir = "tbb"; Name = "141b0e310e1fb552bdca887542c9c1a8544d6503.tar.gz"; Url = "https://github.com/wjakob/tbb/archive/141b0e310e1fb552bdca887542c9c1a8544d6503.tar.gz" },
    @{ Dir = "parallelstl"; Name = "20190522.tar.gz"; Url = "https://github.com/oneapi-src/oneDPL/archive/refs/tags/20190522.tar.gz" },
    @{ Dir = "embree"; Name = "v3.13.0.tar.gz"; Url = "https://github.com/embree/embree/archive/refs/tags/v3.13.0.tar.gz" }
)

foreach ($archive in $archives) {
    $dir = Join-Path $cacheRoot $archive.Dir
    New-Item -ItemType Directory -Force $dir | Out-Null
    $output = Join-Path $dir $archive.Name
    if ((Test-Path $output) -and (Get-Item $output).Length -gt 0) {
        if (-not $archive.Sha256 -or (Get-FileHash -Algorithm SHA256 -LiteralPath $output).Hash.ToLowerInvariant() -eq $archive.Sha256) {
            Write-Host "Already present: $output"
            continue
        }
        Remove-Item -LiteralPath $output
    }
    Write-Host "Downloading $($archive.Url)"
    & curl.exe -L --fail --retry 3 --output $output $archive.Url
    if ($LASTEXITCODE -ne 0) {
        throw "Download failed: $($archive.Url)"
    }
    if ($archive.Sha256 -and (Get-FileHash -Algorithm SHA256 -LiteralPath $output).Hash.ToLowerInvariant() -ne $archive.Sha256) {
        throw "Checksum mismatch: $output"
    }
}

$eigenPackage = Join-Path $PSScriptRoot "offline-aarch64\libeigen3-dev_3.4.0-2ubuntu2_all.deb"
$eigenUrl = "https://archive.ubuntu.com/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.4.0-2ubuntu2_all.deb"
$eigenSha256 = "04ee3759712a0f003fb186edf83724947826d7a43f3ef8d858cd359ca38a25ef"
if (-not (Test-Path -LiteralPath $eigenPackage) -or
    (Get-FileHash -Algorithm SHA256 -LiteralPath $eigenPackage).Hash.ToLowerInvariant() -ne $eigenSha256) {
    & curl.exe -L --fail --retry 3 --output $eigenPackage $eigenUrl
    if ($LASTEXITCODE -ne 0) {
        throw "Download failed: $eigenUrl"
    }
}
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $eigenPackage).Hash.ToLowerInvariant() -ne $eigenSha256) {
    throw "Checksum mismatch: $eigenPackage"
}
