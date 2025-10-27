param(
    [string]$Email,
    $UserPrincipalName
)

$Language = "fr-FR"
$TimeZone = "Romance Standard Time"

Write-Host "`n[INFO] Connect to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName

try {
    if ((Get-Mailbox -Identity $Email | Get-MailboxRegionalConfiguration).Language -ne $Language -or (Get-Mailbox -Identity $Email | Get-MailboxRegionalConfiguration).TimeZone -ne "$TimeZone" ) {
        Get-Mailbox -Identity $Email | Set-MailboxRegionalConfiguration -Language $Language -TimeZone "$TimeZone" -LocalizeDefaultFolderName
        Write-Host "✅ Mailbox is set to french for user : $Email" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Mailbox is already set to french language"
    }
} catch {
    Write-Host "❌ Impossible to set mailbox to french for user : $Email" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}