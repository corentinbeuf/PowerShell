param(
    [string]$Mailbox
)

$Results = @()

Write-Host "🔍 Extract folders for $Mailbox mailbox"
$Folders = Get-MailboxFolderStatistics -Identity $Mailbox

foreach ($Folder in $Folders) {
    $FolderPath = $Folder.FolderPath -replace '/', '\'

    $Identity = "$Mailbox`:$FolderPath"

    Write-Host "📁 Check folder : $Identity" - -ForegroundColor Yellow

    try {
        $Permissions = Get-MailboxFolderPermission -Identity $Identity -ErrorAction Stop
        foreach ($perm in $Permissions) {
            $Results += [PSCustomObject]@{
                Folder          = $FolderPath
                User            = $perm.User
                AccessRights    = ($perm.AccessRights -join ', ')
            }
        }
    } catch {
       Write-Host "❌ Impossible to access to : $Identity" -ForegroundColor Red
    }
}

if ($Results.Count -eq 0) {
    Write-Host "❌ No results found - Please check the paths has correct or mailbox has folders with permissions"
} else {
    $CsvPath = "C:\Temp\MailboxPermissions_$($Mailbox.replace('@','_')).csv"
    $Results | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "✅ Results exported to $CsvPath" -ForegroundColor Green
    Start-Process $CsvPath
}

Disconnect-ExchangeOnline -Confirm:$false