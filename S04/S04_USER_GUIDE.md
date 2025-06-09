# 🛠️ Guide Utilisateur – Sprint 4 : Installation & Configuration

## 1. Introduction

Ce document reprend les instructions pour :   
- La création et configuration de Pfsense : mise en place de regles de pare feu, gestion des routes inter-vlan, gestion de carte vmbr pour la DMZ, déclaration des pools  
- Gestion de télémétrie via GPO    
- Proxmox Simulation de switch par tag VLan, utilisation de sous réseaux de carte bridge  
- Amélioration de proxmox
- Configuration DHCP Relay  

## 2. Server pfsense

### 2.1 Configuration et installation  
- Créer une VM dans Proxmox 
- ISO : Debian12.iso
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.4 / masque : 255.255.255.224) 

### 2.2 Mise en place de règles de pare feu   
A venir 

### 2.3 Gestion des routes inter-vlan  
A venir  

### 2.4 Gestion carte vmbr pour la DMZ  
A venir  

### 2.5 Déclaration des pools   
A venir  


## 3 Gestion de la télémétrie via GPO  

1. Télécharger les fichiers ADMX de Windows  

- Aller sur le site microsoft et télécharger :  ADMX Windows 10/11 - Microsoft Download Center  
- Exécute le fichier  
Cela va extraire tous les fichiers ADMX dans ce dossier :  
C:\Program Files (x86)\Microsoft Group Policy\Windows 11 October 2023 Update (ou équivalent)\PolicyDefinitions\  
- Copier les fichiers + dossier langue dans le dossier Sysvol du domaine  
\\<ton-domaine>\SYSVOL\<ton-domaine>\Policies\PolicyDefinitions\  

2. Configurer la stratégie “Allow Telemetry”  

- Premiere configuration :  
Computer Configuration  
└── Administrative Templates  
    └── Windows Components  
        └── Data Collection and Preview Builds  
            └── Allow Telemetry (ou Allow Diagnostic Data)  
Mettre Enabled et Send optionnal diagnostic data  

- Deuxieme configuration :  
Computer Configuration  
└── Administrative Templates  
    └── Windows Components  
        └── Application Compatibility  
            └── Turn Off application Telemetry  
Mettre Enabled  

- Lier la GPO au domaine  
            
3. Vérification de l’application de la GPO   

- Sur un poste client, faire   
``` powershell  
gpupdate /force  
```

- Dans la barre de recherche, cherche et ouvre : regedit  

- Dérouler les dossiers : HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection  

- Vérifie que la clé suivante existe :  
Nom : AllowTelemetry  
Type : REG_DWORD  
Valeur : 1, 2 ou 3 selon ce que tu as configuré  

## 3. Proxmox  

### 3.1 Simulation de switch par tag VLan  
A venir  

### 3.2 Utilisation de sous réseaux de carte bridge  
A venir  

## 4. Configuration DHCP Relais (au niveau routeur) 
A venir  
