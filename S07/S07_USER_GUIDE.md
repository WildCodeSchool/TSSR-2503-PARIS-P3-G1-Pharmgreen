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
vmbrX : accès au LAN (en 192.168.200.0/24)  

- Ajouter l'image  
vyos-1.1.8-i586.iso  

- Allumer la machine et procéder à l'installation  
Une fois l'installation terminé, s'identifier avec : vyos/vyos (id/mdp)  

- Une fois Vyos installé, entrer en mode configuration et procéder à l'identification des cartes réseaux (eth0, eth1 ...)  
``` vyos  
configure  
show interfaces    
```

### 6.2 Configuration de la carte eth0 (VLAN) 

- Configuration VLAN 10 - Direction/DSI (172.16.20.32/27)  
``` vyos  
set interfaces ethernet eth0 vif 10 address '172.16.20.33/27'  
set interfaces ethernet eth0 vif 10 description 'VLAN10-Direction/DSI'  
```   

- Configuration VLAN 20 - DRH (172.16.20.64/27)  
``` vyos  
set interfaces ethernet eth0 vif 20 address '172.16.20.65/27'  
set interfaces ethernet eth0 vif 20 description 'VLAN20-DRH'  
```  

- Configuration VLAN 30 - Finance/Comptabilité (172.16.20.96/27)   
``` vyos  
set interfaces ethernet eth0 vif 30 address '172.16.20.97/27'  
set interfaces ethernet eth0 vif 30 description 'VLAN30-Finance/Comptabilité'  
```  

- Configuration VLAN 40 - Développement (172.16.20.128/27)  
``` vyos  
set interfaces ethernet eth0 vif 40 address '172.16.20.129/27'  
set interfaces ethernet eth0 vif 40 description 'VLAN40-Développement'  
```  

- Configuration VLAN 50 - Communication (172.16.20.160/27)  
``` vyos  
set interfaces ethernet eth0 vif 50 address '172.16.20.161/27'  
set interfaces ethernet eth0 vif 50 description 'VLAN50-Communication'  
```  

- Configuration VLAN 60 - Service Commercial (172.16.20.192/27)  
``` vyos  
set interfaces ethernet eth0 vif 60 address '172.16.20.193/27'  
set interfaces ethernet eth0 vif 60 description 'VLAN60-ServiceCommercial'  
``` 

- Configuration VLAN 70 - Serveurs (172.16.20.224/27)  
``` vyos  
set interfaces ethernet eth0 vif 70 address '172.16.20.225/27'  
set interfaces ethernet eth0 vif 70 description 'VLAN70-Serveurs'  
``` 

### 6.3 Ajout une route par défaut dans VyOS vers le pare-feu :  
``` vyos  
set protocols static route 0.0.0.0/0 next-hop 192.168.200.254  
``` 

### 6.4 Création d'un groupe d’adresses pour VLANs 10 à 60 (sources/destinations autorisées)  
``` vyos  
set firewall group network-group VLAN10_TO_60 network 172.16.20.32/27  
set firewall group network-group VLAN10_TO_60 network 172.16.20.64/27  
set firewall group network-group VLAN10_TO_60 network 172.16.20.96/27  
set firewall group network-group VLAN10_TO_60 network 172.16.20.128/27  
set firewall group network-group VLAN10_TO_60 network 172.16.20.160/27  
set firewall group network-group VLAN10_TO_60 network 172.16.20.192/27  
``` 

### 6.4  Mise en place ACL VLAN70-IN (entrée sur interface VLAN70)  pour autoriser uniquement le trafic entrant sur VLAN70 provenant des VLANs 10 à 60  
``` vyos  
set firewall name VLAN70-IN default-action drop  
set firewall name VLAN70-IN rule 10 action accept  
set firewall name VLAN70-IN rule 10 source group network-group VLAN10_TO_60  
set firewall name VLAN70-IN rule 10 destination address 172.16.20.224/27  
set firewall name VLAN70-IN rule 10 description "Allow VLAN 10-60 to VLAN 70"  
```  

### 6.5 Mise en place ACL VLAN70-OUT (sortie sur interface VLAN70) pour autoriser le trafic sortant depuis VLAN70 vers les VLANs 10 à 60 (réponses, etc.)  
``` vyos  
set firewall name VLAN70-OUT default-action drop  
set firewall name VLAN70-OUT rule 10 action accept  
set firewall name VLAN70-OUT rule 10 source address 172.16.20.224/27  
set firewall name VLAN70-OUT rule 10 destination group network-group VLAN10_TO_60  
set firewall name VLAN70-OUT rule 10 description "Allow VLAN 70 to VLAN 10-60"  
```  

### 6.6  Appliquer ces ACL à l’interface VLAN70  
``` vyos  
set interfaces ethernet eth0 vif 70 firewall in name VLAN70-IN  
set interfaces ethernet eth0 vif 70 firewall out name VLAN70-OUT  
``` 


-  (PAS ENCORE CONFIGURé) Pour interdire la communication directe entre VLANs 10 à 60
Si tu veux bloquer que les VLANs 10 à 60 communiquent entre eux, tu peux ajouter sur chaque interface VLAN 10, 20, 30, 40, 50, 60 une ACL entrante qui autorise uniquement le trafic vers VLAN70.
Exemple pour VLAN 10 :
set firewall name VLAN10-IN default-action drop
set firewall name VLAN10-IN rule 10 action accept
set firewall name VLAN10-IN rule 10 destination address 172.16.20.224/27
set firewall name VLAN10-IN rule 10 description "Allow VLAN 10 to VLAN 70"
set interfaces ethernet eth0 vif 10 firewall in name VLAN10-IN

- Finaliser avec un commit et une sauvegarde  
```  commit  
save  
exit  
``` 

- (PAS ENCORE FAIT ) 
Création d'une nouvelle carte vmbr pour le réseaux 192.168.200.0/24  
et la configurer dans vyos et dans PFSENSE (en remplacement de la vmbr1 en LAN) 

- (PAS ENCORE FAIT ) 
Définir les VLAN dans les vmbr1 de chaque machine  
Retirer les vmbr0 de chaque machine  

- (PAS ENCORE FAIT ) 
faire les test 

## 7. Configuration PFsense  
