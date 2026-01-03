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
        $response = Invoke-ZabbixAPI "host.delete" @(@($hostId))

        if ($response.error) {
            Write-Error "Erreur création hôte : $($response.error.message)"
        } else {
            Write-Host "Hôte '$HostName' supprimé avec succès !" -ForegroundColor Green
        }
    }
}
