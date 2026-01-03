function Get-ZabbixHost {
    param (
        [Parameter(Mandatory)]
        [string]$HostName
    )

    Invoke-ZabbixAPI "host.get" @{
        filter = @{ host = $HostName }
        output = "extend"
        selectInterfaces = "extend"
    }
}