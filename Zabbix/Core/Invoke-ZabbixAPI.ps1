function Invoke-ZabbixAPI {
    param (
        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter(Mandatory)]
        $Params
    )

    $body = @{
        jsonrpc = "2.0"
        method  = $Method
        params  = $Params
        auth    = $Global:ApiToken
        id      = 1
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod `
        -Uri $Global:ZabbixUrl `
        -Method POST `
        -Headers $Global:ZabbixHeaders `
        -Body $body
}
