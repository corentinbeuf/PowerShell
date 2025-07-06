#Requires -Version 5.1
#Requires -RunAsAdministrator

If (!(Test-Path "C:\Temp")) {
    Write-Host "Creating C:\Temp folder"
    New-Item "C:\Temp" -Type Directory | Out-Null
}

# github relases winget : https://github.com/microsoft/winget-cli/releases/
#https://docs.microsoft.com/fr-fr/windows/package-manager/winget/install
If (!(Test-Path "C:\TEMP\WinGet.msixbundle" -PathType leaf))
{
    Write-Host "Download winget"
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.11.400/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\TEMP\WinGet.msixbundle" | Out-Null
    Write-Host "Download Microsoft Visual C++ 2015 UWP Desktop Runtime Package"
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "C:\TEMP\VisualDeskstopRuntime.appx" | Out-Null
    Write-Host "Add 'Microsoft Visual C++ 2015 UWP Desktop Runtime Package' to App Package Manager"
    Add-AppxPackage -path "C:\TEMP\VisualDeskstopRuntime.appx" | Out-Null
}

try {
    Write-Host "Add winget to App Package Manager"
    Add-AppxPackage -path "C:\Temp\WinGet.msixbundle" -ErrorAction Stop | Out-Null
    #https://www.phhsnews.com/how-to-install3340
} catch {
    Write-Host "The winget program could not be added in Windows"
    Write-Host "Please execute WinGet.msixbundle file in C:\Temp to install manually Winget" -BackgroundColor Black -ForegroundColor Yellow
    Break
}