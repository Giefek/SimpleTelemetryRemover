@echo off
title Simple Telemetry Remover v26.11
setlocal EnableDelayedExpansion

net session >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo [SimpleTelemetryRemover] Administrator permissions are required to disable telemetry services...
    timeout /t 5 /nobreak >nul
    goto done
)

echo [SimpleTelemetryRemover] Disabling telemetry services will begin shortly...
timeout /t 5 /nobreak >nul

set "SERVICES=DiagTrack;dmwappushservice;diagnosticshub.standardcollector.service;diagsvc;WdiServiceHost;DPS;WdiSystemHost;WerSvc;PcaSvc;MapsBroker;lfsvc;RetailDemo;edgeupdate;edgeupdatem;WMPNetworkSvc;wisvc;Sense;DiagTrack-Vault;diagtrack-runner;CDPUserSvc;OneSyncSvc;MessagingService;UserDataSvc;UnistoreSvc;PimIndexMaintenanceSvc;CaptureService;DevicesFlowUserSvc;cbdhsvc;UevAgentService;DoSvc;TroubleshootingSvc;DusmSvc;FamilySafetyMonitor;NaturalAuthentication;SharedRealitySvc;Spectrum;WalletService"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$raw = $env:SERVICES; " ^
    "$services = $raw.Split(';'); " ^
    "$total = $services.Length; " ^
    "$disabled = 0; " ^
    "for ($i = 0; $i -lt $total; $i++) { " ^
    "    $s = $services[$i]; " ^
    "    try { " ^
    "        $svcList = @(Get-Service -Name ($s + '*') -ErrorAction SilentlyContinue); " ^
    "        if ($svcList.Count -gt 0) { " ^
    "            foreach ($item in $svcList) { " ^
    "                try { " ^
    "                    if ($item.Status -ne 'Stopped') { Stop-Service -Name $item.Name -Force -ErrorAction SilentlyContinue }; " ^
    "                    Set-Service -Name $item.Name -StartupType Disabled -ErrorAction SilentlyContinue; " ^
    "                } catch {} " ^
    "            } " ^
    "        }; " ^
    "        $disabled++; " ^
    "    } catch { $disabled++; } " ^
    "    [Console]::Write([char]13 + ('[SimpleTelemetryRemover] Disabling telemetry services [{0}/{1}]' -f $disabled, $total)); " ^
    "} " ^
    "[Console]::WriteLine(); " ^
    "Write-Host '[SimpleTelemetryRemover] Finished disabling telemetry services...'; " ^
    "Write-Host ('[SimpleTelemetryRemover] Disabled [{0}/{1}] services!' -f $disabled, $total); "

:done
pause >nul
goto done
