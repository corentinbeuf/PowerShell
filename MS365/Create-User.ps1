param(
    [string]$DisplayName,
    [string]$GivenName,
    [string]$Surname
)

If (!(Get-Module -ListAvailable -Name 'Microsoft.Graph' -ErrorAction SilentlyContinue)) {
    Write-Host "`n[INFO] Install Microsoft Graph Module..." -ForegroundColor Cyan

    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    Write-Host "✅ Module 'Microsoft.Graph' installed" -ForegroundColor Green
}

Write-Host "`n[INFO] Import Microsoft Graph Module..." -ForegroundColor Cyan
Import-Module Microsoft.Graph

Write-Host "`n[INFO] Connect to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

$MailNickname - ($GivenName + "." + $Surname).ToLower()

Write-Host "`n[INFO] Please enter account information for new user (mail and password)..." -ForegroundColor Cyan
$credential = Get-Credential

$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
)

Write-Host "`n[INFO] Create user : $DisplayName..." -ForegroundColor Cyan
try {
    $PasswordProfile = New-Object -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphPasswordProfile
    $PasswordProfile.Password = $plainPassword
    $PasswordProfile.ForceChangePasswordNextSignIn = $false
    New-MgUser -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -mailNickname = $MailNickname -UserPrincipalName $credential.UserName -UsageLocaltion "FR" -PasswordProfile $PasswordProfile -AccountEnabled:$true
    Write-Host "✅ User $($credential.UserName) was created" -ForegroundColor Green
} catch {
    Write-Host "❌ Impossible to create user : $($credential.UserName)" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    exit 1
}