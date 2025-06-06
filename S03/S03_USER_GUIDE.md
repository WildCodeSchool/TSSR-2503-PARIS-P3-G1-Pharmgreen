# 🛠️ Guide Utilisateur – Sprint 3 : Installation & Configuration

## 1. Introduction

Ce document reprend les instructions pour :   
- La création et configuration pour le PC d'administration  
- La création et configuration pour GLPI
- La création et configuration pour GLPI redondance  
- La création et configuration pour Pfsense  
- La mise en place des GPO de sécurité et les GPO standards
- Gestion de la télémétrie via GPO  


## 2. Création des VMs

### 2.1 PC Administration (Windows 10) 

Installation de OpenSSH Client (et server optionnel) 

### 2.2 Server GLPI 

#### 2.2.1 Installation Server GLPI 

- Créer une VM dans Proxmox 
- ISO : debian12.iso
- Ressources :  2 CPU, 2 Go RAM, 30 Go disque
- vmbr1 (adresse ip : 172.16.20.5 / masque : 255.255.255.224)

#### Objectif :
Mettre en place une solution de gestion de parc informatique GLPI sur une VM Debian 12, accessible depuis des clients Ubuntu et Windows 10.

#### Étapes d’installation de Debian 12

1. Démarrer la VM depuis l’ISO `debian-12.iso`.
2. Suivre l’installation standard Debian (langue, clavier, fuseau horaire…).
3. Configurer manuellement le réseau :
   - IP : `172.16.20.5`
   - Masque : `255.255.255.224`
   - Passerelle : selon votre réseau (ex : `172.16.20.1`)
   - DNS : `8.8.8.8`
4. Créer un utilisateur et définir le mot de passe root.
5. Choisir `Serveur SSH` et `Environnement standard système` dans les logiciels à installer.
6. Terminer l’installation et redémarrer.

#### Installation de GLPI et des dépendances

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mariadb-server php php-mysql php-xml php-cli php-curl php-mbstring php-ldap php-gd php-imap php-intl php-apcu unzip wget -y
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.14/glpi-10.0.14.tgz
tar -xvzf glpi-10.0.14.tgz
sudo mv glpi /var/www/html/
sudo chown -R www-data:www-data /var/www/html/glpi
sudo chmod -R 755 /var/www/html/glpi
```

Créer un fichier de configuration Apache :
```bash
sudo nano /etc/apache2/sites-available/glpi.conf
```

Contenu :
```
<VirtualHost *:80>
    DocumentRoot /var/www/html/glpi
    ServerName glpi.local
    <Directory /var/www/html/glpi>
        AllowOverride All
    </Directory>
</VirtualHost>
```

Activer le site :
```bash
sudo a2ensite glpi.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

Configurer MariaDB :
```bash
sudo mysql -u root -p
```

Dans MariaDB :
```sql
CREATE DATABASE glpidb;
CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'motdepassefort';
GRANT ALL PRIVILEGES ON glpidb.* TO 'glpiuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Accès à l'interface graphique GLPI

#### Client Ubuntu

| Adresse IP | 172.16.20.7 |
|------------|--------------|

```bash
ping 172.16.20.5
```
Accès via navigateur : `http://172.16.20.5/glpi`

#### Client Windows 10

| Adresse IP | 172.16.20.15 |
|------------|----------------|

```cmd
ping 172.16.20.5
```
Accès via navigateur : `http://172.16.20.5/glpi`

#### Comptes par défaut après installation

| Utilisateur     | Mot de passe |
|-----------------|--------------|
| glpi (admin)    | glpi         |
| tech            | tech         |
| normal          | normal       |
| post-only       | postonly     |

> Pensez à modifier les mots de passe immédiatement après l’installation.

#### 2.2.2 Synchronisation GLPI et AD avec ldap

##### 2.2.2.1 Installation des outils LDAP sur le serveur GLPI 
``` bash
sudo apt update  
sudo apt install ldap-utils -y  
```
- Tester la connexion LDAP  
``` bash
ldapsearch -x \  
  -H ldap://172.16.20.1 \  
  -D "CN=glpi-ldap,OU=OU_AdminSystm,OU=OU_DSI,OU=OU_Users,DC=pharmgreen,DC=local" \  
  -W \   
  -b "DC=pharmgreen,DC=local"  
```

##### 2.2.2.2 Configuration de l'annuaire LDAP dans GLPI  
Aller dans Configuration -> Authentification -> Annuaire LDAP -> Ajouter un nouvel annuaire ou modifier celui existant 

Renseigner les champs :  
Nom	: Active Directory  
Serveur par défaut : oui  
Serveur	: 172.16.20.1  
Actif	: oui  
Port	: 389  
Base DN	: DC=pharmgreen,DC=local  
Filtre de connexion :	(&(objectClass=user)(sAMAccountName=%u))  
Utiliser un bind ? : oui  
DN du compte :	CN=glpi-sync,CN=Users,DC=pharmgreen,DC=local (ou OU personnalisé)  
Mot de passe du compte	: (mot de passe du compte glpi-ldap)  
Champ identifiant	: sAMAccountName  
Champs de synchronisation :	cn,mail,displayName  

Cliquer sur "Tester"  
Si le test echoue : vérifier le DN du compte avec la commande  
``` powershell  
Get-ADUser glpi_ldap | Select DistinguishedName  
```

##### 2.2.2.3 Importer les utilisateurs AD dans GLPI   
- Ouvrir l'interface web de GLPI  

Aller dans Administration -> Utilisateurs  
Cliquer sur "Depuis une source externe"  

A reprendre  

#### 2.2.3 Inclusion des Objects AD (utilisateurs, groupes, ordinateurs) 
x

### 2.3 Server GLPI Redondance 

- Créer une VM dans Proxmox 
- ISO : debian12.iso
- Ressources :  2 CPU, 2 Go RAM, 30 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.6 / masque : 255.255.255.224) 


### 2.4 Server pfsense

- Créer une VM dans Proxmox 
- ISO : Debian12.iso
- Ressources : 2 CPU, 2 Go RAM, 40 Go disque
- Network : 
vmbr0 (adresse ip : 192.168.240.(deux dernier numéro numéro VM) / masque : 255.255.255.0 / Gateway : 192.168.240.1 / DNS : 8.8.8.8 ) 
vmbr1 (adresse ip : 172.16.20.4 / masque : 255.255.255.224) 


## 3. Mise en place des GPO

Pour la mise en place des GPOs, dans Server Manager -> Tools -> Group Policy Management
Dérouler : Forest:pharmgreen.local / Domains / pharmgreen.local / Group Policy Object
- Clique droit sur GPO -> New  
Paramétrer les configuration suivantes : 

### 3.1 GPO de sécurité 

#### 3.1.1 Gestion du pare-feu

Name : User_Manage_Firewall_Deny 
Dérouler : User Configuration -> Policies -> Administrative Template -> Network -> Network Connection
- Prohibit adding and removing components for a LAN or remote access connecion - Enabled   
- Prohibit access to the Advanced Settings item on the Advanced menu -> Enabled 
- Prohibit TCP/IP adanced configuration -> Enabled 
- Prohibit Enabling/Disabling component of a LAN connection -> Enabled
- Prohibit deletion of remote access connnections -> Enabled
- Prohibit access to the remote access preferences item on the Advanced menu -> Enabled
- Prohibit access to proprieties of components of a LAN connection -> Enabled
- Prohibit access to properties of a LAN connecion -> Enabled
- Prohibit access to the New Connection Wizard -> Enabled
- Prohibit access to properties of components of a remote access connection -> Enabled
- Prohibit connecting and disconnecting a remote access connection -> Enabled
- Prohibit changing properties of a private remote access connection -> Enabled
- Prohibit renaming private remote access connections -> Enabled
- Prohibit viewing if status for an active connection -> Enabled
Lier cette GPO au domain.

Name : User_Manage_Firewall_Allow 
Dérouler : User Configuration -> Policies -> Administrative Template -> Network -> Network Connection
- Prohibit adding and removing components for a LAN or remote access connecion - Disabled   
- Prohibit access to the Advanced Settings item on the Advanced menu -> Disabled 
- Prohibit TCP/IP adanced configuration -> Disabled 
- Prohibit Enabling/Disabling component of a LAN connection -> Disabled
- Prohibit deletion of remote access connnections -> Disabled
- Prohibit access to the remote access preferences item on the Advanced menu -> Disabled
- Prohibit access to proprieties of components of a LAN connection -> Disabled
- Prohibit access to properties of a LAN connecion -> Disabled
- Prohibit access to the New Connection Wizard -> Disabled
- Prohibit access to properties of components of a remote access connection -> Disabled
- Prohibit connecting and disconnecting a remote access connection -> Disabled
- Prohibit changing properties of a private remote access connection -> Disabled
- Prohibit renaming private remote access connections -> Disabled
- Prohibit viewing if status for an active connection -> Disabled
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce

#### 3.1.2 Ecran de veille en sortie  

Name : User_Manage_SleepDelay_5min
Dérouler : User Configuration -> Policies -> Administrative Template -> Controle Panel -> 
Personalization 
- Enable screen saver -> Enable 
- Screen save executable name -> Value 300 -> Enable
- Password Protect the screen saver -> Enable
Lier cette GPO au domain.

Name : User_Manage_SleepDelay_None
Dérouler : User Configuration -> Policies -> Administrative Template -> Controle Panel -> 
Personalization 
- Enable screen saver -> Disable
- - Screen save executable name -> Value 300 -> Disable
- Password Protect the screen saver -> Disable
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce


#### 3.1.3 Blocage panneau de configuration 

Name : User_ControlPanelAccess_Deny
Dérouler : User Configuration -> Policies -> Administrative Template -> Control Panel
- Prohibit access to Control Panel and PC settings -> Enabled
Lier cette GPO au domain.

Name : User_ControlPanelAccess_Allow
Dérouler : User Configuration -> Policies -> Administrative Template -> Control Panel
- Prohibit access to Control Panel and PC settings -> Disabled
Lier cette GPO aux OU à exclure de la premiere GPO
-> enforce


#### 3.1.4 Verrouillage de compte  

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


#### 3.1.5 Restriction installation
totale 


### 3.2 Mise en place des GPO standard 
L’objectif de cette section est de déployer un ensemble de stratégies de groupe (GPO) afin d’uniformiser la configuration des postes clients au sein du domaine.    
#### 3.2.1 Déploiement d’un fond d’écran d’entreprise  
**Objectif :** Définir un fond d'écran commun pour tous les utilisateurs du domaine.  
**Étapes :**  
    1. Placer l’image .jpg ou .bmp du fond d’écran dans un dossier partagé (ex : \\SRV-AD1-SCHEMAM\Ressources\FondEcran\fond.jpg) avec des droits en lecture pour tous les utilisateurs.  
    2. Créer une nouvelle GPO nommée USER_FondEcran_Entreprise.  
    3. Édition de la GPO :  
        ◦ Chemin : Configuration utilisateur > Stratégies > Modèles d'administration > Bureau > Active Desktop > Active Desktop Wallpaper  
        ◦ Activer la stratégie et indiquer le chemin UNC de l’image (ex : \\SRV-AD1-SCHEMAM\Ressources\FondEcran\fond.jpg)  
        ◦ Style : Remplir, centré ou adapté selon besoin.  
    4. Lier la GPO à l’OU contenant les utilisateurs ou les ordinateurs.  
    5. Tester sur un poste client via gpupdate /force.  

#### 3.2.2 Gestion Alimentation   
**Objectif :** Réduire la consommation d’énergie des postes inactifs.  
**Étapes :**  
    1. Créer une GPO nommée USER_GestionAlim_10Min.  
    2. Édition de la GPO :  
        ◦ Chemin : Configuration ordinateur > Paramètres > Panneau de configuration > Options d’alimentation  
        ◦ Créer ou importer un plan d'alimentation personnalisé (ex : "Économie d’énergie").  
        ◦ Configurer les délais d’extinction d’écran, mise en veille, par exemple.  
    3. Lier la GPO à l’OU contenant les ordinateurs.  
    4. Tester sur un poste client via gpupdate /force.  
    
#### 3.2.3 Déploiement logiciel   
**Objectif :** Publier une application (ex : 7-Zip) sur tous les postes via GPO.  
**Étapes :**  
    1. Copier le fichier .msi de l’application dans un dossier partagé avec accès en lecture (ex : \\SRV-AD1-SCHEMAM\Logiciels\7zip.msi).  
    2. Créer une GPO nommée USER_Deploy_Firefox.  
    3. Édition de la GPO :  
        ◦ Chemin : Configuration utilisateur > Paramètres logiciels > Installation de logiciels  
        ◦ Clic droit > Nouveau > Package > Parcourir vers le chemin UNC du .msi.  
        ◦ Sélectionner "Publié".  
    4. Lier la GPO à l’OU des utilisateurs.  
    5. L’application apparaîtra dans le Panneau de configuration > Programmes à installer.  
    6. Tester sur un poste client via gpupdate /force.  

#### 3.2.4 Redirection de dossier   
**Objectif :** Rediriger le dossier personnel Documents vers un partage réseau centralisé.  
**Étapes :**  
    1. Créer un dossier partagé sur le serveur de fichiers (ex : \\SRV-FICHIERS\Profils) avec sous-dossiers par utilisateur.  
    2. Créer une GPO nommée USER_Redir_Dossiers.  
    3. Édition de la GPO :  
        ◦ Chemin : Configuration utilisateur > Stratégies > Paramètres Windows > Redirection de dossiers > Documents  
        ◦ Clic droit > Propriétés > Rediriger vers un emplacement de base : \\SRV-FICHIERS\Profils\%username%  
        ◦ Activer la création automatique du dossier utilisateur.  
    4. Lier la GPO à l'OU des utilisateurs.  
      

#### 3.2.5 Gestion des paramètres du navigateurs   
**Objectif :**  
    • Définir une page d’accueil.  
    • Forcer l’utilisation de Google comme moteur de recherche.  
    • Bloquer les extensions non autorisées.  
Étapes :  
    1. Télécharger les fichiers ADMX du navigateur (Edge : MS Docs, Chrome : Chrome Enterprise) et les copier dans le dossier C:\Windows\PolicyDefinitions du contrôleur de domaine.  
    2. Créer une GPO nommée USER_Config_Firefox.  
    3. Édition de la GPO (ex : pour Google Chrome) :  
        ◦ Chemin : Configuration utilisateur > Stratégies > Modèles d'administration > Google > Google Chrome  
            ▪ Page d’accueil :  
                • Activer > URL personnalisée (ex : https://intranet.entreprise.local)  
            ▪ Moteur de recherche par défaut :  
                • Définir Google : https://www.google.com/search?q={searchTerms}  
            ▪ Extensions :  
                • Liste noire : Activer et laisser * pour tout bloquer.  
                • Liste blanche : Ajouter les ID des extensions autorisées.  
    4. Lier la GPO à l’OU des utilisateurs.  

### 3.3 Gestion de la télémétrie via GPO  

3.3.1 Installation et mise à jour des ADMX  
- Télécharger les modèles d'administration (ADMX) correspondant à la version de Windows de tes postes clients :
https://www.microsoft.com/en-us/download/details.aspx?id=104003

