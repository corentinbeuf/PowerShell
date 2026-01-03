<#
.SYNOPSIS
    Exchange Online : Export users when mailbox size i greather than 40GB and send an email

.DESCRIPTION
    Exchange Online : Export users when mailbox size i greather than 40GB and send an email

.PARAMETER UserPrincipalName
    This parameter must contain email address of one MS365 global admin account or Exchange admin

.EXAMPLE
    .\Get-MailboxUsage.ps1 -UserPrincipalName admin@example.com

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Get-MailboxUsage.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2025.12.18
            Initial version
#>

# Parameters
param(
    $UserPrincipalName
)

If (!(Get-Module -ListAvailable -Name 'ExchangeOnlineManagement' -ErrorAction SilentlyContinue)) {
    Write-Host "`n[INFO] Install ExchangeOnlineManagement Module..." -ForegroundColor Cyan

    Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
    Write-Host "✅ Module 'ExchangeOnlineManagement' installed" -ForegroundColor Green
}

Write-Host "`n[INFO] Connect to Exchange online..." -ForegroundColor Cyan
Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName -ShowBanner:$false

[array]$UsersMailbox = Get-Mailbox -ResultSize unlimited
$LargeMailboxes = New-Object System.Collections.ArrayList

if (-not $UsersMailbox) {
    Write-Host "`n❌ No users mailbox found. Exiting script" -ForegroundColor Red
    return
}

$counter = 0
$totalUsers = $UsersMailbox.Count

foreach ($User in $UsersMailbox) {
    $counter++

    $percentComplete = [math]::Round(($counter / $totalUsers) * 100)

    $progressParams = @{
        Activity        = "Processing Users"
        Status          = "User $($counter) of $totalUsers - $($User.PrimarySmtpAddress) - $percentComplete% Complete"
        PercentComplete = $percentComplete
    }

    Write-Progress @progressParams

    $mailboxSize = Get-MailboxStatistics -Identity $User.PrimarySmtpAddress

    $bytes = [int64](($mailboxSize.TotalItemSize.Value -replace '*\(|\sbytes\).*','') -replace ',', '')
    $sizeGB = [math]::Round($bytes / 1GB, 2)

    if ($sizeGB -ge 40) {
        Write-Host "📨 $($mailboxSize.DisplayName) : $sizeGB GB" -ForegroundColor Yellow
        $null = $LargeMailboxes.Add([PSCustomObject]@{
            DisplayName = $mailboxSize.DisplayName
            Email       = $mailboxSize.PrimarySmtpAddress
            SizeGB      = $sizeGB
        })
    }
}

Write-Progress -Activity "Processing Users" - Completed

if ($LargeMailboxes.Count -ge 0){
    $Body = "List of mailbox greater than 40GB : `n`n"
    foreach ($mb in $LargeMailboxes) {
        $Body += "$($mb.DisplayName) - $($mb.SizeGB) GB`n"
    }

    $MailParams = @{
        From        = "noreply@example.com"
        To          = "admin@example.com"
        Subject     = "MS365 mailbox greater than 40GB"
        Body        = $Body
        SmtpServer  = "smtp.office365.com"
        Port        = 587
        UseSsl      = $true
    }

    Send-MailMessage @MailParams
    Write-Host "✅ Email sent." -ForegroundColor Green
}