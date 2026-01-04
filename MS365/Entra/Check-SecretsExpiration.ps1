<#
.SYNOPSIS
    Entra : Send a report when secrets or certificates are expired or expiring soon (30 days left)

.DESCRIPTION
    Entra : Send a report when secrets or certificates are expired or expiring soon (30 days left)

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

$DaysBeforeExpiration = 30
$ExpirationDate = (Get-Date).AddDays($DaysBeforeExpiration)

$EmailTo = "destinataire@exemple.com"
$EmailFrom = "expediteur@exemple.com"
$EmailSubject = "🔔 Warning : Azure AD Secrets & Certificates expired soon"
$SMTPServer = "smtp.office365.com"

If (!(Get-Module -ListAvailable -Name 'Microsoft.Graph' -ErrorAction SilentlyContinue)) {
    Write-Host "`n[INFO] Install Microsoft.Graph Module..." -ForegroundColor Cyan

    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    Write-Host "✅ Module 'Microsoft.Graph' installed" -ForegroundColor Green
}

Write-Host "`n[INFO] Connect to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Application.Read.All", "Mail.Send" -NoWelcome

Write-Host "`n[INFO] Get all Azure AD app..." -ForegroundColor Cyan
$AllApps = Get-MgApplication -All
Write-Host "✅ $($AllApps.Count) applications found" -ForegroundColor Green

$AppExpirationData = @()

Foreach ($App in $AllApps) {
    $AllSecrets = $App.PasswordCredentials
    Foreach($Secret in $AllSecrets) {
        $DaysLeft = ($Secret.EndDateTime - (Get-Date)).Days
        $ExpireStatus = if ($Secret.EndDateTime -lt (Get-Date)) { 
            "Expired" 
        } elseif($Secret.EndDateTime -lt $ExpirationDate) {
            "Expiring Soon"
        } else { 
            "Current" 
        }
        
        $AppExpirationData += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationID   = $App.AppId
            CredentialName  = $Secret.DisplayName
            CreatedDateTime = $App.CreatedDateTime
            StartDateTime   = $Secret.StartDateTime
            EndDateTime     = $Secret.EndDateTime
            ExpireStatus    = $ExpireStatus
            Type            = "Client Secret"
            DaysLeft        = $DaysLeft
            Notes           = $App.Notes
        }
    }
 
    foreach ($Cert in $App.KeyCredentials) {
        $DaysLeft = ($Cert.EndDateTime - (Get-Date)).Days
        $ExpireStatus = if ($Cert.EndDateTime -lt (Get-Date)) { 
            "Expired" 
        } elseif($Cert.EndDateTime -lt $ExpirationDate) {
            "Expiring Soon"
        } else { 
            "Current" 
        }
        
        $AppExpirationData += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationID   = $App.AppId
            CredentialName  = $Cert.DisplayName
            CreatedDateTime = $App.CreatedDateTime
            StartDateTime   = $Cert.StartDateTime
            EndDateTime     = $Cert.EndDateTime
            ExpireStatus    = $ExpireStatus
            Type            = "Certificate"
            DaysLeft        = $DaysLeft
            Notes           = $App.Notes
        }
    }
}

$AlertItems = $AppExpirationData | Where-Object { 
    $_.ExpireStatus -eq "Expired" -or $_.ExpireStatus -eq "Expiring Soon" 
}

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  ⚠️  SECRETS & CERTIFICATES NEED YOUR ATTENTION" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow

if ($AlertItems.Count -eq 0) {
    Write-Host "`n✅ No secrets or certificates expired or expiring within $DaysBeforeExpiration days" -ForegroundColor Green
} else {
    Write-Host "`n🔴 Number of alerts : $($AlertItems.Count)" -ForegroundColor Red
    Write-Host ""
    
    $AlertItems | Sort-Object DaysLeft | Format-Table -Property @(
        @{Label="Application"; Expression={$_.ApplicationName}; Width=25},
        @{Label="Type"; Expression={$_.Type}; Width=15},
        @{Label="Credential"; Expression={$_.CredentialName}; Width=20},
        @{Label="Date d'expiration"; Expression={$_.EndDateTime.ToString("dd/MM/yyyy")}; Width=18},
        @{Label="Jours restants"; Expression={$_.DaysLeft}; Width=15},
        @{Label="Statut"; Expression={
            if ($_.ExpireStatus -eq "Expired") { 
                "🔴 EXPIRED" 
            } else { 
                "🟠 EXPIRING SOON" 
            }
        }; Width=20}
    ) -AutoSize
}

if ($AlertItems.Count -gt 0) {
    Write-Host "`n[INFO] Preparation of the email..." -ForegroundColor Cyan
    
    $EmailBody = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        h2 { color: #d9534f; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th { background-color: #d9534f; color: white; padding: 12px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .expired { background-color: #f8d7da; font-weight: bold; }
        .expiring { background-color: #fff3cd; }
        .summary { background-color: #f8f9fa; padding: 15px; border-left: 4px solid #d9534f; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h2>⚠️ Warning : Azure AD Secrets and Certificates requiring attention</h2>
    
    <div class="summary">
        <strong>Summary :</strong><br>
        Total number of alerts : <strong>$($AlertItems.Count)</strong><br>
        Expired : <strong>$($AlertItems | Where-Object {$_.ExpireStatus -eq "Expired"} | Measure-Object | Select-Object -ExpandProperty Count)</strong><br>
        Expiring soon (under $DaysBeforeExpiration days) : <strong>$($AlertItems | Where-Object {$_.ExpireStatus -eq "Expiring Soon"} | Measure-Object | Select-Object -ExpandProperty Count)</strong>
    </div>
    
    <table>
        <tr>
            <th>Application</th>
            <th>Type</th>
            <th>Credential</th>
            <th>Expiration date</th>
            <th>Remaining days</th>
            <th>Status</th>
        </tr>
"@

    foreach ($Item in ($AlertItems | Sort-Object DaysLeft)) {
        $RowClass = if ($Item.ExpireStatus -eq "Expired") { "expired" } else { "expiring" }
        $StatusText = if ($Item.ExpireStatus -eq "Expired") { "🔴 EXPIRÉ" } else { "🟠 EXPIRE BIENTÔT" }
        
        $EmailBody += @"
        <tr class="$RowClass">
            <td>$($Item.ApplicationName)</td>
            <td>$($Item.Type)</td>
            <td>$($Item.CredentialName)</td>
            <td>$($Item.EndDateTime.ToString("dd/MM/yyyy HH:mm"))</td>
            <td>$($Item.DaysLeft)</td>
            <td>$StatusText</td>
        </tr>
"@
    }

    $EmailBody += @"
    </table>
    
    <p style="margin-top: 30px; color: #666; font-size: 12px;">
        <em>This report was automatically generated the $(Get-Date -Format "dd/MM/yyyy at HH:mm")</em>
    </p>
</body>
</html>
"@

    try {
        Send-MailMessage -SmtpServer $SMTPServer -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -BodyAsHtml -Encoding utf8NoBOM
        Write-Host "✅ Email sent." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error while sending the email" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Write-Host "`n═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  ✅ Script is complete" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow

Disconnect-MgGraph