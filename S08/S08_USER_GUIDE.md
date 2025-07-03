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

## 3. SÉCURITÉ - Mettre en place un serveur bastion GUACAMOLE    

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
apt update && apt upgrade -y  
apt install apache2 -y  
systemctl status apache2  

#### 4.2.2 Rappel des fichiers  
- /var/www/html/index.html -> contenu du site  
- /etc/apache2/sites-availables/000-default.conf -> fichier de configuration  
Ce fichier de configuration pointe vers un numéro de VirtualHost (le port d'écoute du site) , vers le serverAdmin (adresse email de l'admin, sinon par défault : webmaster@localhost) et le DocumentRoot (le dossier racine du site, par exemple /var/www/html/index.html)  

#### 4.2.3 Création d'un répertoire pour chaque site (internet.local et intranet.local) avec son contenu  

Pour le site internet :  
mkdir /var/www/internet  
nano /var/www/internet/index.html  

et ajouter le contenu  

Par exemple:  
``` <!DOCTYPE html>  
<html lang="fr">  
<head>  
    <meta charset="UTF-8">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
    <title> Pharmgreen</title>  
    <style>  
        /* Corps de la page */  
        body {  
            margin: 0;  
            height: 100vh;  
            background-image: url('https://via.placeholder.com/1200x800'); /* Remplace cette URL par la tienne */  
            background-size: cover;  
            background-position: center;  
            background-repeat: no-repeat;  

            display: flex;  
            justify-content: center;  
            align-items: center;  
            font-family: Arial, sans-serif;  
        }  

        /* Conteneur central */  
        .conteneur {  
            background-color: rgba(255, 255, 255, 0.8); /* Fond semi-transparent */  
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

![Site Internet](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/88d13129102b617529d471cb31db8ba5add217b1/S08/Pharmgreen-Internet.png)nn

Pour le site intranet :  
mkdir /var/www/intranet  
nano /var/www/intranet/index.html  

et ajouter le contenu  

``` <!DOCTYPE html>  
<html lang="fr">  
<head>  
    <meta charset="UTF-8">  
    <title>Intranet Pharmgreen</title>  
    <style>  
        /* Corps de la page */  
        body {  
            background-image: url('https://via.placeholder.com/1200x800'); /* Remplace par ton image */  
            background-size: cover;  
            background-position: center;  
            background-repeat: no-repeat;  
            margin: 0;  
            height: 100vh;  

            display: flex;  
            justify-content: center;  
            align-items: center;  
        }

        /* Conteneur avec fond semi-transparent */  
        .conteneur {  
            background-color: rgba(255, 255, 255, 0.7); /* blanc semi-transparent */  
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
            margin-top: 40px; /* Équivalent à deux sauts de ligne */  
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
![Site intranet](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/88d13129102b617529d471cb31db8ba5add217b1/S08/Pharmgreen-Intranet.png)  

#### 4.2.4 Création des fichiers de configuration dans /etc/apache2/sites-available  

- pour internet  
sudo nano /etc/apache2/sites-available/internet.conf  

et ajouter :  
<VirtualHost *:80>  
    ServerName internet.local  
    DocumentRoot /var/www/internet  
</VirtualHost>  

- pour intranet  
sudo nano /etc/apache2/sites-available/intranet.conf  

Et ajouter :  
<VirtualHost *:80>  
    ServerName intranet.local  
    DocumentRoot /var/www/intranet  
</VirtualHost>  

Activer les sites et relancer apache2  
 a2ensite internet.conf  
 a2ensite intranet.conf  
 systemctl reload apache2  


#### 4.2.5 Modification du fichier  
sudo nano /etc/hosts  

ajoute :  
<ip serveur> internet.local  
<ip serveur> intranet.local  

Les deux sites doivent être disponible avec les URL : http://internet.local et http://intranet.local (attention accès aux sites depuis un ordinateur dans le même réseaux local seulement)    


## 5. Reprise anciens objectifs  

