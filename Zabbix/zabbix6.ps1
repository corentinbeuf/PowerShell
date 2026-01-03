Function installZabbixModule() {
    If (!(Test-Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208")) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.2.201 -Force
        Install-Module -Name psbbix -Scope CurrentUser -Force
    }
    Import-Module -Name psbbix -Force
}

Function hostInformation() {
    $hostZabbix = Read-Host "Nom de l'hote:"
    Get-ZabbixHost -HostName $hostZabbix
}

Function createHost() {
    $newHostZabbix = Read-Host "Nom du nouvel hote: "
    $ip = Read-Host "Adresse IP nouvel hote: "

    $confirmationOS = Read-Host "Hôte Linux ou Windows ? Renseigner 'linux' ou 'windows'"
    If ($confirmationOS -eq "linux") {
        New-ZabbixHost -HostName $newHostZabbix -IP $ip -GroupID 2 -TemplateID "10544" -status 0
    }
    If ($confirmationOS -eq "windows") {
        New-ZabbixHost -HostName $newHostZabbix -IP $ip -GroupID 19 -TemplateID "10546" -status 0
    }
}

Function deleteHost() {
    $hostToDelete = Read-Host "Nom de l'hote a supprimer: "
    Get-ZabbixHost | ? name -Match $hostToDelete | %{Remove-ZabbixHost -HostID $_.hostid}
}

$ipAddress = "192.168.13.10"
Write-Host "Adresse IP Zabbix : 192.168.13.10"
installZabbixModule
Write-Host
Connect-Zabbix $ipAddress -noSSL

do
{
    Write-Host
    Write-Host
    Write-Host "################### Configuration Zabbix ###################"
    Write-Host "### 1 Information sur un hote"
    Write-Host "### 2 Creation d'un hote"
    Write-Host "### 3 Supprimer un hote"
    Write-Host "q = Quit" -ForegroundColor Red
    Write-Host "############################################################"
    Write-Host
    $input = Read-Host "Selectionner une option: "
    Write-Host
    switch ($input)
    {
        '1' {
            hostInformation
        } '2' {
            createHost
        } '3' {
            deleteHost
        } 'q' {
            return
        }
    }
    Write-Host
    #pause
    Write-Host
}
until ($input -eq 'q')