####################################################################################################
#                              Création automatique des OU en deux étapes                          #
#                 1. Crée les OU principales                                                       #
#                 2. Crée les OU enfants (services) sous chaque OU principale                      #
####################################################################################################

# Chargement du module Active Directory
if (-not (Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# Chemin vers le fichier CSV nettoyé

$pwdpath = $($pwd.path)
$File = "$pwdpath/pharmgreen_cleaned.csv"


# Vérifier si le fichier existe
#if (-Not (Test-Path $File)) {
#    Write-Host "❌ Fichier introuvable : $File" -ForegroundColor Red
#    Exit
#}

# Domaine actuel
$Domain = (Get-ADDomain).DistinguishedName

# Importer le CSV
$OUs = Import-Csv -Path $File -Delimiter ";" -Header "OUPrincipales", "OUServices"

### Étape 1 - Créer les OU principales (uniques)
$OUPrincipales = $OUs | Select-Object -ExpandProperty OUPrincipales -Unique

foreach ($ou in $OUPrincipales) {
    if (![string]::IsNullOrWhiteSpace($ou)) {
        $OUPath = "OU=$($ou.Trim()),$Domain"
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue)) {
            try {
                New-ADOrganizationalUnit -Name $ou.Trim() -Path $Domain -ProtectedFromAccidentalDeletion $false
                Write-Host "✅ OU principale créée : $OUPath" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Erreur création OU principale $ou : $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "ℹ️ OU principale déjà existante : $OUPath" -ForegroundColor Yellow
        }
    }
}

### Étape 2 - Créer les OU enfants
foreach ($entry in $OUs) {
    if (![string]::IsNullOrWhiteSpace($entry.OUPrincipales) -and ![string]::IsNullOrWhiteSpace($entry.OUServices)) {
        $Parent = $entry.OUPrincipales.Trim()
        $Child = $entry.OUServices.Trim()
        $ParentPath = "OU=$Parent,$Domain"
        $FullPath = "OU=$Child,$ParentPath"

        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$FullPath'" -ErrorAction SilentlyContinue)) {
            try {
                New-ADOrganizationalUnit -Name $Child -Path $ParentPath -ProtectedFromAccidentalDeletion $false
                Write-Host "✅ OU enfant créée : $FullPath" -ForegroundColor Cyan
            }
            catch {
                Write-Host "❌ Erreur création OU enfant $Child : $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "ℹ️ OU enfant déjà existante : $FullPath" -ForegroundColor Yellow
        }
    }
}
