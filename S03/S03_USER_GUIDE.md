# 🛠️ Guide Utilisateur – Sprint 3 : Installation & Configuration

## 1. Introduction

Ce document inclut la procédure à suivre afin de créer les servers.  Ces machines ont été configuré depuis des Templates installés au préalable 

- PC administration (Windows 11 GUI)  + installation logiciels nécessaire
- Server GLPI 
- Server GLPI Redondance
- Server Pfsense (TBC) 


## 2. Création des VMs


### 2.1 PC Administration (Windows 11) 
Pas de configuration pour le moment du à un problème technique sur proxmox 


### 2.2 Server GLPI 

#### 2.2.1 Installation GLPI 
- Créer une VM dans Proxmox 
- ISO : debian12.iso
- Ressources :  2 CPU, 2 Go RAM, 30 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.5 / masque : 255.255.255.224) 

#### 2.2.2 Synchronisation GLPI et AD 
x
#### 2.2.3 Synchronisation GLPI et AD 
Gestion de parc : Inclusion des objets AD (utilisateurs, groupes, ordinateurs)

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

cp-server


## 3. Mise en place des GPO de sécurité 

### 3.1 Gestion du pare-feu
activation pare-feu tous profils (domaine, privé et public) 
### 3.2 Ecran de veille en sortie  
Au bout de 5min 
exiger mot de passe à la sortie de veille
### 3.3 Blocage panneau de configuration 
Complet pour les utilisateurs standards 
### 3.4 Verrouillage de compte  
 Blocage après 3 erreurs pendant 15 min 
### 3.5 Restriction installation
totale 


## 4. Mise en place des GPO standard  

### 4.1 Fond d'écran
file dans dossier partagé + deploiement sur tout les postes 
### 4.2 Gestion Alimentation 
en économie d energie 
### 4.3 Déploiement logiciel 
en publication 
### 4.4 Redirection de dossier 
activée pour tt les utilisateurs dans server fichier 
### 4.5 Gestion des paramètres du navigateurs 
definir page d'accueil 
forcer un moteur de recherche (google) 
bloquer extensions non autorisé 

