<#
.SYNOPSIS
    MS365 Admin Center : Setup new password on specific account

.DESCRIPTION
    MS365 Admin Center : Setup new password on specific account

.PARAMETER Email
    This parameter must contain the email address of a person where MFA is not enabled/enforced

.EXAMPLE
    .\Set-PasswordForOneUser.ps1 -Email toto@example.com

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Set-PasswordForOneUser.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2026.01.03
            Initial version
#>

# Parameters
param(
    [string]$Email
)

If (!(Get-Module -ListAvailable -Name 'Microsoft.Graph' -ErrorAction SilentlyContinue)) {
    Write-Host "`n[INFO] Install Microsoft Graph Module..." -ForegroundColor Cyan

    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    Write-Host "✅ Module 'Microsoft.Graph' installed" -ForegroundColor Green
}

Write-Host "`n[INFO] Connect to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome

try {
    $userid = (Get-MgUser -UserId $Email).Id
    
    Write-Host "`n[INFO] Please enter new password..." -ForegroundColor Cyan
    $credential = Get-Credential -UserName $Email

    # $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    #     [Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
    # )
    $newPassword = ConvertTo-SecureString $credential.Password -AsPlainText -Force

    Update-MgUser -UserId $userid -PasswordProfile @{ ForceChangePasswordNextSignIn = $false; Password = $newPassword }
    Write-Host "✅ Password has changed for $Email account" -ForegroundColor Green
}
catch {
    Write-Host "❌ Impossible to change password for $Email account" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}