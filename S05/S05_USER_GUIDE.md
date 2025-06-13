# 🛠️ Guide Utilisateur – Sprint 5 : Installation & Configuration  

## 1. Introduction  
Voici le contenu de ce Readme :  

**Stockage avancé**   
- Mise en place des dossiers partagés  
- Mappage des lecteurs sur des clients  
I pour dossier individuel  
J pour dossier de service  
K pour dossier de departement
- Mettre en place un RAID 10 sur AD1
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

**Additionnel : autoriser un groupe d'utilisateurs à se connecter sur un serveur (AD par exemple), à créer des GPO et à les gérer**
  
## 2. Stockage avancé    

### 2.1 Mise en place des dossiers partagés  
### 2.2 Mappage des lecteurs sur des clients   
I pour dossier individuel  
J pour dossier de service   
K pour dossier de departement  
### 2.3 Mettre en place un RAID 10 sur AD1  

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

## 3. GPO    

### 3.1 Restriction d'utilisation pour les utilisateurs  
du lundi au samedi de 7h30 a 20h autorisé  
### 3.2 Aucune restriction d'utilisation pour les administrateurs  

## 4. Optimisation du projet    

### 4.1 Mise à jour des Readme  

### 4.2 Mettre en place des clones miroirs des VM en high priority  
Eteindre les VM  
Clique droit -> Clone -> Full clone  
Ajouter le nom, l'ID et les emplacements dans les disques  

Manipulation à faire pour chaque serveur AD et pour Pfsense   


## 4. Additionnel : autoriser un groupe d'utilisateurs à se connecter sur un serveur (AD par exemple), à créer des GPO et à les gérer
      
### 4.1. Pour autoriser à se connecter sur le serveur Active Directory   
Sur le serveur en question :    
- Ouvrir secpol.msc    
- Déployer : Local Policies -> User Rights Assignment   
- Modifier : Allow log on locally   
- Cliquer sur Add User or Group, et ajouter l’utilisateur ou le groupe (dans notre cas le groupe GPO_Utilisateurs qui contient les utilisateurs Pauline, Priscilla, Omar et Mohamed)  


### 4.2. Pour autoriser à créer et gérer les GPO   
Sur le serveur AD, ouvrir dsa.mcs  
Déployer Pharmgreen.local -> Users  
Dans Group Policy Creator Owners, aller dans Membre, et ajouter le groupe de sécurité (GPO_Admin) ou les membres un à un.   

### 4.3. Pour autoriser à lier une GPO à une OU : 
Toujours dans dsa.mcs, clique droit sur l'OU cible (ou le domaine) -> "Delegage controle" → ajouter l’utilisateur → lui accorder les permissions de gérer les stratégies de groupe.  
      
