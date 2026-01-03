<#
.SYNOPSIS
    Manage Zabbix hosts without using the web interface

.DESCRIPTION
    Manage Zabbix hosts without using the web interface

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

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\Core\Invoke-ZabbixAPI.ps1"
Get-ChildItem "$PSScriptRoot\Functions\*.ps1" | ForEach-Object { . $_.FullName }

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
            $zabbix_host = Get-ZabbixHost $name
            if ($host) {
                Write-Host "`nInformations pour l'hôte $name :" -ForegroundColor Cyan
                Write-Host "Nom       : $($zabbix_host.Nom)"
                Write-Host "ID        : $($zabbix_host.ID)"
                Write-Host "Statut    : $($zabbix_host.Statut)"
                Write-Host "IP        : $($zabbix_host.IP)"
                Write-Host "Groupe(s) : $($zabbix_host.Groupe)"
                Write-Host "Template(s) : $($zabbix_host.Templates)"
            } else {
                Write-Warning "Aucun hôte trouvé pour '$name'"
            }
        }
        "2" {
            $name = Read-Host "Nom de l'hôte"
            $ip   = Read-Host "Adresse IP"

            $groups = Invoke-ZabbixAPI "hostgroup.get" @{ output = "extend" }
            $groups.result | ForEach-Object { Write-Host "$($_.groupid) : $($_.name)" }
            $groupID = Read-Host "ID du groupe à utiliser"

            $template = Read-Host "Nom du template"
            Write-Host "Type d'interface : Agent, SNMP, IPMI, JMX"
            $typeChoice = Read-Host "Choisir type d'interface (par défaut Agent)"
            if (-not $typeChoice) { $typeChoice = "Agent" }

            New-ZabbixHost -HostName $name -IP $ip -GroupIDOrName $groupID -TemplateIDOrName $template -InterfaceType $typeChoice
        }
        "3" {
            $name = Read-Host "Nom de l'hôte à supprimer"
            Remove-ZabbixHost $name
        }
    }
} until ($choice -eq "q")
