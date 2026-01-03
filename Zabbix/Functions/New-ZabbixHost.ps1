function New-ZabbixHost {
    param (
        [string]$HostName,
        [string]$IP,
        [string]$GroupName,
        [string]$TemplateName
    )

    $groupId    = Get-HostGroupId $GroupName
    $templateId = Get-TemplateId $TemplateName

    Invoke-ZabbixAPI "host.create" @{
        host = $HostName
        interfaces = @(
            @{
                type  = 1
                main  = 1
                useip = 1
                ip    = $IP
                dns   = ""
                port  = "10050"
            }
        )
        groups    = @(@{ groupid = $groupId })
        templates = @(@{ templateid = $templateId })
    }
}
