# 🛠️ Guide Utilisateur – Sprint 1 : Installation & Configuration

## 1. Introduction

Dans ce guide vous trouverez :   
**Un plan schématique du futur réseau**  

**Un plan d'adressage réseau complet cohérent**  

**Liste temporaire des :**  
serveurs nécessaires à l'élaboration de la future infrastructure réseau  
matériels nécessaires à l'élaboration de la future infrastructure réseau  

**Une nomenclature de nom :**  
serveur, ordinateur, utilisateurs et groupes  

**Configuration pour les créations de VM**  
serveur: config, OS et fonctions/roles  
client : config, OS et fonctions/roles  

**Configuration des cartes réseaux vmbr**  

**Mise en place squelette des livrables**  
Install
Readme

## 2. Création des VMs  

### 2.1 Serveur Windows Server 2022  

- Dans Proxmox : `Créer une VM`  
ISO : Windows Server 2022  
Ressources : 2 vCPU, 2 Go RAM, 40 Go disque  
Réseau : bridge (`vmbr0`)  
- Procéder à l'installation de la VM  
- Clique droit sur la VM -> convenir en template   

### 2.2 Clients Windows 10  

- Dans Proxmox : `Créer une VM`  
ISO : Win10.iso
Ressources : 8 vCPU, 4 Go RAM, 40 Go disque  
Réseau : bridge (`vmbr0`)  
- Procéder à l'installation de la VM  
- Clique droit sur la VM -> convenir en template

### 2.3 Serveur Debian 12  

- Dans Proxmox : `Créer une VM`  
ISO : Debian12.iso  
Ressources : 4 vCPU, 4 Go RAM, 40 Go disque  
Réseau : bridge (`vmbr0`)  
- Procéder à l'installation de la VM  
- Clique droit sur la VM -> convenir en template   

### 2.4 Clients Ubuntu  

- Dans Proxmox : `Créer une VM`  
ISO : Ubuntu22-04.iso
Ressources : 4 vCPU, 4 Go RAM, 40 Go disque  
Réseau : bridge (`vmbr0`)  
- Procéder à l'installation de la VM  
- Clique droit sur la VM -> convenir en template   

  
## 3. Configuration cartes réseaux  

### 3.1 vmbr0 (accès au WAN)  

- Dans proxmox, selectionner la VM  
Cliquer sur hardware -> Add -> Network -> vmbr1 -> Intel  

- Allumer la VM  
Modifier les configurations de la carte de cette façon :
Adresse : 192.168.240.XX (XX : deux derniers chiffres de l'ID de la VM dans proxmox)  
Masque : 255.255.255.0  
Gateway : 192.168.240.1

### 3.2 vmbr1 (accès au LAN)  

- Dans proxmox, selectionner la VM  
Cliquer sur hardware -> Add -> Network -> vmbr2 -> Intel  

- Allumer la VM  
Modifier les configurations de la carte de cette façon :
Adresse : 172.16.20.XX (XX : en fonction du plan d'adressage)  
Masque : 255.255.224.0  
DNS : 172.16.20.1 (adresse du serveur AD principal)  

---

## 4. FAQ

### Q : Comment tester la connexion réseau ?

ping 192.168.10.1
