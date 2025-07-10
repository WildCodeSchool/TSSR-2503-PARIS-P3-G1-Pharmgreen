
# 🛠️ Guide Utilisateur – Sprint 9 : Installation & Configuration    

## 1. Introduction    
Voici le contenu de ce Readme qui reprends essentiellement les configurations non terminées depuis le début du projet :  
( les configurations ont été ajoutés également dans les Readme de leurs sprints respectifs pour plus de lisibilité)  

**Reprise des anciens objectifs**  
Configuration PFsense (en integrant Vyos) - s07  
Hébergement de 2 sites : L'un accessible via le réseau interne et Le second accessible par tout le monde depuis l’extérieur - s08  

**SÉCURITÉ - Mettre en place un serveur bastion GUACAMOLE**  
En DMZ ou dans un vlan séparé  
Gestion des règles de pare-feu en conséquences  
Synchronisation des accès avec des groupes AD (opt.)  

**SÉCURITÉ - Mettre en place un serveur de gestion des mises à jour WSUS**  
Installation sur VM dédiée  
Liaison avec l'AD : Les groupes dans WSUS sont liés à l'AD / Les MAJ sont liées aux OU  
Gérer différemment les MAJ pour : Les client / Les serveurs / Les DC  

**VOIP - Mettre en place un serveur de téléphonie sur IP**  
Utilisation de la solution FreePBX  
Création de lignes VoIP  
Validation de communication téléphonique VoIP entre 2 clients / Utilisation du logiciel 3CX  

**SÉCURITÉ - Mettre en place un serveur de gestion de mot de passe**  
Installation sur VM déjà existante, ou CT dédié  
Connexion en web pour l'administration et l'utilisation de la solution  

## 2. Reprise des anciens objectifs   

### 2.1 Configuration PFsense (en integrant Vyos) - s07  
Depuis l'interface graphique, aller dans System -> Routing -> Static Routes  
Ajouter Destination réseau : 172.16.20.0/24 (ou plusieurs /27)  
Passerelle : 192.168.200.1  

#### 2.1.1 Ajout d'une règle d’autorisation sur l’interface vmbr6 "LAN vers VyOS" :  
Aller dans : Firewall -> Rules -> vmbr6/LAN  
    Action : Pass  
    Source : 172.16.20.0/24  
    Destination : any  
    Protocol : any  

#### 2.1.2 Ajout d'une règle d’autorisation : any -> This firewall - ICMP  
Aller dans : Firewall -> Rules -> vmbr6/LAN  
    Action : Pass  
    Interface : LAN  
    Protocol : ICMP  
    Source : 192.168.200.0/24  
    Destination : This Firewall  
    
### 2.2 Rendre accessible le site Internet depuis le WAN - s07  
- Creation première regle NAT : Interface WAN (192.168.240.48) --> IP serveur (10.10.20.3)  
![Regle_NAT1](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/3243ab20374d07816a3825c4277dc4ed1fbb021e/S08/Regle_Nat1.png)  

- Création deuxième règle NAT : Adresse publique (135.125.4.110) --> Interface WAN (192.168.240.48)  

![Regle_NAT2](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/3243ab20374d07816a3825c4277dc4ed1fbb021e/S08/Regle_Nat2.png)  


## 3. SÉCURITÉ - Mettre en place un serveur bastion GUACAMOLE    
## 4. SÉCURITÉ - Mettre en place un serveur de gestion des mises à jour WSUS    
## 5. VOIP - Mettre en place un serveur de téléphonie sur IP    
## 6. SÉCURITÉ - Mettre en place un serveur de gestion de mot de passe    
