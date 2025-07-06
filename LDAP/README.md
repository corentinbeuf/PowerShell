# Envoyer des mails depuis un annuaire LDAP

- Modifier les champs suivant dans le script :
	- `$ldapServer`
    - `$ldapBaseDN`
    - `$ldapFilter`
    - `SmtpServer`
    - `-From`
    - `$smtpServer`
    - `$smtpSender`
    - `$mailSubject`
    - `Body`
- Enregistrer le script.
- Exécuter le script.
```ps1
.\sendMailFromLDAP.ps1
```