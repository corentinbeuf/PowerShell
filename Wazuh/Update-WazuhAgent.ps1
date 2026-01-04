<#
.SYNOPSIS
    Update Windows Wazuh agent

.DESCRIPTION
    Update Windows Wazuh agent

.PARAMETER Version
    This parameter must contain the version of Wazuh agent that you want

.EXAMPLE
    .\Update-WazuhAgent.ps1 -Version 4.14.1

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Update-WazuhAgent.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2026.01.04
            Initial version
#>

# Parameters
param(
    $Version
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

$WazuhServiceName = "WazuhSvc"

if (!(Test-Path "C:\Temp")) {
    Write-Host "`n[INFO] Create temp folder..." -ForegroundColor Cyan
    New-Item -Path "C:\Temp" -Type Directory | Out-Null
}

Write-Host "`n[INFO] Download version $version of Wazuh agent..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-$($Version)-1.msi" -OutFile "C:\Temp\wazuh-agent-$($Version)-1.msi" -UseBasicParsing | Out-Null

Write-Host "`n[INFO] Start update of Wazuh agent..." -ForegroundColor Cyan
msiexec.exe /i C:\Temp\wazuh-agent-$Version-1.msi /q /wait

$Service = Get-Service -Name $WazuhServiceName -ErrorAction SilentlyContinue
if ($Service) {
    if ($Service.Status -ne "Running") {
        Write-Host "`n[INFO] Start Wazuh service..." -ForegroundColor Cyan
        Start-Service -Name $WazuhServiceName
        Write-Host "✅ Service started successfully" -ForegroundColor Green
    } else {
        Write-Host "`n[WARNING] Wazuh service is already running" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n❌ Wazuh service not found" -ForegroundColor Red
}

if ((Test-Path "C:\Temp")) {
    Write-Host "`n[INFO] Remove temp folder..." -ForegroundColor Cyan
    Remove-Item -Path "C:\Temp" -Recurse | Out-Null
}

Write-Host "`n✅ Wazuh agent update completed" -ForegroundColor Green