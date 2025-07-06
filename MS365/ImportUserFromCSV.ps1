Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

$UserList = import-csv "C:\temp\users.csv" -Delimiter ";" -Encoding ansi

foreach($user in $UserList){

    if (![string]::IsNullOrEmpty($user.jobTitle )) {
        Update-MgUser -UserId $user.id -JobTitle $user.jobTitle
    }

    if (![string]::IsNullOrEmpty($user.department)) {
        Update-MgUser -UserId $user.id -Department $user.department
    }

    if (![string]::IsNullOrEmpty($user.telephoneNumber)) {
        Update-MgUser -UserId $user.id -BusinessPhones $user.telephoneNumber
    }

    if (![string]::IsNullOrEmpty($user.mobilePhone)) {
        Update-MgUser -UserId $user.id -MobilePhone $user.mobilePhone
    }

    if (![string]::IsNullOrEmpty($user.streetAddress)) {
        Update-MgUser -UserId $user.id -StreetAddress $user.streetAddress
    }

    if (![string]::IsNullOrEmpty($user.city)) {
        Update-MgUser -UserId $user.id -City $user.city
    }

    if (![string]::IsNullOrEmpty($user.postalCode)) {
        Update-MgUser -UserId $user.id -PostalCode $user.postalCode
    }

    if (![string]::IsNullOrEmpty($user.state )) {
        Update-MgUser -UserId $user.id -State $user.state
    }

    if (![string]::IsNullOrEmpty($user.country)) {
        Update-MgUser -UserId $user.id -Country $user.country
    }

    if (![string]::IsNullOrEmpty($user.companyName)) {
        Update-MgUser -UserId $user.id -CompanyName $user.companyName
    }

    if (![string]::IsNullOrEmpty($user.surname  )) {
        Update-MgUser -UserId $user.id -Surname $user.surname  
    }

    if (![string]::IsNullOrEmpty($user.givenName  )) {
        Update-MgUser -UserId $user.id -GivenName $user.givenName  
    }

    if (![string]::IsNullOrEmpty($user.displayName  )) {
        Update-MgUser -UserId $user.id -DisplayName $user.displayName  
    }

}