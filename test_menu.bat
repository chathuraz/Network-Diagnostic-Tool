@echo off
echo Testing menu functionality...
echo.
echo 1. Option 1
echo 2. Option 2  
echo 3. Exit
echo.
set /p "choice=Select option (1-3): "

if "%choice%"=="1" (
    echo You selected option 1
    pause
    goto :eof
)
if "%choice%"=="2" (
    echo You selected option 2  
    pause
    goto :eof
)
if "%choice%"=="3" (
    echo Exiting...
    goto :eof
)

echo Invalid choice: %choice%
pause
