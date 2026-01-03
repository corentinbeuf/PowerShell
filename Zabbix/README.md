# Zabbix

Pour utiliser le script, il faut créer un utilisateur dans Zabbix avec les droits suivants :
- Lecture / écriture sur les Host groups
- Accès aux Templates

Une fois l'utilisateur créé, générer un token API dans Zabbix. Bien penser à noter le **token d'authentification**.

Une fois le token récupéré, ouvrir le fichier "**config.ps1**" :
- Remplacer la valeur "**VOTRE_TOKEN_API**" par le **token d'authentification**
- Faire correspondre l'adresse IP ou le FQDN d'accès à Zabbix