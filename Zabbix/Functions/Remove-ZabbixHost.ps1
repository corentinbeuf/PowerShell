function Remove-ZabbixHost {
    param (
        [Parameter(Mandatory)]
        [string]$HostName
    )

    $hostId = (Invoke-ZabbixAPI "host.get" @{
        filter = @{ host = $HostName }
        output = "hostid"
    }).result.hostid

    if ($hostId) {
        Invoke-ZabbixAPI "host.delete" @(@($hostId))
    }
}
