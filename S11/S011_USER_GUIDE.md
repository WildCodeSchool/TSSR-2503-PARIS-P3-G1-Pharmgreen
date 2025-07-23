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

### 3.4 - Rechercher les anomalies et les modifier en conséquence  

En loccurence, dans notre cas : 

- Modification droits du groupe "authenticated user" dans les ACL de chaque GPO (dans delegation -> Advanced)   
Seulement Read et Apply   

- Activer : Account is sensitive and cannot be delegated dans Users and computers (ou Set-ADUser -Identity "pprak" -AccountNotDelegated $true)  

- Activer corbeille Enable-Adoptionnalfeature -identity "recycle bin feature" -scope ForestorConfigurationSet -Target "pharmgreen.local"  

- Retirer "Administrator" du groupe "Schema Admin" pour empecher une modification du schema   

- activer "Envoyer une réponse NTLMv2 uniquement" dans : -secpol.msc -> Stratégies locales -> Options de sécurité  

- modifier la taille minimum de mot de passe dans la GPO "Default Domain Policy"   


## 4. Audit ACTIVE DIRECTORY : Microsoft Security Compliance Toolkit  

## 5. Audit SERVEURS LINUX : Tiger  

## 6. Audit SERVEURS WINDOWS : SYSINTERNAL 
                             
## 7. Audit SERVEUR WEB :  Nikto  
