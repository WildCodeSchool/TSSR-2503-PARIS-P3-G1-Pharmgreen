# 🛠️ Guide Utilisateur – Sprint 2 : Installation & Configuration

## 1. Introduction

Ce document inclut la procédure à suivre afin de créer les servers.  Ces machines ont été configuré depuis des Templates installés au préalable 
- AD + DNS (Windows Server 22 GUI)
- AD + DNS Redondance  (Windows Server 22 GUI)
- DHCP (Debian CLI) 
- DHCP - Redondance (Debian CLI) 
- GLPI 
- PC administration (Windows 11 GUI) 

## 2. Création des VMs

### 2.1 Serveur Windows Server 2022 AD + DNS

- Dans Proxmox : `Créer une VM`
- ISO : Windows Server 2022
- Ressources : 2 vCPU, 2 Go RAM, 40 Go disque
- Réseau : bridge (`vmbr`)
- Installation des roles AD et DNS 
``` powershell 
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools
Install-ADDSForest `
  -DomainName "pharmgreen.local" `
  -DomainNetbiosName "PHARMGREEN" `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "Mot de passe DSRM") `
  -InstallDNS:$true `
  -Force
```

### 2.1 Serveur Windows Server 2022 AD + DNS - Redondance 

- Clone de la machine Serveur Windows Server 2022 AD + DNS
- Changement du SID de la nouvelle machine  
``` powershell 
C:\Windows\System32\Sysprep\Sysprep.exe
```
Aller dans Generalize -> Shutdown -> Enter System Out-of-Box Experience (OOBE) 
- Promouvoir ce server en DC  complémentaire 
``` powershell 
Import-Module ADDSDeployment
Install-ADDSDomainController `
  -DomainName "pharmgreen.local" `
  -Credential (Get-Credential) `
  -InstallDNS:$true `
  -SiteName "Default-First-Site-Name" `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "Mot de passe DSRM") `
  -Force
```

### 2.2 Server Debian DHCP 
### 2.3 Server Debian DHCP  - Redondance 
### 2.4 PC Administration (Windows 11)
### 2.5 Server GLPI

## 3. Création des scripts 
### 3.1 Création des OU 
### 3.2 Création des utilisateurs 
### 3.3 Création des groupes Windows  
  
  

## 4. Arborescence AD 

## 5. Groupes Windows 



