Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Function DisableNewOutlookForOrganisation {
    $mailbox = Get-User -ResultSize unlimited -Filter "(RecipientType -eq 'UserMailbox')"

    $mailbox | foreach {Set-CASMailbox -Identity $_.MicrosoftOnlineServicesID -OneWinNativeOutlookEnabled $false}
}

Function EnableNewOutlookForOrganisation {
    $mailbox = Get-User -ResultSize unlimited -Filter "(RecipientType -eq 'UserMailbox')"

    $mailbox | foreach {Set-CASMailbox -Identity $_.MicrosoftOnlineServicesID -OneWinNativeOutlookEnabled $true}
}

Function DisableNewOutlookForOneUser {
    param(
        $UserEmail
    )

    Set-CASMailbox -Identity $UserEmail -OneWinNativeOutlookEnabled $false
}

Function EnableNewOutlookForOneUser {
    param(
        $UserEmail
    )

    Set-CASMailbox -Identity $UserEmail -OneWinNativeOutlookEnabled $true
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