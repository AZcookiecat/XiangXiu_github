@echo off

:: 设置数据库连接信息
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=xiangxiu_culture

:: 获取当前脚本所在目录
set "SCRIPT_DIR=%~dp0"

:: 显示当前操作
echo ==============================================
echo 湘绣文化项目数据库导入脚本
echo ==============================================
echo 脚本路径: %SCRIPT_DIR%
echo ==============================================

:: 连接MySQL并创建数据库
echo 正在连接MySQL并创建数据库...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if %errorlevel% neq 0 (
echo 错误: 连接MySQL失败，请检查数据库服务是否运行以及连接信息是否正确
echo 按任意键退出...
pause > nul
exit /b 1
)

echo 数据库创建成功！

:: 查找并导入所有SQL文件
echo 正在查找SQL文件...
set "SQL_COUNT=0"
set "SUCCESS_COUNT=0"
set "FAILED_COUNT=0"

echo ==============================================
echo 开始导入SQL文件...
echo ==============================================

for %%f in ("%SCRIPT_DIR%\*.sql") do (
    set /a SQL_COUNT+=1
    echo 正在导入: %%~nxf
    
    mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < "%%f"
    
    if %errorlevel% equ 0 (
        set /a SUCCESS_COUNT+=1
        echo 成功导入: %%~nxf
    ) else (
        set /a FAILED_COUNT+=1
        echo 错误: 导入 %%~nxf 失败
    )
    
echo ----------------------------------------------
)

:: 检查是否有SQL文件
if %SQL_COUNT% equ 0 (
echo 错误: 未找到SQL文件，请确保SQL文件在脚本所在目录
echo 按任意键退出...
pause > nul
exit /b 1
)

:: 显示导入结果
echo ==============================================
echo 导入完成！
echo 总SQL文件数: %SQL_COUNT%
echo 成功导入: %SUCCESS_COUNT%
echo 失败导入: %FAILED_COUNT%
echo ==============================================

if %FAILED_COUNT% equ 0 (
echo 所有SQL文件导入成功！
echo 湘绣文化项目数据库已成功搭建。
) else (
echo 部分SQL文件导入失败，请检查错误信息。
)

echo ==============================================
echo 操作完成！
echo 按任意键退出...
pause > nul
exit /b 0
