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

- Créer une VM dans Proxmox 
- ISO : Windows Server 2022
- Ressources : 2 vCPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (172.16.20.1 255.255.255.224) 
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
- Installation OpenSSH-Server
``` powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

- synchronisation des horloges : ouvrir powershell en administrateur 
``` powershell
w32tm /config /manualpeerlist:"ntp.obspm.fr,0x8" /syncfromflags:manual /reliable:YES /update
net stop w32time
net start w32time
w32tm /resync
``` 

### 2.1 Serveur Windows Server 2022 AD + DNS - Redondance 

- Clone de la machine Serveur Windows Server 2022 AD + DNS
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.2 / masque : 255.255.255.224) 
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
- Installation OpenSSH-Server
``` powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
- synchronisation des horloges : 
``` powershell
w32tm /config /syncfromflags:domhier /update
net stop w32time
net start w32time
w32tm /resync
```

### 2.2 Server Debian DHCP 

- Créer une VM dans Proxmox 
- ISO : Debian12.iso
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.3 / masque : 255.255.255.224) 

- Mise à jour et installation 
``` bash
sudo apt update
sudo apt install isc-dhcp-server
```

- Configuration de l'interface réseaux utilisée par DHCP 
``` bash
sudo nano /etc/default/isc-dhcp-server
```
Ajouter le contenu suivant selon le nom de l'interface 
``` bash
INTERFACESv4="enp0s19"
INTERFACESv6=""
```

- Configurer le fichier de configuration DHCP 
``` bash
sudo nano /etc/dhcp/dhcpd.conf
```
Ajouter ce contenu 
``` bash
# Configuration de base du serveur DHCP
option domain-name "example.com";
option domain-name-servers 172.16.20.1; # Remplacez par l'adresse IP de votre serveur DNS

default-lease-time 600;
max-lease-time 7200;

authoritative;

# Configuration du failover
failover peer "dhcp-failover" {
  primary; # Ce serveur est le serveur principal
  address 172.16.20.1; # Adresse IP du serveur principal
  port 647;
  peer address 172.16.20.2; # Adresse IP du serveur secondaire
  peer port 647;
  max-response-delay 60;
  max-unacked-updates 10;
  load balance max seconds 3;
  mclt 3600;
  split 128;
}

# Définition du sous-réseau
subnet 172.16.20.0 netmask 255.255.255.0 {
  range 172.16.20.32 172.16.20.223; # Plage d'adresses IP à distribuer
  option routers 172.16.20.1; # Remplacez par l'adresse IP de votre routeur
  option broadcast-address 172.16.20.255;
  pool {
    failover peer "dhcp-failover";
  }
}
```

- Redemarrer le service DHCP et vérifier qu'il fonctionne 
``` bash
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

- synchronisation des horloges : 
``` bash
sudo apt update
sudo apt install chrony
sudo systemctl enable --now chronyd
chronyc tracking
sudo chronyc makestep
```

### 2.3 Server Debian DHCP  - Redondance 

- Créer une VM dans Proxmox 
- ISO : Debian12.iso
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.4 / masque : 255.255.255.224) 

- Mise à jour et installation 
``` bash
sudo apt update
sudo apt install isc-dhcp-server
```

- Configuration de l'interface réseaux utilisée par DHCP 
``` bash
sudo nano /etc/default/isc-dhcp-server
```
Ajouter le contenu suivant selon le nom de l'interface 
``` bash
INTERFACESv4="enp0s19"
INTERFACESv6=""
```

- Configurer le fichier de configuration DHCP 
``` bash
sudo nano /etc/dhcp/dhcpd.conf
```
Ajouter ce contenu 
``` bash
# Configuration de base du serveur DHCP
option domain-name "example.com";
option domain-name-servers 172.16.20.1; # Remplacez par l'adresse IP de votre serveur DNS

default-lease-time 600;
max-lease-time 7200;

authoritative;

# Configuration du failover
failover peer "dhcp-failover" {
  secondary; # Ce serveur est le serveur secondaire
  address 172.16.20.2; # Adresse IP du serveur secondaire
  port 647;
  peer address 172.16.20.1; # Adresse IP du serveur principal
  peer port 647;
  max-response-delay 60;
  max-unacked-updates 10;
  load balance max seconds 3;
}

# Définition du sous-réseau
subnet 172.16.20.0 netmask 255.255.255.0 {
  range 172.16.20.32 172.16.20.223; # Plage d'adresses IP à distribuer
  option routers 172.16.20.1; # Remplacez par l'adresse IP de votre routeur
  option broadcast-address 172.16.20.255;
  pool {
    failover peer "dhcp-failover";
  }
}
```

- Redemarrer le service DHCP et vérifier qu'il fonctionne 
``` bash
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

- Synchroniser les horloges 
``` bash
sudo apt update
sudo apt install chrony
sudo systemctl enable --now chronyd
chronyc tracking
sudo chronyc makestep
```

### 2.4 PC Administration (Windows 11)
Pas de configuration pour le moment du à un problème technique sur proxmox 

### 2.5 Server GLPI
Configuration en cours 

## 3. Création des scripts

### 3.1 Formatage fichier CSV
Cf. fichier : FormatageCSV.ps1
Fichier formaté : s01_Pharmgreen.csv

### 3.2 Création des OU 
Cf. fichier : creer\_OU_structure.ps1 

### 3.3 Création des utilisateurs 
Cf. fichier : adduser.ps1

### 3.4 Création des groupes Windows  
 En cours de développement
  
  
## 4. Arborescence AD 
PharmGreen.local  
_____Interne   
_______________CommunicationRelationsPubliques  
_________________________CommunicationInterne	 
_________________________RelationsMedias  
_________________________GestionDesMarques  
									
_______________DepartementJuridique  
_________________________DroitsSociétés  
_________________________ProtectionDonnéesConformité  
_________________________PropriétéIntellectuelles  
									
_______________DeveloppementLogiciels  
_________________________AnalyseConception  
_________________________Developpement  
									
_______________OU.Direction  
_________________________User1  

_______________OU.DSI	 
_________________________OU.AdminSystRes  
_________________________OU.DevIntegration  
_________________________OU.Exploitation  
_________________________OU.Support  
_________________________Directeur  
			
_______________OU.FinanceCompta  
_________________________OU.Finance	  
_________________________OU.Fiscalité  
_________________________OU.Compta  
			
_______________OU.QHSE	  
_________________________OU.ControleQualité  
_________________________OU.Certification  
_________________________OU.GestionEnvironnementale	  
			
_______________OU.ServiceCommercial  
_________________________OU.ADV  
_________________________OU.B2B	  
_________________________OU.ServiceAchat	  
_________________________OU.ServiceClient	  
_________________________Directeur  
			
_______________OU.Recrutement  
_________________________OU.AgentRH  
_________________________OU.ResponsableRecrutement	  
									
_____PrestatairesExterne  
_______________OU.Imagine  
_______________OU.StudioDlight	  
_______________OU.Livingston&Associés  
_______________OU.2Face  
									
_____Utilisateurs  

## 5. Groupes Windows 



