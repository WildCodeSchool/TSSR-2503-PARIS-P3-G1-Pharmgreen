# 🛠️ Guide Utilisateur – Sprint 8 : Installation & Configuration    

## 1. Introduction    
Voici le contenu de ce Readme qui reprends essentiellement les configurations non terminées depuis le début du projet :  
( les configurations ont été ajoutés également dans les Readme de leurs sprints respectifs pour plus de lisibilité)  

**SÉCURITÉ - Mettre en place un serveur de gestion des mises à jour WSUS**    
Installation sur VM dédiée  
Liaison avec l'AD : Les groupes dans WSUS sont liés à l'AD / Les MAJ sont liées aux OU  
Gérer différemment les MAJ pour : Les client / Les serveurs / Les DC  

**SÉCURITÉ - Mettre en place un serveur bastion GUACAMOLE**  
En DMZ ou dans un vlan séparé  
Gestion des règles de pare-feu en conséquences  
Synchronisation des accès avec des groupes AD (opt.)  

**WEB - Mettre en place un serveur WEB**  
Utilisation de la solution suivante : apache  
Mis en DMZ  
Hébergement de 2 sites : L'un accessible via le réseau interne et Le second accessible par tout le monde depuis l’extérieur  

**Reprise anciens objectifs**  
Mise en place Vyos (ajout des vlans) - s07  
Configuration PFsense (en integrant Vyos) - s07  

## 2. SÉCURITÉ - Mettre en place un serveur de gestion des mises à jour WSUS    
A venir  

## 3. SÉCURITÉ - Mettre en place un serveur bastion GUACAMOLE    

### 3.1 Création VM dans proxmox  
Debian12 core    
RAM : 2Go   
Core : 2  
Disque : 20Go   

### 3.2 Installation des dépendances    
``` sudo apt update && sudo apt upgrade -y  
sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavformat-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev
sudo apt install tomcat10 default-mysql-server default-mysql-client
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.4.0.tar.gz
tar -xf mysql-connector-j-8.4.0.tar.gz
sudo cp mysql-connector-j-8.4.0/mysql-connector-j-8.4.0.jar /usr/share/tomcat10/lib/
```

### 3.2 Installation des dépendances    
A venir  

## 4. WEB - Mettre en place un serveur WEB    

### 4.1 Création CT dans proxmox  
- Création CT  
Ajouter ID, hostname, password, ressource pool  
Choisir le template Debian dans Local   
Disque : 20Go  
Core : 2  
Memory : 2096  
Network : ajouter vmbr 1 -> ajouter IP (dans la DMZ, donc ici 10.10.20.3/24) et vmbr 100 -> ajouter IP ( 192.168.240.id vm/24)   

### 4.2 Installation Apache2   

#### 4.2.1 Mise à jour + installation apache2  
``` bash
apt update && apt upgrade -y  
apt install apache2 -y  
systemctl status apache2  
```

#### 4.2.2 Rappel des fichiers  
- /var/www/html/index.html -> contenu du site  
- /etc/apache2/sites-availables/000-default.conf -> fichier de configuration  
Ce fichier de configuration pointe vers un numéro de VirtualHost (le port d'écoute du site) , vers le serverAdmin (adresse email de l'admin, sinon par défault : webmaster@localhost) et le DocumentRoot (le dossier racine du site, par exemple /var/www/html/index.html)  

#### 4.2.3 Création d'un répertoire pour chaque site (internet.local et intranet.local) avec son contenu  

Pour le site internet :  
``` bash
mkdir /var/www/internet  
nano /var/www/internet/index.html  
```

et ajouter le contenu  

Par exemple:  
``` <!DOCTYPE html>  
<html lang="fr">  
<head>  
    <meta charset="UTF-8">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
    <title> Pharmgreen</title>  
    <style>  
        body {  
            margin: 0;  
            height: 100vh;  
            background-image: url('https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/60e84108e3d214daba6c139a0b86427dfd6e0e6f/S08/Pharmgreen-Internet.png');  
            background-size: cover;  
            background-position: center;  
            background-repeat: no-repeat;  

            display: flex;  
            justify-content: center;  
            align-items: center;  
            font-family: Arial, sans-serif;  
        }  

        .conteneur {  
            background-color: rgba(255, 255, 255, 0.8);   
            padding: 40px 30px;  
            border-radius: 20px;  
            text-align: center;  
            width: 90%;  
            max-width: 400px;  
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);  
        }  

        .titre {  
            font-weight: bold;  
            font-size: 30px;  
            color: darkgreen;  
            margin: 0;  
        }  

        .sous-titre {  
            font-size: 20px;  
            color: black;  
            margin-top: 30px;  
        }  

        .bouton {  
            margin-top: 40px;  
            padding: 12px 25px;  
            font-size: 16px;  
            background-color: darkgreen;  
            color: white;  
            border: none;  
            border-radius: 10px;  
            cursor: pointer;  
            transition: background-color 0.3s;  
        }  

        .bouton:hover {  
            background-color: #005500;  
        }  

        @media (max-width: 600px) {  
            .titre {  
                font-size: 24px;  
            }  

            .sous-titre {  
                font-size: 18px;  
            }  

            .bouton {  
                width: 100%;  
                padding: 14px;  
            }  
        }  
    </style>  
</head>  
<body>  
    <div class="conteneur">  
        <div class="titre">PHARMGREEN</div>  
        <div class="sous-titre">BIENVENUE</div>  
    </div>  
</body>  
</html>
```  

Pour le site intranet :  
```  mkdir /var/www/intranet  
nano /var/www/intranet/index.html  
```  

et ajouter le contenu  

``` <!DOCTYPE html>  
<html lang="fr">  
<head>  
    <meta charset="UTF-8">  
    <title>Intranet Pharmgreen</title>  
    <style>  
        body {  
            background-image: url('https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/60e84108e3d214daba6c139a0b86427dfd6e0e6f/S08/Pharmgreen-Internet.png');   
            background-size: cover;  
            background-position: center;  
            background-repeat: no-repeat;  
            margin: 0;  
            height: 100vh;  

            display: flex;  
            justify-content: center;  
            align-items: center;  
        }

        .conteneur {  
            background-color: rgba(255, 255, 255, 0.7);   
            padding: 40px;  
            border-radius: 20px;  
            text-align: center;  
        }  

        .titre {  
            font-weight: bold;  
            font-size: 30px;  
            color: darkgreen;  
            margin: 0;  
        }  

        .sous-titre {  
            font-size: 20px;  
            color: black;  
            margin-top: 40px;  
        }  
    </style>  
</head>  
<body>  
    <div class="conteneur">  
        <div class="titre">PHARMGREEN</div>  
        <div class="sous-titre">Espace intranet</div>  
    </div>  
</body>  
</html>  
```  

#### 4.2.4 Création des fichiers de configuration dans /etc/apache2/sites-available  

- pour internet  
```
sudo nano /etc/apache2/sites-available/internet.conf
```  

et ajouter :  
```
<VirtualHost *:80>  
    ServerName internet.local  
    DocumentRoot /var/www/internet  
</VirtualHost>  
```  

- pour intranet  
```
sudo nano /etc/apache2/sites-available/intranet.conf  
```

Et ajouter :  
```
<VirtualHost *:80>  
    ServerName intranet.local  
    DocumentRoot /var/www/intranet  
</VirtualHost>  
```

Activer les sites et relancer apache2  
```
a2ensite internet.conf  
a2ensite intranet.conf  
systemctl reload apache2  
```  

#### 4.2.5 Modification du fichier  
```
sudo nano /etc/hosts  
```

ajoute :  
```
<ip serveur> internet.local  
<ip serveur> intranet.local
```

Les deux sites doivent être disponible avec les URL : http://internet.local et http://intranet.local (attention accès aux sites depuis un ordinateur dans le même réseaux local seulement pour le moment)    

![Site Internet](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/43b1a426ca0dd39e8ddb6b75eba22f654258bb82/S08/Pharmgreen-Internet.png)  

![Site intranet](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/88d13129102b617529d471cb31db8ba5add217b1/S08/Pharmgreen-Intranet.png)  

#### 4.2.6 Rendre accessible le site Internet depuis le WAN  
A venir  

## 5. Reprise anciens objectifs  

### 5.1 Installation de Vyos  
- Création d'une VM   
2Go RAM / 4 cores / 32Go disque dur  

- Ajouter les networks  
vmbr1 : accès aux VLAN (en 172.16.20.0/27)  
vmbr6 : accès au LAN (en 192.168.200.0/24)  

- Ajouter l'image  
vyos-1.1.iso  

- Allumer la machine et s'identifier avec : vyos/vyos (id/mdp)  

- Lancer l'installation  
```
install image   
```

- Sur le clavier taper : touche entrée  -> entrée -> yes -> entrée -> vyos  

- Renseigner un mot de passe pour l'utilisateur Vyos, puis confirmer une seconde fois  

- Sur le clavier taper : touche entrée  

- A la fin de l'installation, redemarrer la machine et retirer l'ISO 
```
reboot
```  

- S'identifier (vyos/vyos), entrer en mode configuration et procéder à l'identification des cartes réseaux (eth0, eth1 ...)  
```    
configure   
ip a  
```
 
### 5.2 Configuration de la carte eth0 (avec VLANs) vmbr1  
```  
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
```

### 5.3 Configuration de la carte eth1 (LAN point à point) vmbr6  
```
set interfaces ethernet eth1 address 192.168.200.1/24  
set interfaces ethernet eth1 description 'LAN'
```  

### 5.4 Route par défaut  
```
set protocols static route 0.0.0.0/0 next-hop '192.168.200.1'  
```

### 5.5 Mise en place des règles de trafic entrant et sortant  
```  
#### 5.5.1 VLAN10  
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

#### 5.5.2 VLAN20   
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

#### 5.5.3 VLAN30  
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

#### 5.5.4 VLAN40  
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

#### 5.5.5 VLAN50  
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

#### 5.5.6 VLAN60  
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

#### 5.5.7 VLAN70  
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
```

### 5.6 Application des règles aux interfaces correspondantes   
```  
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
```

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
  vmbr1 (ne pas mettre d'autres vmbr, cela pourrait empecher la connexion)


## 6. Configuration PFsense  

### 6.1 Ajout d'une route statique pour les VLANs 
Depuis l'interface graphique, aller dans System -> Routing -> Static Routes  
Ajouter Destination réseau : 172.16.20.0/24 (ou plusieurs /27)  
Passerelle : 192.168.200.1  

### 6.2 Ajout d'une règle d’autorisation sur l’interface vmbr6 "LAN vers VyOS" :  
Aller dans : Firewall -> Rules -> vmbr6/LAN  
    Action : Pass  
    Source : 172.16.20.0/24  
    Destination : any  
    Protocol : any  

### 6.3 Ajout d'une règle d’autorisation : any -> This firewall - ICMP  
Aller dans : Firewall -> Rules -> vmbr6/LAN  
    Action : Pass  
    Interface : LAN  
    Protocol : ICMP  
    Source : 192.168.200.0/24  
    Destination : This Firewall  

### 6.4 Test depuis VLAN   
ping 192.168.200.1 (test interface Vyos)  

ping 192.168.200.254 (test interface pfSense)  #  bloqué ici  
ping 8.8.8.8 (test connection internet)  
dig google.com (test DNS)  
