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

### 2.3 Mettre en place un RAID 1 sur AD1  

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


### 2.4 Gestion des droits des dossiers partagés  
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

L'utilité principal de ce serveur sera la sauvegarde via la solution Veeam. Nous allons également installer et configurer AD DS et DNS afin d'avoir un poste supplémentaire pour la gestion de l'AD (étant donnée que nous sommes 4 à travailler sur le projet, cette mise en place nous permettra de gagner en productivité)  

### 8.1. Configuration de la VM  

- Clone du template "Windows Serveur 22 GUI"  
- Ajout d'un second disque dur de 200Go  

### 8.2 Installation  
- Installation AD et DNS. Ajout de la machine dans le domaine. Promotion en tant que DC du domaine (cf. installation Readme semaine 2)   
- Téléchargement de "Veeam Backup & replication CE" et "VeeamAgentWindows" via le site officiel : [https://www.veeam.com/fr/products/free/backup-recovery.html](https://www.veeam.com/fr/virtual-machine-backup-solution-free.html)   
- Monter l’ISO téléchargé puis double-cliquer sur Setup.exe
- Cliquer sur "Veeam Backup & Replication".
- Accepter la licence et continuer  
- Laisser la sélection par défaut (tous cochés)
  
Veeam installe automatiquement les composants manquants  
- Attendre la fin de l’installation des dépendances, puis cliquer "Next".  
- Laisser les paramètres par défaut ou configurer les chemins selon vos préférences.

### 8.3 Préparation du 2nd disque dur pour la sauvegarde 
    Ouvre diskmgmt.msc (Gestion des disques)
    Clic droit sur le disque → Initialiser le disque en GPT.
    Clic droit sur l’espace non alloué → Nouveau volume simple.
    Attribue une lettre de lecteur (ex: E:).
    Choisis le système de fichiers NTFS
    
### 8.4 Ajouter un dépôt de sauvegarde
    Ouvrir la console Veeam.
    Aller dans Backup Infrastructure > Backup Repositories.
    Ajouter un nouveau dépôt local ou distant : Direct Attached Storage -> Microsoft Windows 
    Dans Name : Donner un nom au nouveau repository 
    Dans Server : s'assurer que le repository server soit le serveur dans lequel vous venez d'installer Veeam puis Next 
    Dans Repository : sélectionner le 2nd disque initialisé et formaté à l'étape précédente -> Populate
    Next / Apply jusqu'à la fin 

### 8.5. Ajouter les machines Windows dans Veeam (en tant que machine physique)

    Ouvre la console Veeam Backup & Replication.
    Va dans : Inventory > Physical Infrastructure -> Srv-Windows 
    En haut à gauche : Edit Group 
    Dans Name : Laisser le nom
    Dans Computeur : ajouter l'adresse IP de la machine Windows à sauvegarder 
    Dans option : definir la récurrence de la sauvegarde, et cocher : Install backup agent 
    Next -> Finish 

### 8.6. Ajouter les machines Windows dans Veeam (en tant que machine physique)

    Ouvre la console Veeam Backup & Replication.
    Va dans : Inventory > Physical Infrastructure -> Srv-Linux 
    En haut à gauche : Edit Group 
    Dans Name : Laisser le nom
    Dans Computeur : ajouter l'adresse IP de la machine Linux à sauvegarder 
    Dans option : definir la récurrence de la sauvegarde, et cocher : Install backup agent 
    Next -> Finish 
    
### 8.6 Créer un Job de sauvegarde
    Va dans "Jobs" > "Backup Job" > "Windows/Linux computer".
    Dans Job Mode : Managed by backup server 
    Dans Name : donne un nom au job (par exemple Job-Srv-Veeam) 
    Dans Computers : clique sur Add et Ajoute la machine physique précédemment ajoutée.
    Dans Backup mode : Entire computer
    Dans Storage -> Backup Repository : Selectionner le disque E 
    Dans Schedule : définit le récurrence de la sauvegarde 
    Puis Apply -> Finish 

### 8.7 Sauvegarde  
   Dans Home -> Jobs -> Nom du backup -> Start 

### 8.8 Installation Veeam Agent Linux
Cette section est à réaliser seulement sur les machines Linux, Veeam Agent étant installé automatiquement sur les machines Windows  

- Télécharger la clé dans un fichier temporaire
cd /tmp 
https://repository.veeam.com/backup/linux/agent/dpkg/debian/public/pool/veeam/v/veeam-release-deb/veeam-release-deb_1.0.9_amd64.deb

- Installer Veeam 
sudo apt install ./veeam-release-deb_1.0.x_amd64.deb
sudo apt install veeam-release-deb
sudo apt update
sudo apt install -y veeam veeam-libs veeam-nosnap veeam-release-deb veeamsnap



- Configurer l’agent en ligne de commande
sudo veeam
Cela ouvre une interface en mode texte (TUI = Text-based User Interface), même sur une machine sans GUI.
Sélectionner "Managed by backup server"
Dans le menu :
    Choisis Managed by backup server
    Renseigne l’adresse IP de ton serveur Veeam (ex : 192.168.100.10)
    L’agent va s’enregistrer sur le serveur
