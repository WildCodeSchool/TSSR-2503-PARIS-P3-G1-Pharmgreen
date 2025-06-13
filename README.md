# Projet Pharmgreen - Sprint 5

## 1. Présentation du projet

Pharmgreen est une entreprise innovante dans le domaine des solutions IoT dédiées à la gestion intelligente de l’énergie et des ressources. L'objectif de ce projet est de mettre en place une nouvelle infrastructure réseau pour soutenir la croissance de l'entreprise et répondre aux besoins de ses 251 talents.

## 2. Objectifs finaux du projet

Le projet a pour but de créer une infrastructure réseau solide, évolutive et sécurisée. Ce sprint couvre l’amélioration de la sécurité réseau, la gestion des accès et le renforcement des services d’infrastructure.

## 3. Introduction : Mise en contexte

La société Pharmgreen connaît une croissance rapide et doit améliorer son infrastructure réseau pour mieux gérer ses 7 départements. Ce sprint s’inscrit dans la continuité des précédents, avec un accent mis sur la **sécurité**, la **gestion des droits d’accès**, et le **renforcement des services DHCP et DMZ**.

## 4. Membres du groupe de projet

- Scrum Master : Mohamed  
- Product Owner : Pauline
- Développeurs : Omar, Presillia

## 5. Choix techniques

- OS utilisés : Windows Server 2022 pour les serveurs, Windows 10 pour les clients.  
- Hyperviseur : Proxmox pour la gestion des machines virtuelles.  
- Outils utilisés : Packet Tracer pour la simulation réseau, GitHub pour la gestion de la documentation et du code, draw.io pour la création du plan schématique réseau.

## 6. Difficultés rencontrées

- GPO de sécurité : ajustement du filtrage pour éviter que certaines GPO ne s’appliquent à `srv-AD`.  
- Droits Active Directory : configuration précise des groupes pour gérer les autorisations de connexion et de modification des GPO.  
- Configuration DHCP relay : ajout de règles spécifiques sur pfSense pour relayer correctement les requêtes DHCP.

## 7. Solutions trouvées

- Mise en place de règles spécifiques dans pfSense pour activer le relais DHCP.  
- Création de groupes de sécurité spécifiques dans l’Active Directory pour :  
  - autoriser la connexion au serveur AD sans utiliser le compte Administrator  
  - permettre la création et liaison de GPO  
- Revue des GPO avec filtrage précis basé sur les groupes de sécurité.  
- Ajout de règles de sécurité spécifiques pour la DMZ.

## 8. Travaux réalisés

- Ajout de nouvelles règles concernant la DMZ  
  Réalisé 100%

- Reprise des GPO de sécurité avec filtrage (groupe de sécurité)  
  Réalisé 100%  
  (reste à affiner pour ne pas appliquer certaines GPO à `srv-AD`)

- Autoriser un groupe de sécurité à se logguer sur le serveur AD  
  Réalisé 100%

- Autoriser un groupe de sécurité à créer et lier des GPO à des OU  
  Réalisé 100%

- Mise en place d’un DHCP relai + ajout de règles dans pfSense  
  Réalisé 100%

## 9. Améliorations possibles

- Finaliser le filtrage GPO pour exclure `srv-AD` des règles inappropriées  
- Automatiser certaines configurations de sécurité via GPO centralisées  
- Documenter les nouveaux groupes et leurs permissions pour assurer la maintenabilité

