function Get-TemplateId {
    param (
        [Parameter(Mandatory)]
        [string]$TemplateName
    )

    (Invoke-ZabbixAPI "template.get" @{
        filter = @{ host = $TemplateName }
        output = "templateid"
    }).result.templateid
}
