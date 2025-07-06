Install-Module -Name LDAP
Import-Module LDAP

# LDAP Parameters
$ldapServer = "ldap.example.com:389"
$ldapBaseDN = "ou=Users,dc=example,dc=com"
$ldapFilter = "(|(o=Example1)(o=Example2))"
#$ldapFilter = "(ou=Informatique)"
$ldapProperties = @("mail")
$ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapServer)
$ldapConnection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Anonymous
$ldapConnection.SessionOptions.ProtocolVersion = 3
$searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest($ldapBaseDN, $ldapFilter, [System.DirectoryServices.Protocols.SearchScope]::Subtree, $ldapProperties)
$searchResponse = $ldapConnection.SendRequest($searchRequest)

$Destinataires = ""

# Mail parameters
$smtpServer = "smtp.example.com"
$smtpSender = "no_reply@example.com"
$mailSubject = "Sujet"

# [System.Collections.ArrayList]$To = @()
$To = [System.Collections.ArrayList]::new()
foreach ($entry in $searchResponse.Entries) {        
    if (($entry.Attributes[“mail”]) -ne $null)
    {
        $Mail =  ($entry.Attributes[“mail”])[0] 
        if ($Destinataires -ne "") {
            $Destinataires = $Destinataires + ","
        }
        $Destinataires = $Destinataires + $Mail
        $To += $Mail
        
    }
}
Send-MailMessage -SmtpServer $smtpServer -From $smtpSender -To $To -Subject $mailSubject -Body "Contenu" -BodyAsHtml