# 🛠️ Guide Utilisateur – Sprint 1 : Installation & Configuration

## 1. Introduction

Ce guide décrit la création des machines virtuelles Windows sous Proxmox, la configuration IP statique et l’usage des VLANs pour structurer le réseau de Pharmgreen.  

## 2. Création des VMs

### 2.1 Serveur Windows Server 2022

- Dans Proxmox : `Créer une VM`
- ISO : Windows Server 2022
- Ressources : 2 vCPU, 2 Go RAM, 40 Go disque
- Réseau : bridge (`vmbr`)

### 2.2 Clients Windows 10

- 1 VM par utilisateur 
- Réseau : bridge
  
## 3. Configuration Réseau

### 3.1 IP statique

- Ouvrir les paramètres IPv4 dans Windows
- Exemple :
  - IP : 172.16.20.0/24 
  - Masque : 255.255.255.224

### 3.2 VLANs dans Proxmox

- VM > Hardware > `Add > Network Device`
- Bridge : `vmbr0`
- VLAN Tag : `10`, `20`, etc.
- Affecter selon les services (ex: VLAN 10 = Commercial)

---

## 4. FAQ

### Q : Comment tester la connexion réseau ?

ping 192.168.10.1
