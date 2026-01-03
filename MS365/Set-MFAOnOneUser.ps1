<#
.SYNOPSIS
    MS365 Admin Center : Setup MFA authentication on specific account

.DESCRIPTION
    MS365 Admin Center : Setup MFA authentication on specific account

.PARAMETER Email
    This parameter must contain the email address of a person where MFA is not enabled/enforced

.EXAMPLE
    .\Set-MFAOnOneUser.ps1 -Email toto@example.com

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Set-MFAOnOneUser.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2025.12.18
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
Connect-MgGraph -Scopes "User.ReadWrite.All", "Policy.ReadWrite.AuthenticationMethod" -NoWelcome

try {
    $userid = (Get-MgUser -UserId $Email).Id

    $body = @{"perUserMfaState" = "enforced"}
    
    Invoke-MgGraphRequest -Method PATCH -Uri "/beta/users/$userid/authentication/requirements" -Body $body
    Write-Host "✅ Account $Email is setup with MFA" -ForegroundColor Green
}
catch {
    Write-Host "❌ Impossible to update account : $Email" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}