@echo off
setlocal EnableExtensions
chcp 437 >nul
title Otimizador PC - Ryzen 5 5600G / Windows 11
color 0B

rem ==========================================================
rem  OtimizadorPC - otimizacoes de FPS, internet e limpeza
rem  Feito para: Windows 11, Ryzen 5 5600G, 16GB DDR4, SSD
rem  Tudo e reversivel pela opcao [D] do menu e um ponto de
rem  restauracao do Windows e criado antes de qualquer mudanca.
rem ==========================================================

rem ---- Pede permissao de administrador se precisar ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Pedindo permissao de administrador...
    if "%~1"=="" (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    ) else (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%~1' -Verb RunAs"
    )
    exit /b
)

set "BK=%USERPROFILE%\OtimizadorPC"
if not exist "%BK%" mkdir "%BK%"
set "MM=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
set "PONTO_FEITO=0"
set "COPIA=%BK%\OtimizadorPC.bat"

rem ---- Modos de um clique, usados pelos botoes da Area de Trabalho ----
if /i "%~1"=="auto" goto ARG_AUTO
if /i "%~1"=="turbo" goto ARG_TURBO
if /i "%~1"=="limpeza" goto ARG_LIMPEZA
if /i "%~1"=="foco" goto ARG_FOCO

:MENU
cls
echo.
echo  ==========================================================
echo                O T I M I Z A D O R   P C
echo         Ryzen 5 5600G  ^|  16GB DDR4  ^|  SSD  ^|  Win 11
echo  ==========================================================
echo.
echo   [1] Aplicar TUDO recomendado  - jogos + internet + limpeza
echo   [T] TURBO antes de jogar - fecha programas pesados de fundo
echo   [F] MODO FOCO NO JOGO - processador prioriza o seu jogo
echo   [S] MAIS FPS: upscaling e geracao de quadros, tipo Lossless Scaling
echo   [2] So JOGOS / FPS
echo   [3] So INTERNET / ping
echo   [4] LIMPEZA de arquivos inuteis + TRIM do SSD
echo   [5] Trocar DNS  - Cloudflare / Google / Automatico
echo   [6] DIAGNOSTICO - checa RAM, XMP, Dual Channel, video, disco
echo   [7] Programas que iniciam com o Windows
echo   [8] Reparar arquivos do Windows - SFC + DISM, demora
echo   [9] Reparar rede - reset Winsock/IP, exige reiniciar
echo.
echo   [A] Criar BOTOES na Area de Trabalho - otimizar com 1 clique
echo   [M] Limpeza AUTOMATICA toda semana
echo   [D] DESFAZER tudo - voltar ao padrao do Windows
echo   [0] Sair
echo.
set "OP="
set /p "OP=  Escolha uma opcao: "
if "%OP%"=="1" goto OP_TUDO
if "%OP%"=="2" goto OP_JOGOS
if "%OP%"=="3" goto OP_INTERNET
if "%OP%"=="4" goto OP_LIMPEZA
if "%OP%"=="5" goto OP_DNS
if "%OP%"=="6" goto OP_DIAG
if "%OP%"=="7" goto OP_INICIO
if "%OP%"=="8" goto OP_REPARAR
if "%OP%"=="9" goto OP_REDE
if /i "%OP%"=="T" goto OP_TURBO
if /i "%OP%"=="F" goto OP_FOCO
if /i "%OP%"=="S" goto OP_ESCALA
if /i "%OP%"=="A" goto OP_ATALHOS
if /i "%OP%"=="M" goto OP_MANUT
if /i "%OP%"=="D" goto OP_DESFAZER
if "%OP%"=="0" exit /b
goto MENU

rem ==========================================================
:OP_TUDO
cls
call :PONTO
call :JOGOS
call :INTERNET
call :LIMPEZA
echo.
echo  ==========================================================
echo   PRONTO! Agora faca tambem, fora do Windows:
echo   1. Rode a opcao [6] DIAGNOSTICO para ver XMP e Dual Channel
echo   2. Atualize o driver AMD Adrenalin: amd.com/support
echo   3. Atualize a BIOS da placa-mae se estiver antiga
echo  ==========================================================
call :REINICIAR
goto MENU

:OP_JOGOS
cls
call :PONTO
call :JOGOS
call :REINICIAR
goto MENU

:OP_INTERNET
cls
call :PONTO
call :INTERNET
call :REINICIAR
goto MENU

:OP_LIMPEZA
cls
call :LIMPEZA
pause
goto MENU

rem ==========================================================
:PONTO
if "%PONTO_FEITO%"=="1" exit /b
echo.
echo [SEGURANCA] Criando ponto de restauracao do Windows...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 0 /f >nul 2>&1
powershell -NoProfile -Command "try { Enable-ComputerRestore -Drive ($env:SystemDrive + '\') -ErrorAction Stop; Checkpoint-Computer -Description 'Antes do OtimizadorPC' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Host '            Ponto de restauracao criado.' -ForegroundColor Green } catch { Write-Host ('            Aviso: nao deu para criar o ponto: ' + $_.Exception.Message) -ForegroundColor Yellow }"
set "PONTO_FEITO=1"
exit /b

rem ==========================================================
:JOGOS
echo.
echo ===================== JOGOS / FPS =====================
echo [1/14] Plano de energia Desempenho Maximo...
call :PLANO

echo [2/9] Ativando Modo de Jogo do Windows...
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f >nul

echo [3/9] Desligando gravacao em segundo plano do Xbox Game Bar...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul

echo [4/9] Agendamento de GPU acelerado por hardware...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul

echo [5/9] Dando prioridade de CPU e GPU para jogos...
reg add "%MM%" /v SystemResponsiveness /t REG_DWORD /d 10 /f >nul
reg add "%MM%\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "%MM%\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul
reg add "%MM%\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul
reg add "%MM%\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul

echo [6/9] Desligando economia de energia do processador...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul

echo [7/9] Desligando aceleracao do mouse - mira mais precisa...
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul

echo [8/9] Efeitos visuais leves - sem transparencia e animacoes...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 100 /f >nul

echo [9/9] Desligando telemetria em segundo plano - DiagTrack...
sc config DiagTrack start= disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1

echo [10/13] Removendo propagandas e sugestoes do Windows...
set "CDM=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
for %%V in (SubscribedContent-338388Enabled SubscribedContent-338389Enabled SubscribedContent-353694Enabled SubscribedContent-353696Enabled SystemPaneSuggestionsEnabled SilentInstalledAppsEnabled SoftLandingEnabled) do reg add "%CDM%" /v %%V /t REG_DWORD /d 0 /f >nul

echo [11/13] Desligando Widgets e Copilot - rodam em segundo plano...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul

echo [12/13] Tirando o atraso dos programas ao ligar o PC...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul

echo [13/13] Desligando hibernacao - libera uns 6 GB no SSD...
powercfg /h off >nul 2>&1

echo [14/14] Processador focado no programa em primeiro plano - o jogo...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul

echo.
echo   Otimizacoes de jogos aplicadas.
exit /b

rem ---- Plano de energia: Desempenho Maximo (Ultimate Performance) ----
:PLANO
set "PLAN="
if exist "%BK%\plano.txt" set /p PLAN=<"%BK%\plano.txt"
if not defined PLAN goto PLANO_CRIAR
powercfg /query %PLAN% >nul 2>&1
if %errorlevel%==0 goto PLANO_ATIVAR
:PLANO_CRIAR
set "PLAN="
for /f "usebackq delims=" %%G in (`powershell -NoProfile -Command "[regex]::Match((powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61) -join ' ', '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}').Value"`) do set "PLAN=%%G"
if not defined PLAN set "PLAN=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
> "%BK%\plano.txt" echo %PLAN%
:PLANO_ATIVAR
rem Ryzen: turbo agressivo, clock minimo alto e todos os nucleos sempre acordados
powercfg /setacvalueindex %PLAN% sub_processor PERFBOOSTMODE 2 >nul 2>&1
powercfg /setacvalueindex %PLAN% sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex %PLAN% sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setacvalueindex %PLAN% sub_processor CPMINCORES 100 >nul 2>&1
powercfg /setactive %PLAN%
exit /b

rem ==========================================================
:INTERNET
echo.
echo ===================== INTERNET =====================
echo [1/5] Limpando cache de DNS...
ipconfig /flushdns >nul

echo [2/5] Ajustando TCP - autotuning e RSS...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1

echo [3/5] Tirando limite de rede do Windows durante jogos...
reg add "%MM%" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul

echo [4/5] Diminuindo atraso de pacotes - ping mais estavel...
for /f "delims=" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" ^| findstr /c:"{"') do (
    reg add "%%I" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%I" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul 2>&1
)

echo [5/5] Desligando economia de energia da placa de rede...
powershell -NoProfile -Command "Get-NetAdapter -Physical -ErrorAction SilentlyContinue | ForEach-Object { Disable-NetAdapterPowerManagement -Name $_.Name -NoRestart -ErrorAction SilentlyContinue }" >nul 2>&1

echo [6/6] Impedindo o Windows de usar sua internet para mandar updates a outros PCs...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul

echo.
echo   Otimizacoes de internet aplicadas.
echo   Dica: para jogar, cabo de rede e MUITO melhor que Wi-Fi.
exit /b

rem ==========================================================
:LIMPEZA
echo.
echo ===================== LIMPEZA =====================
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive ($env:SystemDrive.Substring(0,1))).Free/1GB,2)"') do set "ANTES=%%A"

echo [1/5] Apagando arquivos temporarios...
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1

echo [2/5] Limpando cache de downloads do Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%D in ("%SystemRoot%\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

echo [3/5] Esvaziando a Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo [4/5] Limpando cache de miniaturas e DNS...
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
ipconfig /flushdns >nul

echo [5/5] Otimizando o SSD - TRIM...
fsutil behavior set DisableDeleteNotify 0 >nul 2>&1
defrag %SystemDrive% /O

for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive ($env:SystemDrive.Substring(0,1))).Free/1GB,2)"') do set "DEPOIS=%%A"
echo.
echo   Espaco livre antes:  %ANTES% GB
echo   Espaco livre depois: %DEPOIS% GB
echo   Arquivos em uso pelo Windows nao sao apagados - isso e normal.
exit /b

rem ==========================================================
:OP_DNS
cls
echo.
echo  ===== TROCAR DNS =====
echo   [1] Cloudflare  1.1.1.1  - geralmente o mais rapido
echo   [2] Google      8.8.8.8
echo   [3] Automatico  - o da sua operadora, padrao
echo   [0] Voltar
echo.
set "D="
set /p "D=  Escolha: "
if "%D%"=="1" set "DNSCMD=Set-DnsClientServerAddress -ServerAddresses 1.1.1.1,1.0.0.1"
if "%D%"=="2" set "DNSCMD=Set-DnsClientServerAddress -ServerAddresses 8.8.8.8,8.8.4.4"
if "%D%"=="3" set "DNSCMD=Set-DnsClientServerAddress -ResetServerAddresses"
if "%D%"=="0" goto MENU
if not defined DNSCMD goto OP_DNS
powershell -NoProfile -Command "Get-NetAdapter -Physical | Where-Object Status -eq 'Up' | ForEach-Object { %DNSCMD% -InterfaceIndex $_.ifIndex; Write-Host ('  DNS alterado em: ' + $_.Name) -ForegroundColor Green }"
ipconfig /flushdns >nul
set "DNSCMD="
pause
goto MENU

rem ==========================================================
:OP_DIAG
cls
echo.
echo  ===================== DIAGNOSTICO =====================
echo.
echo  ----- MEMORIA RAM - o mais importante para o 5600G -----
powershell -NoProfile -Command "$m=@(Get-CimInstance Win32_PhysicalMemory); foreach($p in $m){ '  {4} {0}: {1} GB - rodando a {2} MHz - maximo do pente {3} MHz' -f $p.DeviceLocator,[math]::Round($p.Capacity/1GB),$p.ConfiguredClockSpeed,$p.Speed,$p.BankLabel }; ''; if($m.Count -lt 2){ Write-Host '  [!] SO 1 PENTE DE RAM = SINGLE CHANNEL.' -ForegroundColor Red; '      O video integrado do 5600G perde MUITO FPS assim, ate 30-40 por cento.'; '      Solucao: 2 pentes iguais, ex 2x8GB, nos slots A2 e B2 da placa-mae.' } else { Write-Host '  [OK] 2 ou mais pentes - Dual Channel.' -ForegroundColor Green }; $s=($m | Measure-Object ConfiguredClockSpeed -Minimum).Minimum; if($s -lt 2900){ Write-Host ('  [!] RAM rodando a so {0} MHz. ATIVE O XMP / DOCP / EXPO NA BIOS.' -f $s) -ForegroundColor Red; '      Esse e o ajuste que MAIS aumenta FPS no 5600G. Ideal: 3200 a 3600 MHz.' } else { Write-Host '  [OK] RAM em velocidade alta - XMP/DOCP ativo.' -ForegroundColor Green }"
echo.
echo  ----- PLACA DE VIDEO -----
powershell -NoProfile -Command "$g=@(Get-CimInstance Win32_VideoController); foreach($x in $g){ '  ' + $x.Name + '  - driver ' + $x.DriverVersion }; if(-not ($g | Where-Object { $_.Name -match 'RTX|GTX|RX [0-9]|Arc' })){ ''; Write-Host '  Voce usa o video integrado Radeon Vega 7 do 5600G. Dicas:' -ForegroundColor Yellow; '   - Na BIOS: UMA Frame Buffer Size = 2G'; '   - No AMD Adrenalin: ative Radeon Anti-Lag e Radeon Image Sharpening'; '   - Nos jogos: ative AMD FSR e use graficos baixos/medios' }"
echo.
echo  ----- SEGURANCA x DESEMPENHO -----
powershell -NoProfile -Command "try{ $d=Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop; if($d.VirtualizationBasedSecurityStatus -eq 2){ Write-Host '  [!] Integridade de Memoria / VBS LIGADA - pode custar 5-10 por cento de FPS.' -ForegroundColor Yellow; '      Para desligar: Seguranca do Windows - Seguranca do dispositivo - Isolamento de nucleo.'; '      Isso reduz um pouco a protecao do PC. Decisao sua, o script nao mexe nisso.' } else { Write-Host '  [OK] VBS / Integridade de Memoria desligada.' -ForegroundColor Green } } catch { '  Nao foi possivel checar o VBS.' }"
echo.
echo  ----- DISCO -----
powershell -NoProfile -Command "$d=Get-PSDrive ($env:SystemDrive.Substring(0,1)); $l=[math]::Round($d.Free/1GB,1); $t=[math]::Round(($d.Free+$d.Used)/1GB,1); '  {0} GB livres de {1} GB' -f $l,$t; if($l -lt ($t*0.15)){ Write-Host '  [!] Pouco espaco. SSD fica mais lento com menos de 15 por cento livre.' -ForegroundColor Red } else { Write-Host '  [OK] Espaco livre suficiente.' -ForegroundColor Green }"
echo.
echo  ----- PLANO DE ENERGIA ATIVO -----
powercfg /getactivescheme
echo.
pause
goto MENU

rem ==========================================================
:OP_INICIO
cls
echo.
echo  Abrindo a lista de programas que iniciam com o Windows...
echo  Desative tudo que voce nao precisa ligado o tempo todo:
echo  launchers de jogos, Discord, Spotify, OneDrive, Teams etc.
echo  NAO desative: driver de audio, AMD Software, antivirus.
start "" ms-settings:startupapps
pause
goto MENU

rem ==========================================================
:OP_REPARAR
cls
echo.
echo  Reparando imagem do Windows com DISM - pode levar 10-20 min...
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo  Verificando arquivos do sistema com SFC...
sfc /scannow
echo.
echo  Reparo concluido.
call :REINICIAR
goto MENU

rem ==========================================================
:OP_REDE
cls
echo.
echo  Isso reseta as configuracoes de rede. Use se a internet estiver
echo  com problema. Senhas de Wi-Fi salvas continuam salvas.
choice /c SN /m "  Continuar"
if errorlevel 2 goto MENU
netsh winsock reset
netsh int ip reset
ipconfig /release >nul
ipconfig /renew >nul
ipconfig /flushdns
call :REINICIAR
goto MENU

rem ==========================================================
:OP_DESFAZER
cls
echo.
echo  Voltando tudo ao padrao do Windows...
rem Plano de energia Equilibrado
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
if exist "%BK%\plano.txt" (
    for /f "usebackq delims=" %%P in ("%BK%\plano.txt") do powercfg /delete %%P >nul 2>&1
    del "%BK%\plano.txt" >nul 2>&1
)
rem Game Bar / DVR
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f >nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /f >nul 2>&1
rem HAGS
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /f >nul 2>&1
rem Prioridades multimidia
reg add "%MM%" /v SystemResponsiveness /t REG_DWORD /d 20 /f >nul
reg add "%MM%" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f >nul
reg add "%MM%\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "%MM%\Tasks\Games" /v "Priority" /t REG_DWORD /d 2 /f >nul
reg add "%MM%\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "Medium" /f >nul
reg add "%MM%\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "Normal" /f >nul
rem Power throttling
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /f >nul 2>&1
rem Mouse
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f >nul
rem Efeitos visuais
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 400 /f >nul
rem Telemetria
sc config DiagTrack start= auto >nul 2>&1
sc start DiagTrack >nul 2>&1
rem Rede
for /f "delims=" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" ^| findstr /c:"{"') do (
    reg delete "%%I" /v TcpAckFrequency /f >nul 2>&1
    reg delete "%%I" /v TCPNoDelay /f >nul 2>&1
)
netsh int tcp set heuristics enabled >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f >nul 2>&1
rem Extras
set "CDM=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
for %%V in (SubscribedContent-338388Enabled SubscribedContent-338389Enabled SubscribedContent-353694Enabled SubscribedContent-353696Enabled SystemPaneSuggestionsEnabled SilentInstalledAppsEnabled SoftLandingEnabled) do reg add "%CDM%" /v %%V /t REG_DWORD /d 1 /f >nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /f >nul 2>&1
powercfg /h on >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 2 /f >nul
if exist "%BK%\jogos.txt" (
    for /f "usebackq delims=" %%J in ("%BK%\jogos.txt") do reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%J\PerfOptions" /f >nul 2>&1
    del "%BK%\jogos.txt" >nul 2>&1
)
del "%BK%\ultimo_jogo.txt" >nul 2>&1
powershell -NoProfile -Command "Unregister-ScheduledTask -TaskName 'OtimizadorPC Limpeza Semanal' -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-NetAdapter -Physical -ErrorAction SilentlyContinue | ForEach-Object { Enable-NetAdapterPowerManagement -Name $_.Name -NoRestart -ErrorAction SilentlyContinue }" >nul 2>&1
echo.
echo  Tudo voltou ao padrao. DNS nao foi alterado - use a opcao [5] - [3] se quiser.
echo  Se algo ainda estiver estranho, use o ponto de restauracao
echo  "Antes do OtimizadorPC": tecla Windows - digite "rstrui".
call :REINICIAR
goto MENU

rem ==========================================================
rem  MODOS DE UM CLIQUE
rem ==========================================================
:ARG_AUTO
cls
echo.
echo  ===== OTIMIZACAO AUTOMATICA - nao precisa fazer nada =====
call :PONTO
call :JOGOS
call :INTERNET
call :LIMPEZA
echo.
echo  ==========================================================
echo   TUDO OTIMIZADO!
echo  ==========================================================
call :REINICIAR
exit /b

:ARG_TURBO
call :TURBO
echo.
echo  Pode jogar! Esta janela fecha sozinha.
timeout /t 5 >nul
exit /b

:ARG_LIMPEZA
call :LIMPEZA
exit /b

rem ==========================================================
:OP_TURBO
cls
call :TURBO
pause
goto MENU

:TURBO
echo.
echo ===================== TURBO PARA JOGAR =====================
echo [1/4] Fechando programas pesados de segundo plano...
for %%P in (OneDrive.exe Teams.exe ms-teams.exe Widgets.exe WidgetService.exe PhoneExperienceHost.exe YourPhone.exe Copilot.exe GameBar.exe GameBarFTServer.exe) do taskkill /f /im %%P >nul 2>&1
echo [2/4] Pausando Windows Update durante o jogo - volta sozinho depois...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop DoSvc >nul 2>&1
echo [3/4] Ativando energia maxima...
call :PLANO >nul
echo [4/4] Limpando cache de DNS e temporarios...
ipconfig /flushdns >nul
del /f /s /q "%TEMP%\*" >nul 2>&1
echo.
echo   Turbo ativado. Feche tambem o navegador antes de jogar:
echo   Chrome/Edge com muitas abas come RAM e video do 5600G.
exit /b

rem ==========================================================
rem  MODO FOCO NO JOGO
rem ==========================================================
:ARG_FOCO
set "JOGO="
if exist "%BK%\ultimo_jogo.txt" set /p JOGO=<"%BK%\ultimo_jogo.txt"
if defined JOGO goto FOCO_VIGIAR
echo  Nenhum jogo escolhido ainda. Abra o menu e use a opcao [F] primeiro.
pause
exit /b

:OP_FOCO
cls
echo.
echo  ===================== MODO FOCO NO JOGO =====================
echo  O processador passa a dar prioridade ALTA ao seu jogo e os
echo  programas de fundo - navegador, Spotify, Steam - ficam com
echo  prioridade baixa enquanto voce joga.
echo.
echo  Dica: abra o jogo antes, assim ele aparece na lista abaixo.
echo.
echo  Programas com janela aberta agora:
powershell -NoProfile -Command "Get-Process | Where-Object { $_.MainWindowTitle } | Sort-Object Name -Unique | ForEach-Object { '    ' + $_.Name + '.exe   -   ' + $_.MainWindowTitle }"
echo.
echo  Exemplos: cs2.exe  GTA5.exe  RobloxPlayerBeta.exe  FortniteClient-Win64-Shipping.exe
echo.
set "JOGO="
set /p "JOGO=  Nome do .exe do jogo, ou Enter para voltar: "
if not defined JOGO goto MENU
set "JOGO=%JOGO:"=%"
if /i not "%JOGO:~-4%"==".exe" set "JOGO=%JOGO%.exe"
call :REGISTRAR_JOGO
echo.
echo   [1] So registrar - prioridade alta toda vez que o jogo abrir
echo   [2] Registrar e VIGIAR - quando o jogo abrir ativa o Turbo e o
echo       foco, e quando o jogo fechar tudo volta ao normal sozinho
echo.
choice /c 12 /m "  Escolha"
if errorlevel 2 goto FOCO_VIGIAR
pause
goto MENU

:REGISTRAR_JOGO
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%JOGO%\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul
findstr /x /i /c:"%JOGO%" "%BK%\jogos.txt" >nul 2>&1 || >>"%BK%\jogos.txt" echo %JOGO%
>"%BK%\ultimo_jogo.txt" echo %JOGO%
echo.
echo   %JOGO% registrado: o Windows vai abrir ele sempre com prioridade ALTA.
echo   Obs: alguns jogos com anti-cheat ignoram isso, sem problema nenhum.
exit /b

:FOCO_VIGIAR
cls
set "NOME=%JOGO:~0,-4%"
title Modo Foco - vigiando %JOGO%
echo.
echo  ===================== MODO FOCO ATIVO =====================
echo   Vigiando: %JOGO%
echo   Pode abrir o jogo. Deixe esta janela aberta - pode minimizar.
echo   Para parar, e so fechar esta janela.
echo  ==========================================================
:FOCO_ESPERA
tasklist /fi "imagename eq %JOGO%" /fo csv /nh 2>nul | find /i "%JOGO%" >nul
if errorlevel 1 (
    timeout /t 3 /nobreak >nul
    goto FOCO_ESPERA
)
echo.
echo  [%time:~0,8%] Jogo aberto! Ativando Turbo e foco no processador...
call :TURBO >nul
call :FOCO_APLICAR
echo  [%time:~0,8%] Pronto. Bom jogo!
:FOCO_JOGANDO
timeout /t 5 /nobreak >nul
tasklist /fi "imagename eq %JOGO%" /fo csv /nh 2>nul | find /i "%JOGO%" >nul
if not errorlevel 1 goto FOCO_JOGANDO
echo  [%time:~0,8%] Jogo fechado. Voltando tudo ao normal...
call :FOCO_RESTAURAR
echo  [%time:~0,8%] Esperando o jogo abrir de novo...
goto FOCO_ESPERA

:FOCO_APLICAR
powershell -NoProfile -Command "Get-Process -Name '%NOME%' -ErrorAction SilentlyContinue | ForEach-Object { try { $_.PriorityClass='High' } catch {} }; Get-Process -Name chrome,msedge,firefox,opera,brave,Spotify,steamwebhelper,EpicGamesLauncher,EpicWebHelper,RiotClientServices -ErrorAction SilentlyContinue | ForEach-Object { try { $_.PriorityClass='BelowNormal' } catch {} }"
exit /b

:FOCO_RESTAURAR
powershell -NoProfile -Command "Get-Process -Name chrome,msedge,firefox,opera,brave,Spotify,steamwebhelper,EpicGamesLauncher,EpicWebHelper,RiotClientServices -ErrorAction SilentlyContinue | ForEach-Object { try { $_.PriorityClass='Normal' } catch {} }"
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
exit /b

rem ==========================================================
rem  MAIS FPS: UPSCALING E GERACAO DE QUADROS
rem ==========================================================
:OP_ESCALA
cls
echo.
echo  ========= MAIS FPS: UPSCALING E GERACAO DE QUADROS =========
echo  Gerar quadros extras exige um programa que usa a placa de video.
echo  Um .bat nao faz isso, mas estas opcoes funcionam no Vega 7 do 5600G:
echo.
echo  1. FSR DENTRO DO JOGO - gratis, a melhor opcao
echo     Nas opcoes graficas do jogo ative AMD FSR em Qualidade ou
echo     Equilibrado. Se tiver FSR 3 Frame Generation, ative tambem.
echo.
echo  2. LOSSLESS SCALING - pago, na Steam, funciona em QUALQUER jogo
echo     Ajuste bom para o 5600G:
echo       - Jogo em "janela sem bordas" e resolucao 720p ou 900p
echo       - Scaling: LS1 ou FSR - estica para a tela com nitidez
echo       - Frame Gen: LSFG, modo X2, Flow Scale 50, modo Performance ligado
echo       - So use Frame Gen se o jogo ja passa de 40 FPS, senao fica
echo         com atraso no mouse. Com 30 FPS, use so o Scaling.
echo.
echo  3. AMD SOFTWARE ADRENALIN
echo     Ative Radeon Anti-Lag e Radeon Image Sharpening.
echo     O AFMF, geracao de quadros da AMD, NAO funciona no Vega 7.
echo.
echo  4. NA BIOS - ganho real e gratis, faca com cuidado
echo     - XMP/DOCP ligado: RAM a 3200 ou 3600 MHz
echo     - UMA Frame Buffer Size: 2G
echo     - Precision Boost Overdrive: Enabled
echo     - Avancado: Curve Optimizer All Core Negative 10 - mais turbo
echo       e menos calor. Se o PC travar, volte para 0.
echo.
echo   [1] Abrir Lossless Scaling na Steam
echo   [2] Abrir o AMD Software
echo   [3] Baixar driver AMD mais recente
echo   [0] Voltar
echo.
choice /c 1230 /m "  Escolha"
if errorlevel 4 goto MENU
if errorlevel 3 (start "" "https://www.amd.com/pt/support/download/drivers.html" & goto OP_ESCALA)
if errorlevel 2 goto ESCALA_AMD
start "" "https://store.steampowered.com/app/993090/"
goto OP_ESCALA
:ESCALA_AMD
if exist "%ProgramFiles%\AMD\CNext\CNext\RadeonSoftware.exe" (
    start "" "%ProgramFiles%\AMD\CNext\CNext\RadeonSoftware.exe"
) else (
    echo  AMD Software nao encontrado. Use a opcao [3] para baixar o driver.
    pause
)
goto OP_ESCALA

rem ==========================================================
:COPIAR
if /i not "%~f0"=="%COPIA%" copy /y "%~f0" "%COPIA%" >nul 2>&1
exit /b

:OP_ATALHOS
cls
call :COPIAR
echo.
echo  Criando botoes na Area de Trabalho...
powershell -NoProfile -Command "$d=[Environment]::GetFolderPath('Desktop'); $w=New-Object -ComObject WScript.Shell; $a=$w.CreateShortcut($d + '\Otimizar PC.lnk'); $a.TargetPath='%COPIA%'; $a.Arguments='auto'; $a.IconLocation='shell32.dll,43'; $a.Description='Otimiza tudo com 1 clique'; $a.Save(); $b=$w.CreateShortcut($d + '\Turbo Jogo.lnk'); $b.TargetPath='%COPIA%'; $b.Arguments='turbo'; $b.IconLocation='shell32.dll,238'; $b.Description='Use antes de jogar'; $b.Save(); $c=$w.CreateShortcut($d + '\Menu Otimizador.lnk'); $c.TargetPath='%COPIA%'; $c.IconLocation='shell32.dll,21'; $c.Save(); $f=$w.CreateShortcut($d + '\Modo Foco Jogo.lnk'); $f.TargetPath='%COPIA%'; $f.Arguments='foco'; $f.IconLocation='shell32.dll,137'; $f.Description='Vigia o jogo e prioriza ele'; $f.Save(); Write-Host '  Botoes criados!' -ForegroundColor Green"
echo.
echo   "Otimizar PC"      - faz TUDO sozinho. Use 1 vez por mes.
echo   "Turbo Jogo"       - clique antes de abrir um jogo.
echo   "Modo Foco Jogo"   - vigia o ultimo jogo escolhido na opcao [F].
echo   "Menu Otimizador"  - abre este menu.
echo.
echo   O programa ficou guardado em: %BK%
pause
goto MENU

rem ==========================================================
:OP_MANUT
cls
call :COPIAR
echo.
echo  Agendando limpeza automatica todo domingo ao meio-dia.
echo  Se o PC estiver desligado, ela roda na proxima vez que ligar.
powershell -NoProfile -Command "$a=New-ScheduledTaskAction -Execute '%COPIA%' -Argument 'limpeza'; $t=New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 12pm; $s=New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries; Register-ScheduledTask -TaskName 'OtimizadorPC Limpeza Semanal' -Action $a -Trigger $t -Settings $s -RunLevel Highest -Force | Out-Null; Write-Host '  Limpeza semanal agendada!' -ForegroundColor Green"
echo  Para cancelar, use a opcao [D] DESFAZER.
pause
goto MENU

rem ==========================================================
:REINICIAR
echo.
echo  Algumas mudancas so valem depois de reiniciar o PC.
choice /c SN /m "  Reiniciar agora"
if errorlevel 2 exit /b
shutdown /r /t 10 /c "OtimizadorPC: reiniciando em 10 segundos"
exit /b
