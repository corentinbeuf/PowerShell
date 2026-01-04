<#
.SYNOPSIS
    Entra : Send a report of the status of the secret app

.DESCRIPTION
    Entra : Send a report of the status of the secret app

.PARAMETER

.EXAMPLE
    .\Check-SecretsExpiration.ps1

.INPUTS
.OUTPUTS

.NOTES
    NAME:   Check-SecretsExpiration.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2026.01.04
            Initial version
#>

$ReportPath = "C:\Temp\AppRegistrationExpirations.csv"
 
Connect-MgGraph -Scopes "Application.Read.All" -NoWelcome
 
$AllApps = Get-MgApplication -All
 
$AppExpirationData = @()
Foreach ($App in $AllApps)
{
    # Check the App Secrets
    $AllSecrets = $App.PasswordCredentials
    Foreach($Secret in $AllSecrets)
    {
        $AppExpirationData += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationID   = $App.AppId
            CredentialName  = $Secret.DisplayName
            CreatedDateTime = $App.CreatedDateTime
            StartDateTime   = $Secret.StartDateTime
            EndDateTime     = $Secret.EndDateTime
            ExpireStatus    = if ($Secret.EndDateTime -lt (Get-Date)) { "Expired" } elseif($Secret.EndDateTime -lt $ExpirationDate) {"Expiring Soon"} Else { "Current" }
            Type        = "Client Secret"
            DaysLeft        = ($Secret.EndDateTime - (Get-Date)).Days
            Notes           =  $App.Notes
        }
    }
 
    # Check App Certificates
    foreach ($Cert in $App.KeyCredentials) {
            $AppExpirationData += [PSCustomObject]@{
                ApplicationName = $App.DisplayName
                ApplicationID   = $App.AppId
                CredentialName  = $Cert.DisplayName
                CreatedDateTime = $App.CreatedDateTime
                StartDateTime   = $Cert.StartDateTime
                EndDateTime     = $Cert.EndDateTime
                ExpireStatus    = if ($Cert.EndDateTime -lt (Get-Date)) { "Expired" } elseif($Cert.EndDateTime -lt $ExpirationDate) {"Expiring Soon"} else { "Current" }
                Type        = "Certificate"
                DaysLeft        = ($Cert.EndDateTime - (Get-Date)).Days
                Notes           =  $App.Notes
            }
    }
}

$AppExpirationData | Format-table
$AppExpirationData | Export-Csv -Path $ReportPath -NoTypeInformation