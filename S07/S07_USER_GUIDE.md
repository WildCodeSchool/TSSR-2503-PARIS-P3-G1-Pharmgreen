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
Installation de Vyos  
Configuration de la carte eth0 (avec VLANs) vmbr1  
Configuration de la carte eth1 (LAN point à point) vmbr6   
Route par défaut   
Mise en place des règles de trafic entrant et sortant  
Application des règles aux interfaces correspondantes  

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
2Go RAM / 4 cores / 32Go disque dur  

- Ajouter les networks  
vmbr1 : accès aux VLAN (en 172.16.20.0/27)  
vmbr6 : accès au LAN (en 192.168.200.0/24)  

- Ajouter l'image  
vyos-1.1.iso  

- Allumer la machine et s'identifier avec : vyos/vyos (id/mdp)  

- Lancer l'installation  
install image   

- Sur le clavier taper : touche entrée  -> entrée -> yes -> entrée -> vyos  

- Renseigner un mot de passe pour l'utilisateur Vyos, puis confirmer une seconde fois  

- Sur le clavier taper : touche entrée  

- A la fin de l'installation, redemarrer la machine et retirer l'ISO 
reboot 

- S'identifier (vyos/vyos), entrer en mode configuration et procéder à l'identification des cartes réseaux (eth0, eth1 ...)  
``` vyos   
configure   
ip a  
```
 
### 6.2 Configuration de la carte eth0 (avec VLANs) vmbr1  

#### VLAN 10 - Serveurs  
set interfaces ethernet eth0 vif 10 address '172.16.20.30/27'  
set interfaces ethernet eth0 vif 10 description 'VLAN10'  

#### VLAN 20 - Direction/DSI  
set interfaces ethernet eth0 vif 20 address '172.16.20.62/27'  
set interfaces ethernet eth0 vif 20 description 'VLAN20'  

#### VLAN 30 - DRH  
set interfaces ethernet eth0 vif 30 address '172.16.20.94/27'  
set interfaces ethernet eth0 vif 30 description 'VLAN30'  

#### VLAN 40 - Finance/Comptabilité  
set interfaces ethernet eth0 vif 40 address '172.16.20.126/27'  
set interfaces ethernet eth0 vif 40 description 'VLAN40'  

#### VLAN 50 - Développement  
set interfaces ethernet eth0 vif 50 address '172.16.20.158/27'   
set interfaces ethernet eth0 vif 50 description 'VLAN50'   

#### VLAN 60 - Communication  
set interfaces ethernet eth0 vif 60 address '172.16.20.190/27'   
set interfaces ethernet eth0 vif 60 description 'VLAN60'  

#### VLAN 70 - Service Commercial  
set interfaces ethernet eth0 vif 70 address '172.16.20.222/27'  
set interfaces ethernet eth0 vif 70 description 'VLAN70'  

### 6.3 Configuration de la carte eth1 (LAN point à point) vmbr6  
set interfaces ethernet eth1 address 192.168.200.1/24  
set interfaces ethernet eth1 description 'LAN' 

### 6.4 Route par défaut  
set protocols static route 0.0.0.0/0 next-hop '192.168.200.254'  

### 6.5 Mise en place des règles de trafic entrant et sortant  

#### 6.5.1 VLAN10  
set firewall name VLAN10-IN rule 10 action accept  
set firewall name VLAN10-IN rule 10 source address 172.16.20.128/27  
set firewall name VLAN10-IN rule 10 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 10 protocol all  
set firewall name VLAN10-IN rule 10 description "Allow VLAN50 → VLAN10"  

set firewall name VLAN10-IN rule 20 action accept  
set firewall name VLAN10-IN rule 20 source address 172.16.20.32/27  
set firewall name VLAN10-IN rule 20 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 20 protocol all  
set firewall name VLAN10-IN rule 20 description "Allow VLAN20 → VLAN10"  

set firewall name VLAN10-IN rule 30 action accept  
set firewall name VLAN10-IN rule 30 source address 172.16.20.64/27  
set firewall name VLAN10-IN rule 30 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 30 protocol all  
set firewall name VLAN10-IN rule 30 description "Allow VLAN30 → VLAN10"  

set firewall name VLAN10-IN rule 40 action accept  
set firewall name VLAN10-IN rule 40 source address 172.16.20.96/27  
set firewall name VLAN10-IN rule 40 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 40 protocol all  
set firewall name VLAN10-IN rule 40 description "Allow VLAN40 → VLAN10"  

set firewall name VLAN10-IN rule 50 action accept  
set firewall name VLAN10-IN rule 50 source address 172.16.20.160/27  
set firewall name VLAN10-IN rule 50 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 50 protocol all  
set firewall name VLAN10-IN rule 50 description "Allow VLAN60 → VLAN10"  

set firewall name VLAN10-IN rule 60 action accept  
set firewall name VLAN10-IN rule 60 source address 172.16.20.192/27  
set firewall name VLAN10-IN rule 60 destination address 172.16.20.0/27  
set firewall name VLAN10-IN rule 60 protocol all  
set firewall name VLAN10-IN rule 60 description "Allow VLAN70 → VLAN10"  

set firewall name VLAN10-IN default-action drop  

set firewall name VLAN10-OUT rule 10 action accept  
set firewall name VLAN10-OUT rule 10 destination address 172.16.20.128/27  
set firewall name VLAN10-OUT rule 10 source address 172.16.20.0/27  
set firewall name VLAN10-OUT rule 10 protocol all  
set firewall name VLAN10-OUT rule 10 description "Allow VLAN10 → VLAN50 (OUT)"  
set firewall name VLAN10-OUT default-action drop  

#### 6.5.2 VLAN20   
set firewall name VLAN20-IN rule 10 action accept  
set firewall name VLAN20-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN20-IN rule 10 destination address 172.16.20.32/27  
set firewall name VLAN20-IN rule 10 protocol all  
set firewall name VLAN20-IN rule 10 description "Allow VLAN10 → VLAN20"  
set firewall name VLAN20-IN default-action drop  

set firewall name VLAN20-OUT rule 10 action accept  
set firewall name VLAN20-OUT rule 10 destination address 172.16.20.0/27  
set firewall name VLAN20-OUT rule 10 source address 172.16.20.32/27  
set firewall name VLAN20-OUT rule 10 protocol all  
set firewall name VLAN20-OUT rule 10 description "Allow VLAN20 → VLAN10"  
set firewall name VLAN20-OUT default-action drop  

#### 6.5.3 VLAN30  
set firewall name VLAN30-IN rule 10 action accept  
set firewall name VLAN30-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN30-IN rule 10 destination address 172.16.20.64/27  
set firewall name VLAN30-IN rule 10 protocol all  
set firewall name VLAN30-IN rule 10 description "Allow VLAN10 → VLAN30"  
set firewall name VLAN30-IN default-action drop  

set firewall name VLAN30-OUT rule 10 action accept  
set firewall name VLAN30-OUT rule 10 destination address 172.16.20.0/27  
set firewall name VLAN30-OUT rule 10 source address 172.16.20.64/27  
set firewall name VLAN30-OUT rule 10 protocol all  
set firewall name VLAN30-OUT rule 10 description "Allow VLAN30 → VLAN10"  
set firewall name VLAN30-OUT default-action drop  


#### 6.5.4 VLAN40  
set firewall name VLAN40-IN rule 10 action accept  
set firewall name VLAN40-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN40-IN rule 10 destination address 172.16.20.96/27  
set firewall name VLAN40-IN rule 10 protocol all  
set firewall name VLAN40-IN rule 10 description "Allow VLAN10 → VLAN40"  
set firewall name VLAN40-IN default-action drop  

set firewall name VLAN40-OUT rule 10 action accept  
set firewall name VLAN40-OUT rule 10 destination address 172.16.20.0/27   
set firewall name VLAN40-OUT rule 10 source address 172.16.20.96/27  
set firewall name VLAN40-OUT rule 10 protocol all  
set firewall name VLAN40-OUT rule 10 description "Allow VLAN40 → VLAN10"  
set firewall name VLAN40-OUT default-action drop  

#### 6.5.5 VLAN50  
set firewall name VLAN50-IN rule 10 action accept  
set firewall name VLAN50-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN50-IN rule 10 destination address 172.16.20.128/27  
set firewall name VLAN50-IN rule 10 protocol all  
set firewall name VLAN50-IN rule 10 description "Allow VLAN10 → VLAN50"  
set firewall name VLAN50-IN default-action drop  

set firewall name VLAN50-OUT rule 10 action accept  
set firewall name VLAN50-OUT rule 10 destination address 172.16.20.0/27  
set firewall name VLAN50-OUT rule 10 source address 172.16.20.128/27  
set firewall name VLAN50-OUT rule 10 protocol all  
set firewall name VLAN50-OUT rule 10 description "Allow VLAN50 → VLAN10"  
set firewall name VLAN50-OUT default-action drop  

#### 6.5.6 VLAN60  
set firewall name VLAN60-IN rule 10 action accept  
set firewall name VLAN60-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN60-IN rule 10 destination address 172.16.20.160/27  
set firewall name VLAN60-IN rule 10 protocol all  
set firewall name VLAN60-IN rule 10 description "Allow VLAN10 → VLAN60"  
set firewall name VLAN60-IN default-action drop  

set firewall name VLAN60-OUT rule 10 action accept  
set firewall name VLAN60-OUT rule 10 destination address 172.16.20.0/27  
set firewall name VLAN60-OUT rule 10 source address 172.16.20.160/27  
set firewall name VLAN60-OUT rule 10 protocol all  
set firewall name VLAN60-OUT rule 10 description "Allow VLAN60 → VLAN10"  
set firewall name VLAN60-OUT default-action drop  

#### 6.5.7 VLAN70  
set firewall name VLAN70-IN rule 10 action accept  
set firewall name VLAN70-IN rule 10 source address 172.16.20.0/27  
set firewall name VLAN70-IN rule 10 destination address 172.16.20.192/27  
set firewall name VLAN70-IN rule 10 protocol all  
set firewall name VLAN70-IN rule 10 description "Allow VLAN10 → VLAN70"  
set firewall name VLAN70-IN default-action drop  

set firewall name VLAN70-OUT rule 10 action accept  
set firewall name VLAN70-OUT rule 10 destination address 172.16.20.0/27  
set firewall name VLAN70-OUT rule 10 source address 172.16.20.192/27  
set firewall name VLAN70-OUT rule 10 protocol all  
set firewall name VLAN70-OUT rule 10 description "Allow VLAN70 → VLAN10"  
set firewall name VLAN70-OUT default-action drop  

### 6.6 Application des règles aux interfaces correspondantes   

set interfaces ethernet eth0 vif 10 firewall in name VLAN10-IN  
set interfaces ethernet eth0 vif 10 firewall out name VLAN10-OUT  

set interfaces ethernet eth0 vif 20 firewall in name VLAN20-IN  
set interfaces ethernet eth0 vif 20 firewall out name VLAN20-OUT  

set interfaces ethernet eth0 vif 30 firewall in name VLAN30-IN  
set interfaces ethernet eth0 vif 30 firewall out name VLAN30-OUT  

set interfaces ethernet eth0 vif 40 firewall in name VLAN40-IN  
set interfaces ethernet eth0 vif 40 firewall out name VLAN40-OUT  

set interfaces ethernet eth0 vif 50 firewall in name VLAN50-IN  
set interfaces ethernet eth0 vif 50 firewall out name VLAN50-OUT  

set interfaces ethernet eth0 vif 60 firewall in name VLAN60-IN  
set interfaces ethernet eth0 vif 60 firewall out name VLAN60-OUT  

set interfaces ethernet eth0 vif 70 firewall in name VLAN70-IN  
set interfaces ethernet eth0 vif 70 firewall out name VLAN70-OUT  

#### Pour rappel : 
vmbr100 -> NAT (192.168.240.0/24)  
vmbr1 -> VLAN (172.16.20.0/27)  
vmbr5 -> DMZ (10.10.20.0/24)  
vmbr6 -> Réseaux point à point (192.168.200.0/24)  

#### Vérifier que les VM ont bien ces vmbr et que les adresses des interfaces correspondent :   
- Pfsense :
  vmbr 100 (192.168.240.48/24)
  vmbr 5 (10.10.20.254/24)
  vmbr 6 (192.168.200.254/24)
    
- Vyos :
  vmbr 6 (192.168.200.1/24)  
  vmbr 1 ( verifier chaque interface VLAN selon adressage rubrique 6.2 )
  
- VM dans les VLAN :
  vmbr1 (ne pas mettre d'autres vmbr, cela bloquerai la connexion)


## 7. Configuration PFsense  
A venir  

## 8.📨 Documentation d’installation d’un serveur de messagerie iRedMail  

**🧱 1. PRÉREQUIS TECHNIQUES**  

**Infrastructure**  

Hyperviseur : Proxmox VE  

Type de machine : Conteneur LXC (CT)  

Réseau : DMZ (zone démilitarisée), configurée avec des règles spécifiques sur le pare-feu  

Adresse IP fixe attribuée au conteneur   

Nom de domaine enregistré pharmgreen.local  

**Système**  
OS du CT : Debian 12   

**1.1. Préparation du serveur iredmail :**  
Mise à jour du système:se connecter en root  

apt update && apt upgrade -y  
Configuration du nom d'hôte: mail.pharmgreen.local  

sudo hostnamectl set-hostname mail  
echo "mail.pharmgreen.local" | tee /etc/hostname  
Configuration du fichier /etc/hosts:  

172.16.20.11  localhost mail.pharmgreen.local  
Installation des outils:  

sudo apt install -y wget vim  

**1.2. Préparation du server DNS :**  
**a. Nouvelle zone**  
Clic droit sur "Zones de recherche directe" -> "Nouvelle Zone...".  
Choisissez "Zone principale" et cliquez sur "Suivant".  
Entrez le nom de votre domaine pharmgreen.local et cliquez sur "Suivant".  
Choisissez "Créer un nouveau fichier avec ce nom de fichier" et cliquez sur "Suivant".  
et "Terminer".  

**b. Ajoutez les enregistrements:**  
**Enregistrement MX:**  

Clic droit sur votre domaine -> "Nouvel enregistrement...".  
Choisissez "Échangeur de courrier (MX)" et cliquez sur "Créer un enregistrement...".  
Dans "Nom de l'hôte de l'échangeur de courrier", entrez le nom d'hôte de votre serveur iredmail (ex: mail).  
Dans "Priorité", entrez une valeur faible (ex: 10).  
Cliquez sur "OK".  

**Enregistrement A:**  

Clic droit sur votre domaine -> "Nouvel enregistrement...".  
Choisissez "Hôte (A)" et cliquez sur "Créer un enregistrement...".  
Dans "Nom", entrez le nom d'hôte de votre serveur Iredmail (ex: mail).  
Dans "Adresse IP", entrez l'adresse IP de votre serveur iredmail.  
Cliquez sur "OK".

**Enregistrement CNAME (optionnel):**  

Clic droit sur votre domaine -> "Nouvel enregistrement...".  
Choisissez "Alias (CNAME)" et cliquez sur "Créer un enregistrement...".  
Dans "Nom d'alias", entrez un alias pour votre serveur iredmail (iredmail)).  
Dans "Nom de domaine complet de la cible", entrez le nom de domaine complet de votre serveur iredmail (ex: mail.tssr.lab).  
Cliquez sur "OK".  
 
**📥 Étape 2 - Téléchargement et installation d'iRedMail**  
**2.1. Téléchargement**  

Depuis le site officiel : https://www.iredmail.org/download.html  

**2.2. Installation :**  
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz  
tar xvf 1.7.2.tar.gz  
cd iRedMail-1.7.4  
bash iRedMail.sh  

**2.3. Configuration :**   
Stockage des emails: Choisissez l'emplacement (par défaut /var/vmail).  
Serveur web: Nginx .    
Backend: OpenLDAP.  
Premier domaine: pharmgreen.local  
Mot de passe administrateur de la base de donnée: Fort et sécurisé.  
Nom de domaine du premier mail : pharmgreen.local  
Mot de passe administrateur du premier mail: Fort et sécurisé.  
Composant optionnel cochez toutes les options  
Confirmation: Vérifiez les options et confirmez.  

**⚙️ Étape 3 - Configuration initiale d'iRedMail**  
Depuis le client windows ou ubuntu  

Accès à l'administration: https://mail.pharmgreen.local/iredadmin  
Connexion: Avec postmaster@tssr.lab et le mot de passe.  
**Configuration:**  
Vérifier la configuration du domaine existant : Nom de domaine, adresse  

**🧑‍💻 Étape 4 - Gestion des domaines et des comptes**  
Cette étape vous permet de créer des comptes utilisateurs sur votre domaine.  
1. Créez un compte utilisateur :  

Cliquez sur le bouton "Add" puis user.  

Exemple de configuration :  

Email: utilisateur1@pharmgreen.local  
Password: Un mot de passe fort (au moins 8 caractères avec des lettres majuscules et minuscules, des chiffres et des symboles).  
Name: Utilisateur Un  
Quota: 1024 (quota de 1 Go)  
Active: Cochez la case pour activer le compte.  
Cliquez sur "Add" pour créer le compte utilisateur.  

**📨 Étape 5 - Accès à la messagerie via webmail**  
Webmail: https://mail.pharmgreen.local/mail (Roundcube).  

**🖥️ Étape 6 - Configuration de Thunderbird**  
Lancez Thunderbird et cliquez sur "Configurer un compte existant".  

Saisissez les informations du compte :  

Votre nom: Votre nom complet.  
Adresse email: utilisateur1@gmail.local  
Mot de passe: Du compte email.  
Configuration manuelle (si nécessaire) :  

Serveur entrant: `mail.pharmgreen.local (IMAP)  
Port: 143  
Serveur sortant (SMTP): `mail.tssr.lab  
Port: 587  
Nom d'utilisateur: Adresse email complète.  
Authentification: Mot de passe normal.  
Sécurité de la connexion: SSL/TLS.  
Cliquez sur "Terminer".  

Vous pouvez maintenant tester l'envoi de mail entre les utilisateurs  




