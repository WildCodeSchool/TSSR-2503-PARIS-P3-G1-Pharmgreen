# 🛠️ Guide Utilisateur – Sprint 6 : Installation & Configuration  

## 1. Introduction  
Voici le contenu de ce Readme :  

**Mise en place RAID 1**   

**SUPERVISION - Mise en place d'une supervision de l'infrastructure réseau : ZABBIX**  
Installation sur VM/CT dédié  
Supervision des éléments de l'infrastructure (actuels et à venir)  
Mise en place de dashboard  

**AD - Nouveau fichier RH pour les utilisateurs de l'entreprise**
Adapter le script initial pour l'intégration des nouveaux utilisateurs et modifs infos 


## 2. Mise en place RAID 1 - Srv-AD1  

### - Étape 1 – Ajouter deux disques à la VM dans Proxmox  
Aller dans l'interface web de Proxmox  
Sélectionne la VM : P3-G1-WinServ22-GUI-SRV-AD1-SchemaMaster  
Aller dans l'onglet Hardware -> Add -> Hard Disk  
Ajouter deux nouveaux disques de 50Go, dans "local-lvm", selectionne "Interface SCSI"  
Redémarrer la VM si nécessaire  

### - Étape 2 – Configurer le RAID 1 dans Windows Server 2022  
Ouvrir le Gestionnaire de disques  
Windows détectera les nouveaux disques  
Initialiser les deux disques en GTP  
Convertir les deux disques en disque dynamique  
Clique droit sur l’un des deux disques → "Nouveau volume en miroir"  
Suivre l’assistant  
Ajouter le second disque comme miroir  
Attribuer une lettre de lecteur (ex. E:)  
Formater le disque en NTFS  
Attendre la fin du formatage  

### - Vérification du RAID  
Dans le Gestionnaire de disques : les deux disques apparaissent comme "Volume en miroir"  
L'état doit être "OK" 


## 3. SUPERVISION - Mise en place d'une supervision de l'infrastructure réseau : ZABBIX  

### Installation sur VM/CT dédié   

- MAJ et Installation du serveur Zabbix  
``` bash  
apt update && apt upgrade -y  
wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb  
dpkg -i zabbix-release_latest_7.2+debian12_all.deb  
```

- Installation de Zabbix server, du frontend, et de l'agent :  
``` bash  
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent  
```

- Installation du SGBD :  
``` bash  
apt install mariadb-server  
```

- Vérification du SGBD :  
``` bash  
systemctl status mysql  
```

- Création et configuration de la base de données : (ne pas oublier de personnaliser nom et mdp)  
``` mysql  
mysql -uroot -p   
reate database zabbix character set utf8mb4 collate utf8mb4_bin;  
create user zabbix@localhost identified by 'password';  
grant all privileges on zabbix.* to zabbix@localhost;  
set global log_bin_trust_function_creators = 1;  
quit;  
```

- Importation du schéma et des données :  
``` bash  
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix  
```

- Désactivation de la possibilité de modifier la configuration de la BD par des acteurs malveillants :  
``` mysql  
mysql -uroot -p  
set global log_bin_trust_function_creators = 0;  
quit;  
```

- Edition du fichier de configuration de la BD du serveur Zabbix dans /etc/zabbix/zabbix_server.conf :  
DBPassword=password  

- Configuration de PHP pour accéder au frontend dans /etc/zabbix/nginx.conf :  
listen 8080;  
server_name <ici tu rentreras l'adresse IPv4 de ta machine>;  

- Démarrage du server et des processus de l'agent :   
``` bash  
systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm  
systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm  
```

### Supervision des éléments de l'infrastructure (actuels et à venir)   

#### 1. Sur les machines Debian 12 à superviser  
🔹 Étape 1 : Installer l'agent Zabbix  

sudo apt update  
sudo apt install zabbix-agent -y  

🔹 Étape 2 : Configurer l’agent  

Édite le fichier de config :  
sudo nano /etc/zabbix/zabbix_agentd.conf  

Modifie les lignes suivantes :  
Server=192.168.1.X         # IP du serveur Zabbix  
ServerActive=192.168.1.X   # Idem  
Hostname=debian-client     # Un nom unique (doit correspondre à celui que tu mettras dans l’interface web)  

🔹 Étape 3 : Redémarrer et activer le service  

sudo systemctl restart zabbix-agent  
sudo systemctl enable zabbix-agent  

🔹 Tester la connectivité  

Depuis le serveur Zabbix :  
telnet 192.168.1.Y 10050  

Tu dois avoir un écran vide (connexion OK).  


#### 2. Sur les machines Windows à superviser  

🔹 Étape 1 : Télécharger l’agent Zabbix  
    Va ici : https://www.zabbix.com/download_agents  
    Choisis : Windows -> Architecture : x64 -> Version Zabbix correspondant  
Télécharge le .msi.  

🔹 Étape 2 : Installer l’agent  
    Double-clique sur le .msi  
    Lors de l’installation, renseigne :  
        Zabbix Server : IP de ton serveur Zabbix  
        Hostname : un nom unique, ex. windows-client  
        Laisse le port 10050  

🔹 Étape 3 : Vérifier que l’agent tourne  
Dans les services Windows (services.msc) :  
    Vérifie que Zabbix Agent est en cours d'exécution  
    Autorise le port 10050 dans le pare-feu Windows si besoin  

#### 3. Ajouter les hôtes dans l’interface Zabbix  

Depuis l'interface web Zabbix :  
🔹 Aller dans :  
Configuration → Hosts → Create host  

🔹 Renseigner :  
    Hostname : debian-client ou windows-client (doit correspondre à la conf agent)  
    Groups : crée un groupe ou sélectionne-en un (ex. "Linux servers", "Windows servers")  
    Interfaces :  
        Type : Agent  
        IP : IP de la machine à superviser  
        Port : 10050  

🔹 Appliquer un Template :  
Clique sur l’onglet Templates, puis :  
        Pour Debian :  
          Template OS Linux by Zabbix agent  
        Pour Windows :  
          Template OS Windows by Zabbix agent  
