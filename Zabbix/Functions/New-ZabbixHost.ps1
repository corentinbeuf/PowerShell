function New-ZabbixHost {
    param (
        [Parameter(Mandatory)]
        [string]$HostName,

        [Parameter(Mandatory)]
        [string]$IP,

        [Parameter(Mandatory)]
        [string]$GroupIDOrName,

        [Parameter(Mandatory)]
        [string]$TemplateIDOrName,

        [ValidateSet("Agent", "SNMP", "JMX", "IPMI")]
        [string]$InterfaceType = "Agent"
    )

    if ($GroupIDOrName -as [int]) {
        $groupId = [int]$GroupIDOrName
    } else {
        $groupId = Get-HostGroupId $GroupIDOrName
        if (-not $groupId) { Write-Error "Groupe '$GroupIDOrName' introuvable."; return }
    }

    if ($TemplateIDOrName -as [int]) {
        $templateId = [int]$TemplateIDOrName
    } else {
        $templateId = Get-TemplateId $TemplateIDOrName
        if (-not $templateId) { Write-Error "Template '$TemplateIDOrName' introuvable."; return }
    }

    $interfaceTypeId = switch ($InterfaceType.ToLower()) {
        "agent" { 1 }
        "snmp"  { 2 }
        "ipmi"  { 3 }
        "jmx"   { 4 }
    }

    $port = switch ($interfaceTypeId) {
        1 { "10050" }  # Agent
        2 { "161" }    # SNMP
        3 { "623" }    # IPMI
        4 { "12345" }  # JMX
    }

    $response = Invoke-ZabbixAPI "host.create" @{
        host       = $HostName
        name       = $HostName
        interfaces = @(@{
            type  = $interfaceTypeId
            main  = 1
            useip = 1
            ip    = $IP
            dns   = ""
            port  = $port
        })
        groups    = @(@{ groupid = $groupId })
        templates = @(@{ templateid = $templateId })
        status    = 0
    }

    if ($response.error) {
        Write-Error "Erreur création hôte : $($response.error.message)"
    } else {
        Write-Host "Hôte '$HostName' créé avec succès ! ID : $($response.result.hostids[0])" -ForegroundColor Green
    }
}
