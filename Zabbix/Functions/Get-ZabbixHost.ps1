function Get-ZabbixHost {
    param (
        [Parameter(Mandatory)]
        [string]$HostName
    )

    $result = Invoke-ZabbixAPI "host.get" @{
        filter = @{ host = $HostName }
        selectInterfaces      = "extend"
        selectGroups          = "extend"
        selectParentTemplates = "extend"
    }

    if (-not $result.result) {
        Write-Warning "Hôte '$HostName' introuvable"
        return
    }

    foreach ($zabbix_host in $result.result) {
        [PSCustomObject]@{
            Nom       = $zabbix_host.host
            ID        = $zabbix_host.hostid
            Statut    = if ($zabbix_host.status -eq 0) { "Actif" } else { "Désactivé" }
            IP        = $zabbix_host.interfaces[0].ip
            Groupe    = ($zabbix_host.groups.name -join ", ")
            Templates = ($zabbix_host.parentTemplates.name -join ", ")
        }
    }
}
