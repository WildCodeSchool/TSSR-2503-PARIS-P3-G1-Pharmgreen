# 🛠️ Guide Utilisateur – Sprint 5 : Installation & Configuration  

## 1. Introduction  
Voici le contenu de ce Readme :  

**Stockage avancé**   
- Mise en place des dossiers partagés  
- Mappage des lecteurs sur des clients  
I pour dossier individuel  
J pour dossier de service  
K pour dossier de departement
- Mettre en place un RAID 1 sur AD1
- Mettre en place un serveur de sauvegarde
- Gestion des droits des dossiers partagés

**GPO**  
- Restriction d'utilisation pour les utilisateurs
du lundi au samedi de 7h30 a 20h autorisé
- Aucune restriction d'utilisation pour les administrateurs

**Optimisation du projet**  
- Mise à jour des Readme
- Mettre en place des clones mirpoirs des VM en high priority
A savoir : Pfsense, chaque serveur AD et Vyos si déjà installé. 

**Additionnel : mise en place d'un DHCP relay sur Pfsense**  

**Additionnel : autoriser un groupe d'utilisateurs à se connecter sur un serveur (AD par exemple), à créer des GPO et à les gérer**

**Additionnel : utiliser les filtres WMI sur les GPO**  

**Mise en place d'un serveur de sauvegarde avec Veeam**

  
## 2. Stockage avancé    

### 2.1 Mise en place des dossiers partagés (serveur partage de fichier FTP-vsftpd)  
 
### Objectif

Installer et configurer un serveur FTP (vsftpd) pour permettre aux utilisateurs de partager et d’échanger des fichiers via FTP.

### Étapes détaillées  

**1. Installation de vsftpd**  
sudo apt update
sudo apt install vsftpd -y

**2. Création de l’utilisateur FTP dédié**

sudo adduser ftpuser
Définir un mot de passe sécurisé.

Cet utilisateur sera utilisé pour se connecter au serveur FTP.

**3. Configuration du répertoire FTP**  
Création de la structure des dossiers pour le partage :

sudo mkdir -p /home/ftpuser/uploads/docs  
sudo mkdir -p /home/ftpuser/uploads/projets  
sudo mkdir -p /home/ftpuser/uploads/depots  
Attribution des droits :  

sudo chown -R ftpuser:ftpuser /home/ftpuser/uploads
sudo chmod -R 775 /home/ftpuser/uploads  
Pour des raisons de sécurité, le dossier personnel /home/ftpuser doit être non modifiable :  

sudo chmod a-w /home/ftpuser

**4. Configuration de vsftpd**  
Modifier le fichier /etc/vsftpd.conf avec les options suivantes (ajouter ou modifier) :

write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
local_umask=022
listen=YES
listen_ipv6=NO  
Ces options permettent :

L’écriture dans le dossier FTP,

Le confinement de l’utilisateur dans son répertoire personnel (chroot),

De contourner l’erreur liée à un dossier personnel inscriptible,

L’écoute du service FTP sur IPv4 uniquement.

**5. Redémarrage du service FTP**

sudo systemctl restart vsftpd

**6. Test de connexion FTP**  
Utiliser un client FTP (FileZilla, Cyberduck, ou en ligne de commande) pour se connecter :

ftp <adresse_IP_du_serveur>
Se connecter avec le login ftpuser et son mot de passe.

Naviguer dans les dossiers /uploads et ses sous-dossiers.

Tester le téléchargement et l’envoi de fichiers.

**7. Configuration du pare-feu (si actif)**  
Autoriser les ports FTP nécessaires :

sudo ufw allow 20,21/tcp
sudo ufw allow 30000:31000/tcp  
Cela correspond au port de commande FTP (21), au port de données (20) et à la plage des ports passifs (30000-31000) si configurée.

### 2.2 Mappage des lecteurs sur des clients   
I pour dossier individuel  
J pour dossier de service   
K pour dossier de departement  

### 2.3 Mettre en place un RAID 10 sur AD1  

#### - Étape 1 – Ajouter deux disques à la VM dans Proxmox    
Aller dans l'interface web de Proxmox    
Sélectionne la VM : P3-G1-WinServ22-GUI-SRV-AD1-SchemaMaster    
Aller dans l'onglet Hardware -> Add -> Hard Disk    
Ajouter deux nouveaux disques de 50Go, dans "local-lvm", selectionne "Interface SCSI"    
Redémarrer la VM si nécessaire    

#### - Étape 2 – Configurer le RAID 1 dans Windows Server 2022    
Ouvrir le Gestionnaire de disques    
Windows détectera les nouveaux disques    
Initialiser les deux disques en GTP    
Convertir les deux disques en disque dynamique    
Clique droit sur l’un des deux disques → "Nouveau volume en miroir"    
Suivre l’assistant    
Ajouter le second disque comme miroir    
Attribuer une lettre de lecteur (ex. E:)    
Formater le disque en NTFS    
Attendre la fin du formatage    

#### - Vérification du RAID    
Dans le Gestionnaire de disques : les deux disques apparaissent comme "Volume en miroir"    
L'état doit être "OK"   


### 2.4 Mettre en place un serveur de sauvegarde  ( en cours )  
- PREREQUIS  
1 VM Windows Server core  
RAM 4096Go  
2 soquets 2 cores 
vmbr0 : 192.168.240.71/24  
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.240.71 -PrefixLength 24 -DefaultGateway 192.168.240.1  
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8  

vmbr2 : 172.16.20.20/27  
Storage : 1 PV  en LVM avec 3 LV  : home, root et swap 

- Changer le nom de la machine si nécessaire 
Rename-Computer -NewName "SRV-Sauvegarde" -Restart

-  Installation du rôle via PowerShell
Install-WindowsFeature Windows-Server-Backup
Get-WindowsFeature Windows-Server-Backup

### 2.5 Gestion des droits des dossiers partagés  
A venir  


## 3. GPO    

### 3.1 Restriction d'utilisation pour les utilisateurs  
du lundi au samedi de 7h30 a 20h autorisé  

### 3.2 Aucune restriction d'utilisation pour les administrateurs  
A venir  


## 4. Optimisation du projet    

### 4.1 Mise à jour des Readme  
Ok

### 4.2 Mettre en place des clones miroirs des VM en high priority  
Eteindre les VM  
Clique droit -> Clone -> Full clone  
Ajouter le nom, l'ID et les emplacements dans les disques  

Manipulation à faire pour chaque serveur AD et pour Pfsense   


## 5. Mise en place d'un DHCP relay sur Pfsense  

### 5.1. Désactiver le serveur DHCP intégré sur pfSense  
Depuis l'interface graphique aller dans :  
Services -> DHCP Server -> LAN -> décocher "Enable DHCP server on LAN interface" -> Save  

### 5.2. Activer le DHCP Relay  
Toujours dans l'interface graphique aller dans :  
Services > DHCP Relay -> Cocher "Enable DHCP Relay on Interface"  
Dans Interfaces, sélectionner l’interface sur laquelle pfSense recevra les requêtes DHCP : LAN  
Dans Destination Server, indiquer l’adresse IP du serveur DHCP  
Cliquer sur Save, puis Apply Changes

### 5.3. Regle Pfsense
Ne pas oiblier d'ajouter une règle sur Pfsense pour ouvrir les ports 67 et 68 entre le pfsense et le serveur DHCP. 


## 6. Additionnel : autoriser un groupe d'utilisateurs à se connecter sur un serveur (AD par exemple), à créer des GPO et à les gérer
      
### 6.1. Pour autoriser à se connecter sur le serveur Active Directory   
Sur le serveur en question :    
- Ouvrir secpol.msc    
- Déployer : Local Policies -> User Rights Assignment   
- Modifier : Allow log on locally   
- Cliquer sur Add User or Group, et ajouter l’utilisateur ou le groupe (dans notre cas le groupe GPO_Utilisateurs qui contient les utilisateurs Pauline, Priscilla, Omar et Mohamed)  

### 6.2. Pour autoriser à créer et gérer les GPO   
Sur le serveur AD, ouvrir dsa.mcs  
Déployer Pharmgreen.local -> Users  
Dans Group Policy Creator Owners, aller dans Membre, et ajouter le groupe de sécurité (GPO_Admin) ou les membres un à un.   

### 6.3. Pour autoriser à lier une GPO à une OU : 
Toujours dans dsa.mcs, clique droit sur l'OU cible (ou le domaine) -> "Delegage controle" → ajouter l’utilisateur → lui accorder les permissions de gérer les stratégies de groupe.  
      

## 7.0. Additionnel : utiliser les filtres WMI sur les GPO  

 Objectif : retirer les Domain Controller de la GPO "COMPUTER_Manage_SleepDelay_5min"  
 en utilisant les filtre WMI (filtre en fonction du matériel)  

 - Ouvrir gpmc.msc  
 - Dans l'arborescence à gauche, clique droit sur "Filtres WMI" → Nouveau  
 - Donner un nom et descriptif  
 - Cliquer sur Ajouter, puis entrer cette requête :  
SELECT * FROM Win32_OperatingSystem WHERE ProductType = "2"  
(pour info : 1 = poste client / 2 = Controleur de domaine / 3 = Serveur membre)  
- Revenir sur la GPO "COMPUTER_Manage_SleepDelay_5min" et clique droit  
- Aller dans "Filtre WMI" et ajouter le groupe créée précédement.


## 8.0. Mise en place d'un serveur de sauvegarde avec Veeam  

L'utilité principal de ce serveur sera la sauvegarde via la solution Veeam. Nous allons également installer et configurer AD DS et DNS afin d'avoir un poste supplémentaire pour la gestion de l'AD (étant donnée que nous sommes 4 à travailler sur le projet, cette mise en place nous permettra de gagner en productiviité)  

### 8.1. Installation  
- Clone du template "Windows Serveur 22 GUI"    
- Installation AD et DNS. Ajout de la machine dans le domaine. Promotion en tant que DC du domaine (cf. installation Readme semaine 2)   
- Téléchargement de "Veeam Backup & replication CE" et "VeeamAgentWindows" via le site officiel : https://www.veeam.com/fr/products/free/backup-recovery.html  
- Monter l’ISO téléchargé puis double-cliquer sur Setup.exe
- Cliquer sur "Veeam Backup & Replication".
- Accepter la licence et continuer  
- Laisser la sélection par défaut (tous cochés)  
Veeam installe automatiquement les composants manquants  
- Attendre la fin de l’installation des dépendances, puis cliquer "Next".  
- Laisser les paramètres par défaut ou configurer les chemins selon vos préférences.

### 8.2. Configuration  

- Ouvrir le menu Démarrer > Veeam Backup & Replication.


