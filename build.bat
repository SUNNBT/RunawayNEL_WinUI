@echo off
chcp 65001 >nul
echo ========================================
echo   RunawayNEL 编译脚本
echo ========================================
echo.

set PROJECT=EastSide.UI\Runaway.UI.csproj
set OUTPUT_DIR=publish

echo [1/4] 正在还原依赖...
dotnet restore %PROJECT%
if %errorlevel% neq 0 (
    echo 错误: 依赖还原失败
    pause
    exit /b 1
)

echo.
echo [2/4] 正在编译项目...
dotnet build %PROJECT% --configuration Release --no-restore
if %errorlevel% neq 0 (
    echo 错误: 编译失败
    pause
    exit /b 1
)

echo.
echo [3/4] 正在发布 (独立部署 win-x64)...
dotnet publish %PROJECT% -c Release -r win-x64 --self-contained true -o %OUTPUT_DIR%\win-x64 --no-restore -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if %errorlevel% neq 0 (
    echo 错误: 发布失败
    pause
    exit /b 1
)

echo.
echo [4/4] 正在发布 (框架依赖)...
dotnet publish %PROJECT% -c Release -o %OUTPUT_DIR%\fdd --no-restore
if %errorlevel% neq 0 (
    echo 错误: 发布失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo   编译完成!
echo   输出目录: %OUTPUT_DIR%\
echo   - win-x64: 独立部署单文件版
echo   - fdd: 框架依赖版
echo ========================================
pause
