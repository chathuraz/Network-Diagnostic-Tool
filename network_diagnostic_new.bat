@echo off
setlocal enabledelayedexpansion

REM ===============================================
REM           INITIAL SETUP & CONFIG
REM ===============================================

REM Enable ANSI colors in modern Windows terminals
reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f >nul 2>&1

REM Get ESC character for ANSI codes
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

REM Color definitions
set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"

REM Configuration
set "TARGETS_FILE=targets.txt"
set "PING_ON=false"
set "TRACERT_ON=false"
set "DNS_ON=false"
set "PORT_ON=false"

REM ===============================================
REM               MAIN MENU
REM ===============================================
:main_menu
cls
echo.
echo %BOLD%%CYAN%==================================================%RESET%
echo %BOLD%%CYAN%           NETWORK DIAGNOSTIC TOOL v2.0          %RESET%
echo %BOLD%%CYAN%==================================================%RESET%
echo.
echo %YELLOW%Available Tests (Toggle ON/OFF):%RESET%
if "%PING_ON%"=="true" (echo %GREEN%  1. Ping Test                     [ENABLED]%RESET%) else (echo %WHITE%  1. Ping Test                     [DISABLED]%RESET%)
if "%TRACERT_ON%"=="true" (echo %GREEN%  2. Traceroute Test               [ENABLED]%RESET%) else (echo %WHITE%  2. Traceroute Test               [DISABLED]%RESET%)
if "%DNS_ON%"=="true" (echo %GREEN%  3. DNS Lookup Test               [ENABLED]%RESET%) else (echo %WHITE%  3. DNS Lookup Test               [DISABLED]%RESET%)
if "%PORT_ON%"=="true" (echo %GREEN%  4. Port Connectivity Test        [ENABLED]%RESET%) else (echo %WHITE%  4. Port Connectivity Test        [DISABLED]%RESET%)
echo.
echo %YELLOW%Advanced Tools:%RESET%
echo %CYAN%  5. Subdomain Discovery%RESET%
echo %CYAN%  6. Network Configuration Info%RESET%
echo %CYAN%  7. View Network Statistics%RESET%
echo.
echo %YELLOW%Management:%RESET%
echo %MAGENTA%  8. Manage Targets%RESET%
echo %MAGENTA%  9. View Current Targets%RESET%
echo %GREEN% 10. RUN ALL ENABLED TESTS%RESET%
echo %RED% 11. Exit%RESET%
echo.
echo %BOLD%%CYAN%==================================================%RESET%
set /p "choice=%YELLOW%Select an option (1-11): %RESET%"

if "%choice%"=="1" call :toggle_ping & goto :main_menu
if "%choice%"=="2" call :toggle_tracert & goto :main_menu
if "%choice%"=="3" call :toggle_dns & goto :main_menu
if "%choice%"=="4" call :toggle_port & goto :main_menu
if "%choice%"=="5" call :subdomain_discovery & goto :main_menu
if "%choice%"=="6" call :network_config & goto :main_menu
if "%choice%"=="7" call :network_stats & goto :main_menu
if "%choice%"=="8" call :manage_targets & goto :main_menu
if "%choice%"=="9" call :view_targets & goto :main_menu
if "%choice%"=="10" call :run_tests & goto :main_menu
if "%choice%"=="11" goto :exit_program

echo %RED%Invalid choice. Press any key to continue...%RESET%
pause >nul
goto :main_menu

REM ===============================================
REM           TEST TOGGLE FUNCTIONS
REM ===============================================
:toggle_ping
if "%PING_ON%"=="true" (set "PING_ON=false") else (set "PING_ON=true")
goto :eof
:toggle_tracert
if "%TRACERT_ON%"=="true" (set "TRACERT_ON=false") else (set "TRACERT_ON=true")
goto :eof
:toggle_dns
if "%DNS_ON%"=="true" (set "DNS_ON=false") else (set "DNS_ON=true")
goto :eof
:toggle_port
if "%PORT_ON%"=="true" (set "PORT_ON=false") else (set "PORT_ON=true")
goto :eof

REM ===============================================
REM           ADVANCED TOOLS
REM ===============================================
:subdomain_discovery
cls & echo.
echo %BOLD%%CYAN%================= SUBDOMAIN DISCOVERY =================%RESET%
echo.
set /p "domain=%YELLOW%Enter domain to scan (e.g., google.com): %RESET%"
if "%domain%"=="" goto :eof
echo. & echo %CYAN%Scanning for common subdomains of: %WHITE%%domain%%RESET% & echo.
set "subdomains=www mail ftp admin blog shop api dev test staging beta mobile cdn static assets secure vpn remote support help docs"
for %%s in (%subdomains%) do (
    powershell -command "if(Test-Connection -ComputerName '%%s.%domain%' -Count 1 -Quiet){Write-Host '[FOUND] %%s.%domain%' -ForegroundColor Green}else{Write-Host '[NOT FOUND] %%s.%domain%' -ForegroundColor DarkGray}"
)
echo. & echo %GREEN%Scan complete.%RESET% & pause >nul & goto :eof

:network_config
cls & echo.
echo %BOLD%%CYAN%============== NETWORK CONFIGURATION INFO ===============%RESET%
echo. & echo %YELLOW%--- Network Adapters ---%RESET%
ipconfig /all | findstr /C:"Description" /C:"Physical Address" /C:"IPv4 Address" /C:"Subnet Mask" /C:"Default Gateway" /C:"DNS Servers"
echo. & echo %YELLOW%--- Public IP Address ---%RESET%
powershell -command "try{(Invoke-RestMethod -Uri 'https://ipinfo.io/ip').Trim()}catch{'Unable to fetch public IP'}"
echo. & echo %YELLOW%--- Active TCP Connections ---%RESET%
netstat -an | find "ESTABLISHED"
echo. & pause >nul & goto :eof

:network_stats
cls & echo.
echo %BOLD%%CYAN%================== NETWORK STATISTICS ===================%RESET%
echo. & echo %YELLOW%--- Interface Statistics (All) ---%RESET%
netstat -e
echo. & echo %YELLOW%--- TCP/UDP Protocol Statistics ---%RESET%
netstat -s | findstr /C:"Segments Received" /C:"Segments Sent" /C:"Datagrams Received" /C:"Datagrams Sent"
echo. & echo %YELLOW%--- Latency Test ---%RESET%
echo %WHITE%Pinging Cloudflare DNS (1.1.1.1)...%RESET%
ping -n 4 1.1.1.1 | findstr "Average"
echo. & pause >nul & goto :eof

REM ===============================================
REM           TARGET MANAGEMENT
REM ===============================================
:manage_targets
cls & echo.
echo %BOLD%%CYAN%================== TARGET MANAGEMENT ==================%RESET%
echo %CYAN%  1. View Targets%RESET%
echo %CYAN%  2. Add New Target%RESET%
echo %CYAN%  3. Delete a Target%RESET%
echo %CYAN%  4. Clear All Targets%RESET%
echo %CYAN%  5. Create Default Targets%RESET%
echo %CYAN%  6. Back to Main Menu%RESET%
echo %BOLD%%CYAN%==================================================%RESET%
set /p "tchoice=%YELLOW%Select an option: %RESET%"
if "%tchoice%"=="1" call :view_targets_sub & goto :manage_targets
if "%tchoice%"=="2" call :add_target & goto :manage_targets
if "%tchoice%"=="3" call :delete_target & goto :manage_targets
if "%tchoice%"=="4" call :clear_targets & goto :manage_targets
if "%tchoice%"=="5" call :create_defaults & goto :manage_targets
if "%tchoice%"=="6" goto :eof
goto :manage_targets

:view_targets_sub
cls & echo. & echo %YELLOW%--- Current Targets ---%RESET%
if exist "%TARGETS_FILE%" (type "%TARGETS_FILE%") else (echo %RED%No targets defined.%RESET%)
echo. & pause >nul & goto :eof

:add_target
echo. & set /p "new_target=%YELLOW%Enter new target (hostname or IP): %RESET%"
if "%new_target%"=="" goto :eof
echo %new_target%>>"%TARGETS_FILE%"
echo %GREEN%Target '%new_target%' added.%RESET% & timeout /t 1 >nul & goto :eof

:delete_target
cls & echo. & echo %YELLOW%--- Delete a Target ---%RESET%
if not exist "%TARGETS_FILE%" (echo %RED%No targets to delete.%RESET% & pause >nul & goto :eof)
set "line_num=0"
for /f "tokens=*" %%a in ('type "%TARGETS_FILE%"') do (
    set /a line_num+=1
    echo %WHITE%  !line_num!. %%a%RESET%
)
echo. & set /p "del_choice=%YELLOW%Enter number to delete (0 to cancel): %RESET%"
if "%del_choice%"=="0" goto :eof
set "current_num=0" & set "TEMP_FILE=%TEMP%\targets.tmp"
(for /f "tokens=*" %%a in ('type "%TARGETS_FILE%"') do (
    set /a current_num+=1
    if !current_num! neq %del_choice% echo %%a
)) > "%TEMP_FILE%"
move /y "%TEMP_FILE%" "%TARGETS_FILE%" >nul
echo %GREEN%Target deleted.%RESET% & timeout /t 1 >nul & goto :eof

:clear_targets
echo. & set /p "confirm=%YELLOW%Clear all targets? (y/N): %RESET%"
if /i "%confirm%"=="y" (del "%TARGETS_FILE%" >nul 2>&1 & echo %GREEN%All targets cleared.%RESET%) else (echo %BLUE%Cancelled.%RESET%)
timeout /t 1 >nul & goto :eof

:create_defaults
(echo google.com & echo cloudflare.com & echo 8.8.8.8 & echo 1.1.1.1) > "%TARGETS_FILE%"
echo %GREEN%Default targets created.%RESET% & timeout /t 1 >nul & goto :eof

:view_targets
call :view_targets_sub & goto :eof

REM ===============================================
REM           MAIN TEST RUNNER
REM ===============================================
:run_tests
if "%PING_ON%%TRACERT_ON%%DNS_ON%%PORT_ON%"=="falsefalsefalsefalse" (
    echo %RED%No tests enabled!%RESET% & timeout /t 2 >nul & goto :eof
)
if not exist "%TARGETS_FILE%" (
    echo %YELLOW%Targets file not found. Creating defaults...%RESET% & call :create_defaults
)
cls & echo. & echo %BOLD%%CYAN%================== RUNNING NETWORK TESTS ==================%RESET%
echo %CYAN%Started at: %WHITE%!DATE! !TIME!%RESET%

REM --- Handle potential Unicode file format ---
set "ANSI_TARGETS_FILE=%TEMP%\targets_ansi.txt"
set "CLEAN_TARGETS_FILE=%TEMP%\targets_clean.txt"

REM Convert Unicode to ANSI if needed
powershell -command "Get-Content -Path '%TARGETS_FILE%' | Set-Content -Path '%ANSI_TARGETS_FILE%' -Encoding ASCII"
if !errorlevel! neq 0 (
    echo %YELLOW%Converting Unicode targets file to ANSI format...%RESET%
    copy "%TARGETS_FILE%" "%ANSI_TARGETS_FILE%" >nul 2>&1
)

REM --- Sanitize targets file (now works with any encoding) ---
echo %CYAN%Validating targets...%RESET%
REM Improved pattern to filter only valid hostnames/IPs but handle both Unicode and ANSI
findstr /R /C:"^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$" "%ANSI_TARGETS_FILE%" > "%CLEAN_TARGETS_FILE%" 2>nul
if %errorlevel% neq 0 (
    REM Try alternate method if findstr fails due to encoding
    powershell -command "Get-Content '%ANSI_TARGETS_FILE%' | Where-Object { $_ -match '^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$' } | Set-Content '%CLEAN_TARGETS_FILE%'"
)

REM --- Check if we have any valid targets ---
set "file_is_empty=true"
for /f "usebackq" %%L in ("%CLEAN_TARGETS_FILE%") do (
    set "file_is_empty=false"
    goto :break_check_empty
)
:break_check_empty

if "%file_is_empty%"=="true" (
    echo %RED%No valid targets found! Creating and using default targets...%RESET%
    call :create_defaults
    copy "%TARGETS_FILE%" "%CLEAN_TARGETS_FILE%" >nul 2>&1
)

REM --- Initialize counters ---
set /a test_count=0 & set /a success_count=0 & set /a fail_count=0

REM --- Loop through CLEANED targets ---
for /f "usebackq delims=" %%i in ("%CLEAN_TARGETS_FILE%") do (
    set /a test_count+=1
    echo. & echo %BLUE%--- Testing Target !test_count!: [%%i] ---%RESET%
    if "%PING_ON%"=="true" call :run_ping_test "%%i"
    if "%TRACERT_ON%"=="true" call :run_tracert_test "%%i"
    if "%DNS_ON%"=="true" call :run_dns_test "%%i"
    if "%PORT_ON%"=="true" call :run_port_test "%%i"
)

REM --- Clean up temporary files ---
del "%CLEAN_TARGETS_FILE%" >nul 2>&1
del "%ANSI_TARGETS_FILE%" >nul 2>&1

echo. & echo %BOLD%%CYAN%==================== TEST SUMMARY =====================%RESET%
echo %YELLOW%  Total valid targets tested: %WHITE%!test_count!%RESET%
if "%PING_ON%"=="true" echo %GREEN%  Ping Tests - Success: %WHITE%!success_count!%GREEN%, Failed: %WHITE%!fail_count!%RESET%
echo %CYAN%  Completed at: %WHITE%!DATE! !TIME!%RESET%
echo. & pause >nul & goto :eof

REM ===============================================
REM           INDIVIDUAL TEST FUNCTIONS
REM ===============================================
:run_ping_test
set "target=%~1" & echo. & echo %YELLOW%  ^> Ping Test...%RESET%
ping -n 4 "%target%" >nul 2>&1
if !errorlevel!==0 (
    echo %GREEN%    [SUCCESS]%RESET% Host is reachable.
    set /a success_count+=1
    for /f "tokens=*" %%p in ('ping -n 4 "%target%" ^| findstr "Average"') do echo %CYAN%    %%p%RESET%
) else (
    echo %RED%    [FAILED]%RESET% Host is not reachable.
    set /a fail_count+=1
)
goto :eof

:run_tracert_test
set "target=%~1" & echo. & echo %YELLOW%  ^> Traceroute Test...%RESET%
tracert -d -h 15 -w 1000 "%target%" | findstr /C:" 1 " /C:" 2 " /C:" 3 " /C:" 4 " /C:" 5 " /C:"ms" /C:"Trace complete"
goto :eof

:run_dns_test
set "target=%~1" & echo. & echo %YELLOW%  ^> DNS Lookup Test...%RESET%
powershell -command "try{($lookup=Resolve-DnsName -Name '%target%' -Type A -ErrorAction Stop).IPAddress}catch{'DNS resolution failed'}"
goto :eof

:run_port_test
set "target=%~1" & echo. & echo %YELLOW%  ^> Port Scan...%RESET%
set "ports=80,443,21,22,25,3389"
for %%p in (%ports%) do (
    powershell -command "$port=%%p; $tcp=New-Object System.Net.Sockets.TcpClient; try{$conn=$tcp.ConnectAsync('%target%',$port).Wait(200); if($tcp.Connected){Write-Host ('    [OPEN] Port '+$port) -f Green}else{Write-Host ('    [CLOSED] Port '+$port) -f Red}}catch{Write-Host ('    [FILTERED] Port '+$port) -f Yellow}; $tcp.Close()"
)
goto :eof

REM ===============================================
REM               EXIT PROGRAM
REM ===============================================
:exit_program
cls & echo.
echo %BOLD%%GREEN%==================================================%RESET%
echo %BOLD%%GREEN%        Thank you for using the tool!            %RESET%
echo %BOLD%%GREEN%==================================================%RESET%
echo. & timeout /t 1 >nul
exit /b 0
