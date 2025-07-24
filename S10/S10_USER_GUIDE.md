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
### 2.1 - Rappel architecture réseau   

#### 2.1.1 - Site A - Pharmgreen   
WAN pfSense	192.168.240.48/24   
LAN pfSense	192.168.1.0/24   
Tunnel VPN	10.0.8.1  

#### 2.1.2 - Site B - Ekoloclast
WAN pfSense	192.168.240.192   
LAN pfSense	192.168.200.1  
Tunnel VPN        10.0.8.2  

### 2.2 - Configuration du serveur VPN (Site A – pfSense)  

#### 2.2.1 - Création du serveur OpenVPN   
- Accéder à l’interface web de pfSense (Site A)  
- Aller dans VPN > OpenVPN > Servers et cliquez sur + Add  
- Paramètres à configurer :
	Server mode : Peer to Peer (Shared Key)  
	Protocol : UDP on IPv4 only  
	Device mode : tun   
	Interface : WAN  
	Local port : 1194   
	Description : VPN vers Site B   
	Shared Key : Automatically generate   
	Encryption Algorithm : AES-256-GCM   
	Auth digest algorithm : SHA256   
	IPv4 Tunnel Network : 10.0.8.1  
	IPv4 Remote Network : ??  
	
#### 2.2.2 - Récupération de la clé partagée  
Retourner dans la liste des serveurs, éditez celui créé.  
Copier l'intégralité de la clé dans la case Shared Key (-----BEGIN OpenVPN Static key V1-----)  
Transmettre la clef au Site B de façon sécurisée   


### 2.3 - Configuration du serveur VPN (Site B – pfSense)  

#### 2.3.1 - Création du client OpenVPN  
- Accéder à l’interface web de pfSense (Site B)   
- Aller  dans VPN > OpenVPN > Clients et cliquez sur + Add   
- Paramètres à configurer :  
	Server mode : Peer to Peer (Shared Key)  
	Protocol : UDP on IPv4 only  
	Device mode : tun  
	Interface : WAN  
	Server host or address : IP publique du Site A  
	Server port : 1194  
	Shared Key : Automatically generate → Coller la clé reçue  
	Encryption Algorithm : AES-256-GCM  
	Auth digest algorithm : SHA256  
	IPv4 Tunnel Network : 10.0.8.2  
	IPv4 Remote Network(s)	??  

### 2.4- Configuration des routes et du NAT  

#### 2.4.1 - Route statique sur pfSense/VyOS  
Sur le routeur VyOS, ajoutez une route vers le réseau distant (Site B) via l’IP de pfSense sur l’interface connectée à VyOS :  
set protocols static route 192.168.2.0/24 next-hop 10.0.0.1  
commit  
save  
    
#### 2.4.2 - NAT sur pfSense (Site A)    
- Aller dans Firewall > NAT > Outbound    
- Activer le mode Hybrid Outbound NAT    
- Créer une règle :    
	Interface : OpenVPN  
	Source : 10.0.0.0/24  

### 2.5 - Configuration des règles de pare-feu (sur les 2 PFsense)   
- Aller dans Firewall > Rules > OpenVPN   
- Cliquer sur + Add   
- Configurer :  
	Action	: Pass  
	Interface : OpenVPN  
	Protocol : Any  
	Source : Any  
	Destination : Any  
	Description : Autoriser tout trafic VPN  

### 2.6 -  Vérifications et tests  

#### 2.6.1 - Vérifier le statut du VPN   
Aller dans Status > OpenVPN sur les deux pfSense  
Le tunnel doit apparaître "up" (en vert)  

#### 2.6.2 - Test de connectivité  
Depuis un poste du réseau Site A (192.168.1.x), pinguez un hôte du réseau Site B (192.168.2.x)  
Si le ping fonctionne → VPN opérationnel   


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


