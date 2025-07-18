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

### 3.1 - Installation du serveur Bastion Guacamole 

Créer un CT, ajouter une carte vmbr6 (car VM dans la DMZ), renseigner l'adresse IP en fonction du réseaux et choisir template Debian.  
Faire les mises à jours.   

#### 3.1.1 - Installer les prérequis d'Apache Guacamole
    
- Installer les dépendances     
```bash
apt-get install build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev
```

#### 3.1.2 - Compiler et installer Apache Guacamole "Server"

- Télécharger l'archive  
```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz
```
- Décompresser l'archive  
```bash
tar -xzf guacamole-server-1.5.5.tar.gz
cd guacamole-server-1.5.5/
```

- Vérifier la présence des dépendances  
```bash
sudo ./configure --with-systemd-dir=/etc/systemd/system/
```
Toutes les dépendances devraient avoir le status YES  

- Compiler le code source de guacamole-server  
```bash
sudo make  
```

- Installer le composant Guacamole Server  
```bash
sudo make install  
```

#### 3.1.3 - Créer le répertoire de configuration  

```bash
sudo mkdir -p /etc/guacamole/{extensions,lib}  
```

#### 3.1.4 - Installer Guacamole Client (Web App)
- Ajout nouveau fichier source pour APT  
```bash
sudo nano /etc/apt/sources.list.d/bullseye.list 
```

- Ajouter cette ligne  
```
deb http://deb.debian.org/debian/ bullseye main
```

- Mettre à jour le système  
```bash
apt update && apt upgrade  
```

- Installer Tomcat9  
```bash
sudo apt-get install tomcat9 tomcat9-admin tomcat9-common tomcat9-user
```

- Telecharger la dernière version de la Web App d'Apache Guacamole depuis le dépot officiel 
```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.5/binary/guacamole-1.5.5.war
```

- Déplacer le fichier dans la librairie de Web App de Tomcat9  
```bash
sudo mv guacamole-1.5.5.war /var/lib/tomcat9/webapps/guacamole.war
```

- Relancer les services Tomcat9 et guacamole  
```bash
sudo systemctl restart tomcat9 guacd
```

#### 3.1.5 - Base de données MariaDB pour l'authentification

- Installation de la base de donnée MariaDB
```bash 
sudo apt-get install mariadb-server
sudo mysql_secure_installation
```

- Puis on créer une base de données et un utilisateur dédié pour Apache Guacamole
```bash
mysql -u root -p
```

```maria DB
CREATE DATABASE guacadb;
CREATE USER 'guaca_nachos'@'localhost' IDENTIFIED BY 'P@ssword!';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacadb.* TO 'guaca_nachos'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

- Ajouter l'extension MySQL à Apache Guacamole
```bash 
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.5/binary/guacamole-auth-jdbc-1.5.5.tar.gz
tar -xzf guacamole-auth-jdbc-1.5.5.tar.gz
sudo mv guacamole-auth-jdbc-1.5.5/mysql/guacamole-auth-jdbc-mysql-1.5.5.jar /etc/guacamole/extensions/
```

- Télécharger le connecteur MySQL 
```bash 
cd /tmp
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.1.0.tar.gz
tar -xzf mysql-connector-j-9.1.0.tar.gz
sudo cp mysql-connector-j-9.1.0/mysql-connector-j-9.1.0.jar /etc/guacamole/lib/
```

- Importer la structure de la base de données Apache Guacamole dans la base de données "guacadb"
```bash
cd guacamole-auth-jdbc-1.5.5/mysql/schema/
cat *.sql | mysql -u root -p guacadb
```

- Création fichier pour déclarer la connexion à MariaDB
```bash
sudo nano /etc/guacamole/guacamole.properties
```

- Insérer ces lignes 
```# MySQL
mysql-hostname: 127.0.0.1
mysql-port: 3306
mysql-database: guacadb
mysql-username: guaca_nachos
mysql-password: Azerty1*
```

-Déclarer le serveur Guacamole 
```bash 
sudo nano /etc/guacamole/guacd.conf
```

- Ajouter 
```
[server] 
bind_host = 0.0.0.0
bind_port = 4822
```

- Relancer les services
```bash 
sudo systemctl restart tomcat9 guacd mariadb
```


## 4. SÉCURITÉ - Mettre en place un serveur de gestion des mises à jour WSUS    
## 🎯 Objectif
Mettre en place un serveur **WSUS** (Windows Server Update Services) pour centraliser, sécuriser et automatiser la gestion des mises à jour dans l’environnement Active Directory.  
L’objectif principal est de :
- **Limiter les connexions externes directes aux serveurs Microsoft** (enjeu sécurité).
- **Avoir un contrôle granulaire** sur les mises à jour applicables selon le rôle des machines.
- **Différencier les stratégies de mise à jour** pour les postes **clients**, les **serveurs** et les **contrôleurs de domaine (DC)**.

## 🏗️ Architecture & environnement

- **Serveur WSUS** installé sur une **VM dédiée** (hors contrôleur de domaine).
- VM intégrée à l’Active Directory `pharmgreen.local` (liaison DNS + join domaine).
- Rôle WSUS installé via `Server Manager` + configuration de synchronisation avec Microsoft Update.
- Console WSUS configurée pour l’approbation manuelle des mises à jour et le ciblage côté client.

## 🗃️ Groupes WSUS et Active Directory

### 🔧 Console WSUS :
Création de **groupes personnalisés** dans `All Computers` :
- `Grp-WSUS-Clients`
- `Grp-WSUS-Serveurs`
- `Grp-WSUS-DC`

### 🧩 AD - Organisation par OU :
Les machines ont été placées dans des **Unités Organisationnelles (OU)** spécifiques :
- `OU=Clients`
- `OU=Serveurs`
- `OU=Domain Controllers`

Ces OU permettent une **liaison directe avec les stratégies WSUS** (via GPO) et garantissent une **gestion différenciée des mises à jour** selon le rôle des machines.

## 🧠 Stratégies de groupe (GPO)

Trois GPO ont été créées pour appliquer les paramètres WSUS aux différentes OU :

| GPO | Cible AD | Groupe WSUS |
|-----|----------|-------------|
| `COMPUTER-GPO-WSUS-CLIENT` | OU=Clients | Grp-WSUS-Clients |
| `COMPUTER-GPO-WSUS-SERVEURS` | OU=Serveurs | Grp-WSUS-Serveurs |
| `COMPUTER-GPO-WSUS-DC` | OU=Domain Controllers | Grp-WSUS-DC |

### 🧾 Paramètres communs :
- `Specify intranet Microsoft update service location` :  
  `http://wsus-server:8530` *(à adapter selon le nom DNS réel du serveur WSUS)*
- `Enable client-side targeting` :  
  Activé avec nom du groupe correspondant dans WSUS
- `Configure Automatic Updates` :  
  - Auto download and notify for install (Clients)  
  - Schedule install (Serveurs / DC selon les contraintes métiers)
- `No auto-restart with logged on users` : Activé
- `Detection frequency` : Toutes les 6 heures

> ✅ **Sécurité** : ce mécanisme évite les mises à jour non maîtrisées et réduit les risques liés aux incompatibilités ou redémarrages intempestifs.

## 🔁 Déploiement et validation

- GPO appliquées après un `gpupdate /force`
- Appartenance des machines aux bons groupes WSUS vérifiée
- Commandes utilisées sur les clients :
  ```
  wuauclt /reportnow
  wuauclt /detectnow
  ```

- Tests réalisés avec la console WSUS pour vérifier :
  - Remontée des clients
  - Attribution correcte aux groupes
  - Réception des catalogues de mise à jour
  - Capacité d’approuver/refuser des updates selon le groupe

## 5. VOIP - Mettre en place un serveur de téléphonie sur IP    
A venir  

## 6. SÉCURITÉ - Mettre en place un serveur de gestion de mot de passe  
A venir  

