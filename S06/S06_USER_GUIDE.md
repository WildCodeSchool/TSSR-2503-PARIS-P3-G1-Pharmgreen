# 🛠️ Guide Utilisateur – Sprint 6 : Installation & Configuration  

## 1. Introduction  
Voici le contenu de ce Readme :  

**Mise en place RAID 1**   

**Mise en place d’un serveur FTP pour le partage de dossiers** 

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


## 3. Mise en place d’un serveur FTP pour le partage de dossiers

### Objectif

Installer et configurer un serveur FTP (vsftpd) pour permettre aux utilisateurs de partager et d’échanger des fichiers via FTP.

### Étapes détaillées

```bash
1. Installation de vsftpd
sudo apt update
sudo apt install vsftpd -y

2. Création de l’utilisateur FTP dédié

sudo adduser ftpuser
Définir un mot de passe sécurisé.

Cet utilisateur sera utilisé pour se connecter au serveur FTP.

3. Configuration du répertoire FTP
Création de la structure des dossiers pour le partage :

sudo mkdir -p /home/ftpuser/uploads/docs
sudo mkdir -p /home/ftpuser/uploads/projets
sudo mkdir -p /home/ftpuser/uploads/depots
Attribution des droits :

sudo chown -R ftpuser:ftpuser /home/ftpuser/uploads
sudo chmod -R 775 /home/ftpuser/uploads
Pour des raisons de sécurité, le dossier personnel /home/ftpuser doit être non modifiable :

sudo chmod a-w /home/ftpuser

4. Configuration de vsftpd
Modifier le fichier /etc/vsftpd.conf avec les options suivantes (ajouter ou modifier) :

write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
local_umask=022
listen=YES
listen_ipv6=NO
Ces options permettent :

L’écriture dans le dossier FTP,

Le confinement de l’utilisateur dans son répertoire personnel (chroot),

De contourner l’erreur liée à un dossier personnel inscriptible,

L’écoute du service FTP sur IPv4 uniquement.

5. Redémarrage du service FTP

sudo systemctl restart vsftpd

6. Test de connexion FTP
Utiliser un client FTP (FileZilla, Cyberduck, ou en ligne de commande) pour se connecter :

ftp <adresse_IP_du_serveur>
Se connecter avec le login ftpuser et son mot de passe.

Naviguer dans les dossiers /uploads et ses sous-dossiers.

Tester le téléchargement et l’envoi de fichiers.

7. Configuration du pare-feu (si actif)
Autoriser les ports FTP nécessaires :

sudo ufw allow 20,21/tcp
sudo ufw allow 30000:31000/tcp
Cela correspond au port de commande FTP (21), au port de données (20) et à la plage des ports passifs (30000-31000) si configurée.



