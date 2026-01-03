function Get-HostGroupId {
    param (
        [Parameter(Mandatory)]
        [string]$GroupName
    )

    (Invoke-ZabbixAPI "hostgroup.get" @{
        filter = @{ name = $GroupName }
        output = "groupid"
    }).result.groupid
}
