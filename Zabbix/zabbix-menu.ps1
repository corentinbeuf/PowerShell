<#
.SYNOPSIS
    MS365 Admin Center : Block connection on specific MS365 account

.DESCRIPTION
    MS365 Admin Center : Block connection on specific MS365 account

.PARAMETER

.EXAMPLE
    .\zabbix-menu.ps1

.INPUTS
.OUTPUTS

.NOTES
    NAME:   zabbix-menu.ps1
    AUTHOR: Corentin BEUF
    EMAIL:  corentin.beuf@ynov.com
    VERSION HISTORY:
    1.0     2026.01.03
            Initial version
#>

# Charger la config
. "$PSScriptRoot\config.ps1"

# Charger le core API
. "$PSScriptRoot\Core\Invoke-ZabbixAPI.ps1"

# Charger toutes les fonctions
Get-ChildItem "$PSScriptRoot\Functions\*.ps1" | ForEach-Object {
    . $_.FullName
}

do {
    Write-Host "`n### ZABBIX 7.0 ###"
    Write-Host "1 - Infos hôte"
    Write-Host "2 - Créer hôte"
    Write-Host "3 - Supprimer hôte"
    Write-Host "q - Quitter" -ForegroundColor Red

    $choice = Read-Host "Choix"

    switch ($choice) {
        "1" {
            $name = Read-Host "Nom de l'hôte"
            Get-ZabbixHost $name | ConvertTo-Json -Depth 5
        }
        "2" {
            New-ZabbixHost `
                (Read-Host "Nom") `
                (Read-Host "IP") `
                (Read-Host "Groupe") `
                (Read-Host "Template")
        }
        "3" {
            Remove-ZabbixHost (Read-Host "Nom de l'hôte")
        }
    }
} until ($choice -eq "q")