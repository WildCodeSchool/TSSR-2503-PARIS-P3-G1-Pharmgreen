# Installation et Configuration - Sprint 1

## 1. Prérequis techniques

- **Hyperviseur** : Proxmox
- **Systèmes d'exploitation** : 
  - Windows Server 2022 pour les serveurs
  - Windows 10 pour les clients
- **Logiciels nécessaires** : 
  - Packet Tracer (pour la simulation réseau)
  - GitHub (pour la gestion de la documentation)
  - **draw.io** (pour la création de diagrammes et schémas)
  
## 2. Étapes d'installation et de configuration

1. **Serveur Active Directory (AD)** :
   - Créez une VM avec Windows Server 2022.
   - Installation des cartes réseaux.
   
2. **Clients (Windows 10)** :
   - Créez des VM Windows 10 pour chaque utilisateur.
   - Installation des cartes réseaux.

### 2.3. Configuration IP et VLAN

1. **Adresses IP** :
   - Utilisez les plages définies dans le plan d'adressage IP pour attribuer les adresses IP aux serveurs et clients.
   
2. **VLAN** :
   - Configurez les VLANs sur les switchs virtuels dans Proxmox pour séparer les départements.

## 3. FAQ

### Q: Comment attribuer des adresses IP dans Proxmox ?
Allez dans la configuration de chaque VM et assignez l'adresse IP appropriée selon le plan d'adressage.

### Q: Comment créer un VLAN dans Proxmox ?
Allez dans les paramètres réseau de la VM et créez un VLAN en définissant un ID unique pour chaque VLAN.
