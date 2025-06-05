# 🛠️ Guide Utilisateur – Sprint 3 : Installation & Configuration

## 1. Introduction

Ce document reprend les instructions pour :   
- la mise en place des GPO de sécurité et les GPO standards   
- Installation du server GLPI  
- Configuration GLPI (Synchronisation de l'AD et l'inclusion des objets AD)   
- Installation de l'agent GLPI sur chaque ordinateur du domaine (via script ou GPO)  pour la gestion de l'inventaire  
- Server Pfsense (TBC) 


## 2. Création des VMs

### 2.1 PC Administration (Windows 11) 

Installation de OpenSSH Client (et server optionnel) 

### 2.2 Server GLPI 

#### 2.2.1 Installation Server GLPI 
- Créer une VM dans Proxmox 
- ISO : debian12.iso
- Ressources :  2 CPU, 2 Go RAM, 30 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.5 / masque : 255.255.255.224) 

#### 2.2.2 Synchronisation GLPI et AD avec ldap

##### 2.2.2.1 Installation des outils LDAP sur le serveur GLPI 
``` bash
sudo apt update  
sudo apt install ldap-utils -y  
```
- Tester la connexion LDAP  
``` bash
ldapsearch -x \  
  -H ldap://172.16.20.1 \  
  -D "CN=glpi-ldap,OU=OU_AdminSystm,OU=OU_DSI,OU=OU_Users,DC=pharmgreen,DC=local" \  
  -W \   
  -b "DC=pharmgreen,DC=local"  
```

##### 2.2.2.2 Configuration de l'annuaire LDAP dans GLPI  
Aller dans Configuration -> Authentification -> Annuaire LDAP -> Ajouter un nouvel annuaire ou modifier celui existant 

Renseigner les champs :  
Nom	: Active Directory  
Serveur par défaut : oui  
Serveur	: 172.16.20.1  
Actif	: oui  
Port	: 389  
Base DN	: DC=pharmgreen,DC=local  
Filtre de connexion :	(&(objectClass=user)(sAMAccountName=%u))  
Utiliser un bind ? : oui  
DN du compte :	CN=glpi-sync,CN=Users,DC=pharmgreen,DC=local (ou OU personnalisé)  
Mot de passe du compte	: (mot de passe du compte glpi-ldap)  
Champ identifiant	: sAMAccountName  
Champs de synchronisation :	cn,mail,displayName  

Cliquer sur "Tester"  
Si le test echoue : vérifier le DN du compte avec la commande  
``` powershell  
Get-ADUser glpi_ldap | Select DistinguishedName  
```

##### 2.2.2.3 Importer les utilisateurs AD dans GLPI   
- Ouvrir l'interface web de GLPI  

Aller dans Administration -> Utilisateurs  
Cliquer sur "Depuis une source externe"  

A reprendre  

#### 2.2.3 Inclusion des Objects AD (utilisateurs, groupes, ordinateurs) 
x

### 2.3 Server GLPI Redondance 

- Créer une VM dans Proxmox 
- ISO : debian12.iso
- Ressources :  2 CPU, 2 Go RAM, 30 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.6 / masque : 255.255.255.224) 


### 2.4 Server pfsense ?? TBC  

- Créer une VM dans Proxmox 
- ISO : Debian12.iso
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.4 / masque : 255.255.255.224) 


## 3. Mise en place des GPO

Pour la mise en place des GPOs, dans Server Manager -> Tools -> Group Policy Management
Dérouler : Forest:pharmgreen.local / Domains / pharmgreen.local / Group Policy Object
- Clique droit sur GPO -> New  
Paramétrer les configuration suivantes : 

### 3.1 GPO de sécurité 

#### 3.1.1 Gestion du pare-feu

Name : User_Manage_Firewall_Deny 
Dérouler : User Configuration -> Policies -> Administrative Template -> Network -> Network Connection
- Prohibit adding and removing components for a LAN or remote access connecion - Enabled   
- Prohibit access to the Advanced Settings item on the Advanced menu -> Enabled 
- Prohibit TCP/IP adanced configuration -> Enabled 
- Prohibit Enabling/Disabling component of a LAN connection -> Enabled
- Prohibit deletion of remote access connnections -> Enabled
- Prohibit access to the remote access preferences item on the Advanced menu -> Enabled
- Prohibit access to proprieties of components of a LAN connection -> Enabled
- Prohibit access to properties of a LAN connecion -> Enabled
- Prohibit access to the New Connection Wizard -> Enabled
- Prohibit access to properties of components of a remote access connection -> Enabled
- Prohibit connecting and disconnecting a remote access connection -> Enabled
- Prohibit changing properties of a private remote access connection -> Enabled
- Prohibit renaming private remote access connections -> Enabled
- Prohibit viewing if status for an active connection -> Enabled
Lier cette GPO au domain.

Name : User_Manage_Firewall_Allow 
Dérouler : User Configuration -> Policies -> Administrative Template -> Network -> Network Connection
- Prohibit adding and removing components for a LAN or remote access connecion - Disabled   
- Prohibit access to the Advanced Settings item on the Advanced menu -> Disabled 
- Prohibit TCP/IP adanced configuration -> Disabled 
- Prohibit Enabling/Disabling component of a LAN connection -> Disabled
- Prohibit deletion of remote access connnections -> Disabled
- Prohibit access to the remote access preferences item on the Advanced menu -> Disabled
- Prohibit access to proprieties of components of a LAN connection -> Disabled
- Prohibit access to properties of a LAN connecion -> Disabled
- Prohibit access to the New Connection Wizard -> Disabled
- Prohibit access to properties of components of a remote access connection -> Disabled
- Prohibit connecting and disconnecting a remote access connection -> Disabled
- Prohibit changing properties of a private remote access connection -> Disabled
- Prohibit renaming private remote access connections -> Disabled
- Prohibit viewing if status for an active connection -> Disabled
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce

#### 3.1.2 Ecran de veille en sortie  

Name : User_Manage_SleepDelay_5min
Dérouler : User Configuration -> Policies -> Administrative Template -> Controle Panel -> 
Personalization 
- Enable screen saver -> Enable 
- Screen save executable name -> Value 300 -> Enable
- Password Protect the screen saver -> Enable
Lier cette GPO au domain.

Name : User_Manage_SleepDelay_None
Dérouler : User Configuration -> Policies -> Administrative Template -> Controle Panel -> 
Personalization 
- Enable screen saver -> Disable
- - Screen save executable name -> Value 300 -> Disable
- Password Protect the screen saver -> Disable
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce


#### 3.1.3 Blocage panneau de configuration 

Name : User_ControlPanelAccess_Deny
Dérouler : User Configuration -> Policies -> Administrative Template -> Control Panel
- Prohibit access to Control Panel and PC settings -> Enabled
Lier cette GPO au domain.

Name : User_ControlPanelAccess_Allow
Dérouler : User Configuration -> Policies -> Administrative Template -> Control Panel
- Prohibit access to Control Panel and PC settings -> Disabled
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce


#### 3.1.4 Verrouillage de compte  

Name : Computer_Manage_BlockAccount_3times/10min
Dérouler : Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies -> Account Lockout Policy
- Account lockout threshold : 3 tentatives
- Account lockout duration : 10 min
- Reset account lockout counter after : 10 min
Lier cette GPO au domain.

Name : Computer_Manage_BlockAccount_None
Dérouler : Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies -> Account Lockout Policy
- Account lockout threshold : 0 tentatives
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce


#### 3.1.5 Restriction installation
totale 


### 3.2 Mise en place des GPO standard  

#### 3.2.1 Fond d'écran
file dans dossier partagé + deploiement sur tout les postes 
#### 3.2.2 Gestion Alimentation 
en économie d energie 
#### 3.2.3 Déploiement logiciel 
en publication 
#### 3.2.4 Redirection de dossier 
activée pour tt les utilisateurs dans server fichier 
#### 3.2.5 Gestion des paramètres du navigateurs 
definir page d'accueil 
forcer un moteur de recherche (google) 
bloquer extensions non autorisé 

