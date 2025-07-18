# 🛠️ Guide Utilisateur – Sprint 10 : Installation & Configuration    

## 1. Introduction    
Voici le contenu de ce Readme qui reprends essentiellement les configurations non terminées depuis le début du projet :  
( les configurations ont été ajoutés également dans les Readme de leurs sprints respectifs pour plus de lisibilité)  


**PARTENARIAT D'ENTREPRISE - VPN site-à-site**  
Mettre en place un VPN site-à-site entre les 2 réseaux d'entreprise pour avoir une communication sécurisée avec OpenVPN  

**Reprise des anciens objectifs**  
Mise en place de Filezilla pour l'administration de l'interface GUI de FTP  
Mise en place une plannification de sauvegarde (script /ou/ GPO puis lancer un script /ou/ logiciel) sur un disque du serveur de sauvegarde - S5   
Debuguage SRV-BastionGuacamole  
Mise en place des règles dans Pfsense pour le Srv-BastionGuacamole  

## 2. PARTENARIAT D'ENTREPRISE - VPN site-à-site      
A venir 

## 3. Mise en place de Filezilla pour l'administration de l'interface GUI de FTP     
A venir

## 4. Mise en place une plannification de sauvegarde (par script)    

### 4.1 - Prérequis       
- Dans le serveur FTP, créer les dossiers modifier les propriétaires  
```bash  
sudo mkdir -p /home/ftpuser/veeam  
sudo chown ftpuser:ftpuser /home/ftpuser/veeam  
```

- Depuis SRV-Veeam vérifier la connexion avec le serveur FTP  
Ouvrir Powershell  

```powershell 
ftp 10.10.20.2   
```

Se connecter avec : ftpuser / Azerty1*  

- Depuis le SRV-Veeam, installer WinSCP  
Télécharge WinSCP depuis le site officiel (https://winscp.net/eng/download.php) et l'installer avec les options par défaut.

- Depuis SRV-Veam, créer un dossier de scripts dans C:


### 4.2 - Creation du script : veeam_ftp_upload.ps1 dans C:\Scripts\

Créer le fichier avec NotePad (ou Visualcodestudio / powershell IDE)  
```powershell
# Variables
$localFolder = "D:\Job Windows"  
$remoteFolder = "/veeam"  
$ftpHost = "10.10.20.2"  
$ftpUser = "ftpuser"  
$ftpPassword = "Azerty1*"  

# Fichier de script WinSCP à générer  
$scriptPath = "C:\Scripts\ftp_script.txt"  

# Contenu du script WinSCP  
Set-Content -Path $scriptPath -Value @"  
open ftp://$($ftpUser):$($ftpPassword)@$($ftpHost)  
lcd "$localFolder"  
cd "$remoteFolder"  
put *.*  
exit  
"@  

# Exécuter le script avec WinSCP
& "C:\Program Files (x86)\WinSCP\WinSCP.com" /script="$scriptPath"  
```

### 4.3 - Tester le script

Ouvre PowerShell en tant qu’administrateur, et lance :
```powershell
C:\Scripts\veeam_ftp_upload.ps1
```

### 4.4 - Créer une tache pour automatiser l'envoie des sauvegardes vers le serveur FTP   

- Ouvrir le Planificateur de tâches (Task Scheduler)  
- Dans le panneau de droite, cliquer sur Create Task  

- Dans l'onglet “General”  
Name : SauvegardeVeeamVersFtp  
Cocher : Run whether user is logged on or not (Exécuter que l'utilisateur soit connecté ou non) et Run with highest privileges (Exécuter avec les privilèges les plus élevés) si le script nécessite des droits admin.  

- Dans l'onglet “Triggers” cliquer sur New et définir :  
Begin the task : On a schedule  
Settings : Daily  
Start : mettre la date de départ  
Start time : mettre 23:30:00  
Recur every : 1 day  
-> Cliquer sur OK  

- Dans l'onglet “Actions” cliquer sur New et définir :  
Action : Start a program  
Program/script : parcours pour sélectionner le script  
-> Cliquer sur OK  
 
 - Dans l'onglet “Conditions”  
Tout décocher  

- Dans l'onglet “Settings”  
Cocher : Allow task to be run on demand et Run task as soon as possible after a scheduled start is missed  

- Valider et entrer un mot de passe  


