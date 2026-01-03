<#
.SYNOPSIS
    MS365 Admin Center : Block connection on specific MS365 account

.DESCRIPTION
    MS365 Admin Center : Block connection on specific MS365 account

.PARAMETER Email
    This parameter must contain email address of a person

.EXAMPLE
    .\Block-AccountConnection.ps1 -Email toto@example.com

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Block-AccountConnection.ps1
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
Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome

try {
    $user = Get-MgUser -UserId $Email -Property "AccountEnabled"

    if ($null -eq $user) {
        Write-Host "`n❌ User $Email not found." -ForegroundColor Red
        return
    }

    if ($user.AccountEnabled -eq $true) {
        Update-MgUser -UserId $Email -BodyParameter @{ accountEnabled = $false }
        Write-Host "✅ Account $Email is blockd" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Account has already been blocked" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Impossible to update account : $Email" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}