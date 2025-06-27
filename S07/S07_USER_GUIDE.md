# 🛠️ Guide Utilisateur – Sprint 7 : Installation & Configuration    

## 1. Introduction    
Voici le contenu de ce Readme qui reprends essentiellement les configurations non terminées depuis le début du projet :  
( les configurations ont été ajoutés également dans les Readme de leurs sprints respectifs pour plus de lisibilité)  

**GPO de sécurité** (reprise sprint numéro 3)   
Verrouillage de compte (blocage de l'accès à la session après 3 erreurs de mot de passe) pendant 30s   
Restriction d'installation de logiciel pour les utilisateurs non-administrateurs  
Politique de mot de passe (complexité, longueur, etc.)  

**GPO standard** (reprise sprint numéro 3)  
Déploiement (publication) de logiciels firefox  
Redirection de dossiers (Documents, Bureau)  
Configuration des paramètres du navigateur (Firefox )  

**Server GLPI** (reprise sprint numéro 3)  
Installation de l'agent glpi par script ou gpo (pour faire l inventaire)  
Gestion de parc : Inclusion des objets AD (utilisateurs, groupes, ordinateurs)  
Installation de l'agent glpi par script ou gpo (pour faire l inventaire)  

**Mise en place Serveur de messagerie IRedMail** 

**Mise en place Vyos** 
Configuration des VLANS  
Ajout d'une route par défaut (accès WAN)  
Création groupe d'adresses  
Mise en place ACL pour autoriser les VLAN 10 à 60 (utilisateurs) à communiquer avec VLAN 70 (servers)  
Mise en place ACL pour interdire les VLAN 10 à 60 (utilisateurs) à communiquer entre elles  
( Création nouvelle vmbr sur proxmox ) A FAIRE   
( Mise en place des tags VLAN dans proxmox ) A FAIRE  

**Configuration PFsense**  
( Configuration de la nouvelle carte vmbr sur le LAN ) A FAIRE  


## 2. GPO de sécurité  

### 2.1 Verrouillage de compte  

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


### 2.2 Restriction installation : Interdire l'installation de logiciels pour les non-admins  

- Ouvrir : Group Policy Management

- Créer une GPo : COMPUTEUR_Software_Restriction_Standard_Users

- Clique droit dessus et dérouler : Computer Configuration -> Policies > Windows Settings -> Security Settings -> Software Restriction Policies

- Clique-droit sur Software Restriction Policies -> New Software Restriction Policies.  
Dans Security Levels : Clique-droit sur Disallowed > Set as Default.  
Dans Additional Rules : Crée une nouvelle Path Rule :  
            Path : C:\Program Files\  
            Security level : Unrestricted  
            
- Refaire la même chose pour : C:\Windows\  

Cela permet aux admins d’installer dans ces dossiers, mais bloque les utilisateurs standard (car ils ne peuvent écrire ailleurs sans droit admin).  
Pour cibler les utilisateurs non-admin, applique la GPO à une OU contenant uniquement ces comptes (OU_Users par exemple)  


### 2.3 Politique de mot de passe (longueur, complexité…)  
- Ouvrir : Group Policy Management
  
- Créer une GPo : COMPUTEUR_Password_Policy
  
- Clique droit dessus et dérouler : Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies -> Password Policy    

- Mettre ces configurations :    
Minimum password length → 12   
Password must meet complexity requirements → Enabled   
Maximum password age → ex : 90 jours   
Enforce password history → 5    

## 3. GPO standard  

## 4. Server GLPI  

## 5. Mise en place Serveur de messagerie IRedMail  

## 6. Mise en place Vyos  

### 6.1 Installation de Vyos  
- Création d'une VM   
4Go RAM / 4 cores / 32Go disque dur  

- Ajouter les network  
vmbr1 : accès aux VLAN (en 172.16.20.0/27)  
vmbr6 : accès au LAN (en 192.168.200.0/24)  

- Ajouter l'image  
vyos-1.5.iso  

- Allumer la machine et procéder à l'installation  
Une fois l'installation terminé, s'identifier avec : vyos/vyos (id/mdp)  

- Une fois Vyos installé, entrer en mode configuration et procéder à l'identification des cartes réseaux (eth0, eth1 ...)  
``` vyos  
configure  
ip a
```

### 6.2 Configuration de la carte eth1 (LAN point à point) 
set interfaces ethernet eth1 address 192.168.200.1/24 
set interfaces ethernet eth1 description 'LAN'


### 6.3 Configuration de la carte eth0 (avec VLANs)

# VLAN 10 - Serveurs
set interfaces ethernet eth0 vif 10 address '172.16.20.1/27'
set interfaces ethernet eth0 vif 10 description 'VLAN10-Serveurs'

# VLAN 20 - Direction/DSI
set interfaces ethernet eth0 vif 20 address '172.16.20.33/27'
set interfaces ethernet eth0 vif 20 description 'VLAN20-Direction/DSI'

# VLAN 30 - DRH
set interfaces ethernet eth0 vif 30 address '172.16.20.65/27'
set interfaces ethernet eth0 vif 30 description 'VLAN30-DRH'

# VLAN 40 - Finance/Comptabilité
set interfaces ethernet eth0 vif 40 address '172.16.20.97/27'
set interfaces ethernet eth0 vif 40 description 'VLAN40-Finance/Comptabilité'

# VLAN 50 - Développement
set interfaces ethernet eth0 vif 50 address '172.16.20.129/27'
set interfaces ethernet eth0 vif 50 description 'VLAN50-Développement'

# VLAN 60 - Communication
set interfaces ethernet eth0 vif 60 address '172.16.20.161/27'
set interfaces ethernet eth0 vif 60 description 'VLAN60-Communication'

# VLAN 70 - Service Commercial
set interfaces ethernet eth0 vif 70 address '172.16.20.193/27'
set interfaces ethernet eth0 vif 70 description 'VLAN70-ServiceCommercial'


### 6.4 Route par défaut
set protocols static route 0.0.0.0/0 next-hop '192.168.200.254'

### 6.5 Configuration groupe de réseaux pour VLAN10
set firewall group network-group VLAN10 network '172.16.20.0/27'

### 6.6 Configuration groupe de réseaux pour VLAN-20-to-70 
set firewall group network-group VLAN-20-TO-70 network '172.16.20.32/27'
set firewall group network-group VLAN-20-TO-70 network '172.16.20.64/27'
set firewall group network-group VLAN-20-TO-70 network '172.16.20.96/27'
set firewall group network-group VLAN-20-TO-70 network '172.16.20.128/27'
set firewall group network-group VLAN-20-TO-70 network '172.16.20.160/27'
set firewall group network-group VLAN-20-TO-70 network '172.16.20.192/27'

### 6.7 Creation regles pour VLAN10-IN : trafic entrant autorisé uniquement depuis les VLAN-20-to-70
# interdire tout par defaut 
set firewall ipv4 name VLAN10-IN default-action drop
# Autoriser trafic établi et lié
set firewall ipv4 name VLAN10-IN rule 10 action accept
set firewall ipv4 name VLAN10-IN rule 10 state established (enable)
set firewall ipv4 name VLAN10-IN rule 10 state related (enable)
# Autoriser le trafic depuis les VLAN-20-to-70 vers VLAN 10
set firewall ipv4 name VLAN10-IN rule 20 action accept
set firewall ipv4 name VLAN10-IN rule 20 source group network-group VLAN-20-TO-70
set firewall ipv4 name VLAN10-IN rule 20 destination address '172.16.20.0/27'
set firewall ipv4 name VLAN10-IN rule 20 description 'Allow VLAN-20-TO-70 to VLAN 10'

### 6.8 Creation regles pour VLAN10-OUT  : trafic sortant autorisé vers tout le monde 
#  tout accepter par defaut 
set firewall ipv4 name VLAN10-OUT default-action accept
set firewall ipv4 name VLAN10-OUT rule 10 action accept
set firewall ipv4 name VLAN10-OUT rule 10 state established enable
set firewall ipv4 name VLAN10-OUT rule 10 state related enable

### 6.9 Creation regles pour VLAN-20-to-70-IN : trafic entrant autorisé uniquement depuis VLAN 10
# interdire tout par defaut 
set firewall ipv4 name VLAN-20-to-70-IN default-action drop
# Autoriser trafic établi et lié
set firewall ipv4 name VLAN-20-to-70-IN rule 10 action accept
set firewall ipv4 name VLAN-20-to-70-IN rule 10 state established (enable)
set firewall ipv4 name VLAN-20-to-70-IN rule 10 state related (enable)
# Autoriser le trafic depuis les VLAN10 vers VLAN-20-70
set firewall ipv4 name VLAN-20-to-70-IN rule 20 action accept
set firewall ipv4 name VLAN-20-to-70-IN rule 20 source address '172.16.20.0/27'
set firewall ipv4 name VLAN-20-to-70-IN rule 20 destination group network-group VLAN-20-to-70
set firewall ipv4 name VLAN-20-to-70-IN rule 20 description 'Allow VLAN 10 to VLAN-20-to-70'

### 6.10 Creation regles pour VLAN-20-to-70-OUT  : trafic sortant autorisé VLAN10  
set firewall ipv4 name VLAN-20-to-70-OUT rule 40 action accept
set firewall ipv4 name VLAN-20-to-70-OUT rule 40 source network-group VLAN-20-to-70
set firewall ipv4 name VLAN-20-to-70-OUT rule 40 destination  network-group VLAN10
set firewall ipv4 name VLAN-20-to-70-OUT rule 40 description  "Allow VLAN-20-to-70 to VLAN 10"


### 6.9  Application des regles pare-feux sur l’interface VLAN10
set firewall ipv4 name VLAN10-IN rule 10 inbound-interface name eth0  
set firewall ipv4 name VLAN10-IN rule 20 inbound-interface name eth0  
set firewall ipv4 name VLAN10-OUT rule 10 inbound-interface name eth0  

### 6.10  Application des regles pare-feux sur l’interface VLAN-20-to-70
set firewall ipv4 name VLAN-20-to-70-IN rule 10 inbound-interface name eth0  
set firewall ipv4 name VLAN-20-to-70-IN rule 20 inbound-interface name eth0  
set firewall ipv4 name VLAN-20-to-70-OUT rule 10 inbound-interface name eth0  

commit
save

 pour vérifier :

show interfaces
show configuration commands | grep firewall


## 7. Configuration PFsense  
