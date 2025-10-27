Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Function ConvertToSharedMailbox {
    param (
        [string]$UserEmail
    )

    Write-Host "`n[INFO] Convert mailbox to shared mailbox..." -ForegroundColor Cyan

    $mailboxType = "Shared"

    try {
        if ((Get-Mailbox -Identity $UserEmail).RecipientTypeDetails -ne $mailboxType ) {
            Set-Mailbox -Identity $UserEmail -Type $mailboxType
            Write-Host "✅ Mailbox type is set to shared : $UserEmail" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Mailbox type is already shared "
        }
    } catch {
        Write-Host "❌ Impossible to set mailbox type to shared : $UserEmail" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Function ConvertToUserMailbox {
    param (
        [string]$UserEmail
    )

    Write-Host "`n[INFO] Convert mailbox to user mailbox..." -ForegroundColor Cyan

    $mailboxType = "Regular"

    try {
        if ((Get-Mailbox -Identity $UserEmail).RecipientTypeDetails -ne $mailboxType ) {
            Set-Mailbox -Identity $UserEmail -Type $mailboxType
            Write-Host "✅ Mailbox type is set to regular : $UserEmail" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Mailbox type is already regular "
        }
    } catch {
        Write-Host "❌ Impossible to set mailbox to regular : $UserEmail" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

do
{
    Write-Host
    Write-Host "1 - Convert mailbox to shared mailbox"
    Write-Host "2 - Convert mailbox to user mailbox"
    Write-Host "q - Quit" -ForegroundColor Red
    Write-Host
    $input = Read-Host "Please make a selection"
    Write-Host
    switch ($input) {
        '1' {
            $email = Read-Host "Please enter user email :"
            ConvertToSharedMailbox -UserEmail $email
        } '2' {
            $email = Read-Host "Please enter user email :"
            ConvertToUserMailbox -UserEmail $email
        } 'q' {
            Disconnect-ExchangeOnline -Confirm:$false
            return
        }
    }
}
until ($input -eq 'q')