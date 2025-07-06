#Requires -Version 5.1
#Requires -RunAsAdministrator

If (!(Test-Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")) {
    Write-Host "Downlodap NuGet package"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.2.201 -Force

    Write-Host "Install Windows Update module"
    Install-Module -Name PSWindowsUpdate -Force
}

If (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate\2.2.0.2")) {
    Write-Host "Import Windows Update module"
    Import-Module PSWindowsUpdate
}

Write-Host "Installation of the latest Windows updates"
Install-WindowsUpdate -AcceptAll
