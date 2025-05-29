# Fonction pour ajouter des guillemets autour de chaque champ
function Ajouter-Guillemets {
    param ([String]$String)

    if ($String -match '\s') {
        return '"' + $String + '"'
    } else {
        return $String
    }
}

# Fonction pour nettoyer les caractères spéciaux (accents, cédilles, etc.)
function Nettoyer-CaracteresSpeciaux {
    param ([String]$String)

    # Remplacer les caractères accentués
    $String = $String -replace '[éèêë]', 'e'
    $String = $String -replace '[àáâä]', 'a'
    $String = $String -replace '[îï]', 'i'
    $String = $String -replace '[ôö]', 'o'
    $String = $String -replace '[ùûü]', 'u'
    $String = $String -replace '[ç]', 'c'

    # Convertir en minuscules
    $String = $String.ToLower()

    return $String
}

# Fonction pour formater le CSV
function Formater-CSV {
    
    # Récupérer le chemin du fichier CSV (situé dans le même répertoire que le script)
    #$pwdpath = Get-Location
    #$file = "$($pwdpath.Path)\S01_Pharmgreen.csv"
    
    $file = ".\s01_Pharmgreen.csv"
    
    # Lire toutes les lignes du fichier CSV
    $lignes = Get-Content $file -Encoding UTF8

    # Traiter chaque ligne
    $lignesModifiees = $lignes | ForEach-Object {
        # Découper la ligne en champs
        $champs = $_ -split ','

        # Formater chaque champ :
        $champsFormates = $champs | ForEach-Object {
            if ($_ -eq "") {
                # Si le champ est vide, remplacer par "-"
                return "-"
            } else {
                # Nettoyer les caractères spéciaux et ajouter des guillemets
                $nettoye = Nettoyer-CaracteresSpeciaux $_
                return Ajouter-Guillemets $nettoye
            }
        }

        # Recomposer la ligne avec les champs modifiés
        $champsFormates -join ','
    }

    # Écrire les lignes modifiées dans le fichier CSV
    $lignesModifiees | Set-Content -Path $file -Encoding UTF8
}

# Appeler la fonction de formatage
Formater-CSV

Write-Host "Le fichier CSV a été formaté avec succès !" -ForegroundColor Green
