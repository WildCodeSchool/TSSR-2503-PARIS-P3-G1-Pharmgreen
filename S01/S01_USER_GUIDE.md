# Guide de l'Utilisateur - Installation et Configuration - Sprint 1

## 1. Introduction

Ce guide présente les étapes nécessaires à l'installation et à la configuration de l'infrastructure réseau de Pharmgreen, ainsi que les fonctionnalités clés et les options avancées disponibles dans l'environnement virtuel. Ce document couvre la mise en place du serveur Active Directory (AD) et la configuration des clients sous Windows 10, ainsi que la gestion des adresses IP et des VLAN dans Proxmox.

## 2. Utilisation de base

### 2.1 Installation du Serveur Active Directory

1. **Création de la VM Windows Server 2022 :**
   - Créez une nouvelle machine virtuelle dans Proxmox en sélectionnant `Windows Server 2022` comme système d'exploitation.
   - Attribuez les ressources nécessaires (CPU, RAM, stockage) selon les exigences du projet.

2. **Installation du rôle Contrôleur de Domaine Active Directory :**
   - Une fois le système d'exploitation installé et configuré, ouvrez le gestionnaire de serveur.
   - Allez dans **Ajouter des rôles et des fonctionnalités**, puis sélectionnez **Contrôleur de domaine Active Directory**.
   - Suivez les instructions pour promouvoir le serveur en contrôleur de domaine et rejoignez-le au domaine souhaité (par exemple `lab.lan`).

### 2.2 Configuration des Clients Windows 10

1. **Création des VM Windows 10 :**
   - Créez une machine virtuelle pour chaque utilisateur en utilisant Windows 10 comme système d'exploitation.
   - Assurez-vous que les ressources allouées à chaque VM respectent les besoins de l'utilisateur.

2. **Rejoindre le Domaine :**
   - Sur chaque VM Windows 10, allez dans **Panneau de configuration > Système et sécurité > Système**.
   - Sous **Paramètres du nom de l'ordinateur**, cliquez sur **Modifier les paramètres**.
   - Cliquez sur **Modifier**, puis sélectionnez **Domaine** et entrez le nom du domaine (`lab.lan`).

### 2.3 Configuration IP et VLAN

1. **Attribution des adresses IP :**
   - Suivez le plan d'adressage IP pour attribuer les adresses appropriées à chaque serveur et client dans l'environnement.
   - Dans Proxmox, allez dans la configuration réseau de chaque VM et attribuez une adresse IP statique en fonction du plan d'adressage.

2. **Configuration des VLANs :**
   - Dans Proxmox, accédez aux paramètres de chaque switch virtuel et créez des VLANs pour séparer les départements (par exemple : VLAN 10 pour le service commercial, VLAN 20 pour le service technique, etc.).
   - Assignez l'ID de chaque VLAN à la VM correspondante selon la structure du réseau.

## 3. Utilisation avancée

### 3.1 Gestion des VLANs dans Proxmox

- **Création et gestion des VLANs :**
   - Accédez à l'interface de gestion Proxmox.
   - Allez dans les paramètres de la VM et configurez les VLANs en définissant un ID unique pour chaque VLAN (par exemple : VLAN 10, VLAN 20, etc.).
   - Pour chaque machine virtuelle, attribuez le bon VLAN en fonction de son rôle (serveur, client, etc.).

- **Vérification du VLAN :**
   - Utilisez la commande `ip a` sur les VMs Linux ou les outils de gestion réseau sur Windows pour vérifier que les VLANs sont correctement configurés et les interfaces réseau affectées.

### 3.2 Gestion des Adresses IP Dynamique

- Si vous préférez une gestion d'adresses IP automatique, vous pouvez configurer un serveur DHCP sur Windows Server 2022 pour attribuer des adresses IP dynamiquement aux clients.
- Pour configurer DHCP, allez dans **Gestionnaire de serveur > Ajouter des rôles et des fonctionnalités**, puis sélectionnez le rôle **Serveur DHCP** et suivez les étapes pour configurer les plages d'adresses.

## 4. FAQ

### Q: Comment vérifier la connexion au domaine depuis une machine cliente ?

Ouvrez l'**Invite de commandes** sur la VM cliente et utilisez la commande `ping` suivie du nom du domaine (par exemple `ping lab.lan`). Si la connexion est réussie, cela signifie que la machine est bien jointe au domaine.

### Q: Que faire si un client ne parvient pas à rejoindre le domaine ?

Vérifiez que l'adresse IP du client est correcte et qu'il utilise le serveur DNS du domaine. Assurez-vous également que le serveur Active Directory est correctement configuré et accessible depuis le client. Vous pouvez tester la résolution DNS avec la commande `nslookup`.
