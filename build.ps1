# RunawayNEL 编译脚本
param(
    [string]$Runtime = "win-x64",
    [string]$Configuration = "Release",
    [string]$OutputDir = "publish",
    [switch]$SelfContained = $true,
    [switch]$SingleFile = $true
)

$ErrorActionPreference = "Stop"
$Project = "EastSide.UI\Runaway.UI.csproj"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RunawayNEL 编译脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 .NET SDK
Write-Host "[1/5] 检查 .NET SDK..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "  .NET 版本: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "错误: 未找到 .NET SDK，请先安装 .NET 9.0 SDK" -ForegroundColor Red
    exit 1
}

# 还原依赖
Write-Host ""
Write-Host "[2/5] 还原依赖..." -ForegroundColor Yellow
dotnet restore $Project
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 依赖还原失败" -ForegroundColor Red
    exit 1
}

# 编译
Write-Host ""
Write-Host "[3/5] 编译项目..." -ForegroundColor Yellow
dotnet build $Project --configuration $Configuration --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 编译失败" -ForegroundColor Red
    exit 1
}

# 发布
Write-Host ""
Write-Host "[4/5] 发布项目..." -ForegroundColor Yellow
$publishArgs = @(
    "publish", $Project,
    "-c", $Configuration,
    "-r", $Runtime,
    "--self-contained", $SelfContained.ToString().ToLower(),
    "-o", "$OutputDir\$Runtime",
    "--no-restore"
)

if ($SingleFile) {
    $publishArgs += @(
        "-p:PublishSingleFile=true",
        "-p:EnableCompressionInSingleFile=true",
        "-p:IncludeNativeLibrariesForSelfExtract=true"
    )
}

dotnet @publishArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 发布失败" -ForegroundColor Red
    exit 1
}

# 完成
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  编译完成!" -ForegroundColor Green
Write-Host "  输出目录: $OutputDir\$Runtime\" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
