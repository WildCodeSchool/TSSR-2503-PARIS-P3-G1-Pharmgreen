# Projet Pharmgreen - Sprint 1

## 1. Présentation du projet

**Pharmgreen** est une entreprise innovante dans le domaine des solutions IoT dédiées à la gestion intelligente de l’énergie et des ressources. L'objectif de ce projet est de mettre en place une nouvelle infrastructure réseau pour soutenir la croissance de l'entreprise et répondre aux besoins de ses 251 talents.

## 2. Objectifs finaux du projet

Le projet a pour but de créer une infrastructure réseau solide, évolutive et sécurisée. Ce premier sprint couvre la mise en place de la planification réseau, l'adressage, ainsi que la définition des ressources matérielles nécessaires à l'implantation futur.

## 3. Introduction : Mise en contexte

La société **Pharmgreen** connaît une croissance rapide et doit améliorer son infrastructure réseau pour mieux gérer ses 7 départements. Ce projet s'inscrit dans le cadre d'une mise à jour de l'infrastructure réseau, en visant une approche plus sécurisée et une meilleure gestion de la communication entre les différents services.

## 4. Membres du groupe de projet

- **Scrum Master**: Mohamed
- **Product Owner**: Priscilla
- **Développeurs**: Omar, Pauline
  
## 5. Choix techniques

- **OS utilisés** : Windows Server 2022 pour les serveurs, Windows 10 pour les clients.
- **Hyperviseur** : Proxmox pour la gestion des machines virtuelles.
- **Outils utilisés** : Packet Tracer pour la simulation réseau, GitHub pour la gestion de la documentation et du code, **draw.io** pour la création du plan schématique réseau.

## 6. Difficultés rencontrées

- **Plan schématique** : Difficulté à choisir entre Cisco Packet Tracer et GNS3, en raison de limitations des deux outils pour représenter un réseau complet. Finalement, le choix s'est porté sur **draw.io** pour la création du plan schématique.
- **Matériel adapté** : Le matériel nécessaire pour installer Windows Server ou des ordinateurs portables n'était pas disponible de base dans l'environnement de test.
- **VM/CT** : Difficulté dans le choix entre machines virtuelles (VM) et conteneurs (CT) pour les serveurs (sauvegarde, fichier). Les VMs ont été privilégiées pour la flexibilité et la gestion des rôles multiples.
- **GUI vs Core** : Choix entre une interface graphique (GUI) et une version core pour les serveurs. Les versions avec GUI sont plus gourmandes en ressources, mais plus intuitives. Une décision a été prise de privilégier une version avec GUI pour le serveur Active Directory et la messagerie pour faciliter l’administration et l’utilisation.

## 7. Solutions trouvées

- Utilisation de **draw.io** pour la création du plan réseau détaillé.
- Choix des **VM** pour leur flexibilité et gestion des différentes fonctions.
- Préférence pour le **GUI** sur Active Directory et messagerie pour simplifier les tâches d'administration.

## 8. Améliorations possibles

- Création domaine + arborescence 
- Finaliser les VM/CT servers + clients 
