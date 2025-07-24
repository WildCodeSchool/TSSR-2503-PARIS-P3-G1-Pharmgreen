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

### 2.1 - Rappel architecture réseau   

#### 2.1.1 - Site A - Pharmgreen   
WAN pfSense	192.168.240.48/24   
LAN pfSense	192.168.1.0/24   
Tunnel VPN	10.0.8.1  

#### 2.1.2 - Site B - Ekoloclast
WAN pfSense	192.168.240.192   
LAN pfSense	192.168.200.1  
Tunnel VPN        10.0.8.2  

### 2.2 - Configuration du serveur VPN (Site A – pfSense)  

#### 2.2.1 - Création du serveur OpenVPN   
- Accéder à l’interface web de pfSense (Site A)  
- Aller dans VPN > OpenVPN > Servers et cliquez sur + Add  
- Paramètres à configurer :
	Server mode : Peer to Peer (Shared Key)  
	Protocol : UDP on IPv4 only  
	Device mode : tun   
	Interface : WAN  
	Local port : 1194   
	Description : VPN vers Site B   
	Shared Key : Automatically generate   
	Encryption Algorithm : AES-256-GCM   
	Auth digest algorithm : SHA256   
	IPv4 Tunnel Network : 10.0.8.1  
	IPv4 Remote Network : ??  
	
#### 2.2.2 - Récupération de la clé partagée  
Retourner dans la liste des serveurs, éditez celui créé.  
Copier l'intégralité de la clé dans la case Shared Key (-----BEGIN OpenVPN Static key V1-----)  
Transmettre la clef au Site B de façon sécurisée   


### 2.3 - Configuration du serveur VPN (Site B – pfSense)  

#### 2.3.1 - Création du client OpenVPN  
- Accéder à l’interface web de pfSense (Site B)   
- Aller  dans VPN > OpenVPN > Clients et cliquez sur + Add   
- Paramètres à configurer :  
	Server mode : Peer to Peer (Shared Key)  
	Protocol : UDP on IPv4 only  
	Device mode : tun  
	Interface : WAN  
	Server host or address : IP publique du Site A  
	Server port : 1194  
	Shared Key : Automatically generate → Coller la clé reçue  
	Encryption Algorithm : AES-256-GCM  
	Auth digest algorithm : SHA256  
	IPv4 Tunnel Network : 10.0.8.2  
	IPv4 Remote Network(s)	??  

### 2.4- Configuration des routes et du NAT  

#### 2.4.1 - Route statique sur pfSense/VyOS  
Sur le routeur VyOS, ajoutez une route vers le réseau distant (Site B) via l’IP de pfSense sur l’interface connectée à VyOS :  
set protocols static route 192.168.2.0/24 next-hop 10.0.0.1  
commit  
save  
    
#### 2.4.2 - NAT sur pfSense (Site A)    
- Aller dans Firewall > NAT > Outbound    
- Activer le mode Hybrid Outbound NAT    
- Créer une règle :    
	Interface : OpenVPN  
	Source : 10.0.0.0/24  

### 2.5 - Configuration des règles de pare-feu (sur les 2 PFsense)   
- Aller dans Firewall > Rules > OpenVPN   
- Cliquer sur + Add   
- Configurer :  
	Action	: Pass  
	Interface : OpenVPN  
	Protocol : Any  
	Source : Any  
	Destination : Any  
	Description : Autoriser tout trafic VPN  

### 2.6 -  Vérifications et tests  

#### 2.6.1 - Vérifier le statut du VPN   
Aller dans Status > OpenVPN sur les deux pfSense  
Le tunnel doit apparaître "up" (en vert)  

#### 2.6.2 - Test de connectivité  
Depuis un poste du réseau Site A (192.168.1.x), pinguez un hôte du réseau Site B (192.168.2.x)  
Si le ping fonctionne → VPN opérationnel   


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

## 6. Audit SERVEURS WINDOWS : SYSINTERNAL 
                             
## 7. Audit SERVEUR WEB :  Nikto  
