# 🛠️ Guide Utilisateur – Sprint 2 : Installation & Configuration  

## 1. Introduction  

Ce document inclut la procédure à suivre afin de créer les servers.  Ces machines ont été configuré depuis des Templates installés au préalable   
- AD + DNS (Windows Server 22 GUI)  
- AD + DNS Redondance  (Windows Server 22 GUI)  
- DHCP (Debian CLI)   
- DHCP - Redondance (Debian CLI)   
- GLPI   
- PC administration (Windows 10 GUI)   

## 2. Création des VMs  

### 2.1 Serveur Windows Server 2022 AD + DNS  

- Créer une VM dans Proxmox  
- ISO : Windows Server 2022  
- Ressources : 8 CPU (2 soquets/2 cores), 8 Go RAM, 40 Go disque
- Renommer la machine (par exemple P3-G1-WinServ22-GUI-SRV-AD1-SchemaMaster)
- Désactiver les firewall
- Desactiver l'écran de veille
- Network :   
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 )  
vmbr1 (172.16.20.1 255.255.255.224)  
- Installation des roles AD et DNS  
  Serveur Manager -> Roles -> Add new roles -> AD DS + DNS  
  Suivre l'installation jusqu'à la fin  
  Redémarrer l'ordinateur  
- Ajout de l'ordinateur au domaine 
- Ouvrir seetings -> System -> Rename Computeur -> Changer le nom de l'ordinateur ( P3-G1-WinServ22-GUI-SRV-AD1-SchemaMaster)  
Choisir Domaine, et entrer le nom du domaine (pharmgreen.local)  
Utilisation d'un compte administrateur (pharmgreen.local\Administrator) et du mot de passe correspondant
Redemarrage
- Ouvrir Serveur manager, et finaliser l'installation en choisisant "Ajouter un Domain Controlleur à un domaine existant"   
- Verifier si OpenSSH est installé  
``` powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```

- Installation OpenSSH-Server  
``` powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

- Verification présence fichiers OpenSSH  
``` powershell
Test-Path "C:\Windows\System32\OpenSSH\sshd.exe"
```

- Démarrer et activer le service sshd  
``` powershell
Start-Service sshd
Set-Service sshd -StartupType Automatic
```

- Ouverture du port 22  
``` powershell
New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server (sshd)" `
 -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

- Vérifief les fichiers et port  
``` powershell
Test-Path "C:\Windows\System32\OpenSSH\sshd.exe"
netstat -an | findstr :22
```

- synchronisation des horloges : ouvrir powershell en administrateur   
``` powershell
w32tm /config /manualpeerlist:"ntp.obspm.fr,0x8" /syncfromflags:manual /reliable:YES /update
net stop w32time
net start w32time
w32tm /resync
``` 

### 2.1 Serveur Windows Server 2022 AD + DNS - Redondance 

- Installer une machine Serveur Windows Server 2022  
- Renommer la machine (par exemple "SRV-AD2-RIDMaster"  
``` powershell
Rename-Computer -NewName "SRV-AD2-RIDMaster" -Restart  
```
-Desactiver veille automatique  
``` powershell
powercfg -change -standby-timeout-ac 0  
powercfg -change -standby-timeout-dc 0  
```
- Modifier l'adresse IP selon le modèle et les besoins :  
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 )    
vmbr1 (adresse ip : 172.16.20.2 / masque : 255.255.255.224 / DNS : "IP de SRV-AD1", "127.0.0.1"    

``` powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.20.2 -PrefixLenght 27  
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "172.16.20.1"  
```

- Installer AD/DNS et features   
``` powershell 
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools  
```

- Ajout de la machine dans le domaine  
``` powershell
Add-Computer -DomainName "pharmgreen.local" -Credential (Get-Credential) -Restart
```
Utiliser : Administrator et mot de passe pour autoriser l'ordinateur à joindre le domaine 

-Importer le module si nécessaire 
``` powershell 
Import-Module ActiveDirectory
```

- Synchroniser les horloges 
``` powershell
w32tm /config /syncfromflags:domhier /update
net stop w32time
net start w32time
w32tm /resync
```

Revenir sur AD1 (en GUI) 

- Dans "Server Manager" 
-> Manage -> Add Server   
Cliquer sur "Find now"
Selectionner et double clique sur le serveur AD à ajouter pour le mettre dans la partie "selected" à droite.   
Selectionner le serveur puis cliquer sur OK    

- Revenir dans "Server Manager"
Clique droit sur le drapeau rouge en haut 
-> Promote this server to a a domain controler -> a new DC in an existing domain 
Dans credential entrer le compte Administrator + mot de passe 
Entrer un DSRM password 
Replicate depuis un server AD 
Suivant jusqu'a la fin + installation 

- Vérifier en faisant depuis n'importe quel server :   
``` powershell
Get-ADDomainController -Filter * | Select-Object HostName  
```
Chaque DC du domaine devrait apparaitre. 

- Verifier si OpenSSH est installé   
``` powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'  
```

- Installation si nécessaire  
``` powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0  
```

- Verification présence fichiers OpenSSH  
``` powershell
Test-Path "C:\Windows\System32\OpenSSH\sshd.exe"
```

- Démarrer et activer le service sshd  
``` powershell
Start-Service sshd
Set-Service sshd -StartupType Automatic
```

- Ouverture du port 22   
``` powershell
New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server (sshd)" `
 -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

- Vérifief les fichiers et port  
``` powershell
Test-Path "C:\Windows\System32\OpenSSH\sshd.exe"
netstat -an | findstr :22
```


### 2.2 Server Debian DHCP  

- Créer une VM dans Proxmox   
- ISO : Debian12.iso  
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque  
- Network :   
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 )  
vmbr1 (adresse ip : 172.16.20.3 / masque : 255.255.255.224 / DNS 172.16.20.1)  

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
vmbr1 (adresse ip : 172.16.20.4 / masque : 255.255.255.224 / DNS 172.16.20.1)   

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

### 2.4 PC Administration (Windows 10)   
- Création d'une VM  
Image : Windows 10  

- Renommer l'ordinateur  
``` powershell
Rename-Computeur -NewName "PC-ADMIN-WIN10" -Restart  
```

( - Installer SSH.client )

- Ajout au domaine :
``` powershell
Add-Computer -DomainName "pharmgreen.local" -Credential "pharmgreen\Administrator" -Restart  
```  

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
En cours


