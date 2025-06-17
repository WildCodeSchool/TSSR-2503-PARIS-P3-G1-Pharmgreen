# 🛠️ Guide Utilisateur – Sprint 6 : Installation & Configuration  

## 1. Introduction  
Voici le contenu de ce Readme :  
**Mise en place RAID 1**   


## - Mise en place RAID 1 - Srv-AD1  

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
