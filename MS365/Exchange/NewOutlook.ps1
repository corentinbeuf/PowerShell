Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Function DisableNewOutlookForOrganisation {
    Write-Host "`n[INFO] Disable new Outlook on the tenant..." -ForegroundColor Cyan

    try {
        $mailbox = Get-User -ResultSize unlimited -Filter "(RecipientType -eq 'UserMailbox')"
        $mailbox | foreach {Set-CASMailbox -Identity $_.MicrosoftOnlineServicesID -OneWinNativeOutlookEnabled $false}
        Write-Host "✅ New Outlook is disabled" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Impossible to disable new Outlook on the tenant" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
    
}

Function EnableNewOutlookForOrganisation {
    Write-Host "`n[INFO] Enable new Outlook on the tenant..." -ForegroundColor Cyan

    try {
        $mailbox = Get-User -ResultSize unlimited -Filter "(RecipientType -eq 'UserMailbox')"
        $mailbox | foreach {Set-CASMailbox -Identity $_.MicrosoftOnlineServicesID -OneWinNativeOutlookEnabled $false}
        Write-Host "✅ New Outlook is enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Impossible to enable new Outlook on the tenant" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Function DisableNewOutlookForOneUser {
    param(
        $UserEmail
    )

    Write-Host "`n[INFO] Disable new Outlook for one user..." -ForegroundColor Cyan

    try {
        Set-CASMailbox -Identity $UserEmail -OneWinNativeOutlookEnabled $false
        Write-Host "✅ New Outlook is disabled for user : $UserEmail" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Impossible to disable new Outlook for user : $UserEmail" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Function EnableNewOutlookForOneUser {
    param(
        $UserEmail
    )

    Write-Host "`n[INFO] Enable new Outlook for one user..." -ForegroundColor Cyan

    try {
        Set-CASMailbox -Identity $UserEmail -OneWinNativeOutlookEnabled $true
        Write-Host "✅ New Outlook is enabled for user : $UserEmail" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Impossible to enable new Outlook for user : $UserEmail" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

do
{
    Write-Host
    Write-Host "1 - Disable new Outlook on the organisation"
    Write-Host "2 - Enable new Outlook on the organisation"
    Write-Host "3 - Disable new Outlook for one user"
    Write-Host "4 - Enable new Outlook for one user"
    Write-Host "q - Quit" -ForegroundColor Red
    Write-Host
    $input = Read-Host "Please make a selection"
    Write-Host
    switch ($input) {
        '1' {
            DisableNewOutlookForOrganisation
        } '2' {
            EnableNewOutlookForOrganisation
        } '3' {
            $email = Read-Host "Please enter user email :"
            DisableNewOutlookForOneUser -UserEmail $email
        } '4' {
            $email = Read-Host "Please enter user email :"
            EnableNewOutlookForOneUser -UserEmail $email
        }
    }
}