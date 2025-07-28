# 🛠️ Guide Utilisateur – Sprint 11 : Installation & Configuration    

## 1. Introduction    
Voici le contenu de ce Readme qui reprends essentiellement les configurations non terminées depuis le début du projet :  
( les configurations ont été ajoutés également dans les Readme de leurs sprints respectifs pour plus de lisibilité)  


**Relation de confiancce entre les 2 AD Pharmgreen - Ecoloklast**  

**Audit ACTIVE DIRECTORY : PingCastle** 
  Analyse des résultats : (Domain Risk Level : 100/100)  
  Effectuer les actions correctives proposées  
  Tendre vers un score de 0%  

**Audit ACTIVE DIRECTORY : Microsoft Security Compliance Toolkit**  
  Analyse du rapport de sécurité  
  Application des paramètres de sécurité recommandées  
  Génération du rapport final  

**Audit SERVEURS LINUX : Tiger**  
  Audit de système Linux/Unix  


**Audit SERVEURS WINDOWS : SYSINTERNAL**  
  AccessChk -> Niveau d'accès d'un utilisateur  
  AccessEnum -> Audit des accès utilisateurs  
  ShareEnum -> Audit des partages de fichiers  
                                 
**Audit SERVEUR WEB :  Nikto**  
  Scanner de vulnérabilitté  
  Correction des failles  



  
## 2. Relation de confiancce entre les 2 AD Pharmgreen - Ecoloklast 

### 2.1 – DNS : Ajouter des redirecteurs conditionnels  

- Ouvrir la console DNS  
- Selectionner zone de transfert conditionnel et en créer une  
- Clic droit sur Zones de recherche directes → Nouvelle zone de transfert conditionnel  
        Nom du domaine distant : Ekoloclast.local   
        Ajouter l'adresse IP du serveur DNS d'Ekoloclast (192.168.9.10)   
- Valider et tester  
ping 192.168.9.10   


### 2.2 - Activer la relation de confiance - A faire sur les deux serveurs pour une relation bidirectionnelle non transitive   

- Ouvrir Domaines et approbations Active Directory / Active Directory Domains and Trusts (domain.msc)  
- Clic droit sur le domaine > Propriétés  
- Aller dans l'onglet Relations d’approbation (Trusts)   
- Selectionner Nouvelle relation de confiance (New Trust)  
    
Dans l'assistant de relation de confiance :  
	Next 
        Nom du domaine distant : Ekoloclast.local  
	Trust type : External Trust  
	Direction of Trusy : Two-way  
	Sides of Trust : Both  
	Username and Password : Entrer les identifiants Administrateur d'Ekoloclast  

## 3. Audit ACTIVE DIRECTORY : PingCastle 

### 3.1 - Télécharger PingCastle 
Aller sur : https://www.pingcastle.com/download et télécharger PingCastle.     
Et extraire le zip.   

### 3.2 - Ouvrir powershell en mode administrateur
Dans Powershell, aller dans le répertoire extrait et :   
```powershell  
.\PingCastle.exe    
``` 
Choix 1 deux fois et indiquer le nom de domaine  

### 3.3 - Vérification  
Ouvrir le fichier : ad_hc_pharmgreen.local dans le répertoire pour voir les failles    
Dans le fichier ci contre, nous pouvons constater un (mauvais) score de 100/100  
![Audit Début](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/0be31bedca27915f40718e74e1dead36bc2d84bd/S11/Audit-AD-1.png)  

### 3.4 - Rechercher les anomalies et les modifier en conséquence  

En loccurence, dans notre cas : 

- Modification droits du groupe "authenticated user" dans les ACL de chaque GPO (dans delegation -> Advanced)   
Seulement Read et Apply   

- Activer : Account is sensitive and cannot be delegated dans Users and computers (ou Set-ADUser -Identity "pprak" -AccountNotDelegated $true)  

- Activer corbeille Enable-Adoptionnalfeature -identity "recycle bin feature" -scope ForestorConfigurationSet -Target "pharmgreen.local"  

- Retirer "Administrator" du groupe "Schema Admin" pour empecher une modification du schema   

- activer "Envoyer une réponse NTLMv2 uniquement" dans : -secpol.msc -> Stratégies locales -> Options de sécurité  

- modifier la taille minimum de mot de passe dans la GPO "Default Domain Policy"   

### 3.5 - Résultat final  
Après reprise des anomalies, nous pouvons constater sur l'image ci dessous que le score est meilleur (40/100) 
![Audit Fin](https://github.com/WildCodeSchool/TSSR-2503-PARIS-P3-G1-Pharmgreen/blob/cb35611ad00a6dd2a849c4b2a9d8338bfb75d822/S11/Audit-AD-2.png)  

## 4. Audit ACTIVE DIRECTORY : Microsoft Security Compliance Toolkit  

## 5. Audit SERVEURS LINUX : Tiger  

# 🐯 Audit de sécurité Linux avec Tiger

## 🎯 Objectif 

Réaliser un audit de sécurité sur un ou plusieurs serveurs Linux à l’aide du logiciel Tiger, afin de détecter d’éventuelles failles, mauvaises configurations ou pratiques non sécurisées. Cet objectif vise à acquérir des compétences en sécurisation des systèmes Unix/Linux à travers un outil d’audit automatisé.

---

## 🛠️ Outil utilisé

### 🔹 Tiger – Unix Security Audit Tool

- Site officiel : [https://www.nongnu.org/tiger/](https://www.nongnu.org/tiger/)
- Fonction : Audit local de la sécurité sur un système Unix/Linux
- Type d’analyse : Permissions, utilisateurs, rootkits, services, configurations, fichiers suspects…

---

## 🧩 Environnement d’audit

- **Machine auditée** : SRV-FTP (Debian 12)
- **Environnement** : Proxmox VE
- **Espace disque** : 31 Go
- **Audit local exécuté en root**

---

## 🚀 Étapes réalisées

### 1. Installation de Tiger

```bash
sudo apt update
sudo apt install tiger -y
```

> 💡 Problème rencontré : disque saturé (100%).  
> ✅ Solution : ajout d’un disque secondaire SATA monté sur `/home`.

---

### 2. Lancement de l’audit

```bash
sudo tiger
```

Tiger génère un rapport dans :

```bash
/var/log/tiger/security.report.*
```

---

### 3. Analyse des résultats

```bash
grep -E "ALERT|WARNING" /var/log/tiger/security.report.*
```

#### 🔍 Résumé des alertes rencontrées

| Niveau   | Code        | Description                                    | Statut       |
|----------|-------------|------------------------------------------------|--------------|
| ALERT    | `perm023a`  | `/bin/su` et `/usr/bin/passwd` sont `setuid`  | ✅ Comportement normal |
| ALERT    | `fsys006a`  | Fichiers spéciaux inattendus (`device files`) | 🔍 En cours d’analyse |

---

## ✅ Bilan

L’outil **Tiger** a permis de :
- Vérifier la conformité des permissions critiques
- Identifier les comportements système potentiellement dangereux
- Détecter des fichiers inhabituels pour approfondir l’analyse

---

## 📎 À faire

- Poursuivre l’analyse des fichiers `device` inattendus
- Documenter les actions correctives appliquées
- Intégrer Tiger dans une politique d’audit régulière


## 6. Audit SERVEURS WINDOWS : SYSINTERNAL 
                             
## 7. Audit SERVEUR WEB :  Nikto  
