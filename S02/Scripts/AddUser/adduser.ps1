######################################################################################################
#                                                                                                    #
#   Cr�ation USER automatiquement avec fichier (avec gestion des doublons de SamAccountName)         #
#   Reprise script de Zineb et adaptation par Pauline                                                #
######################################################################################################


# Path du fichier CSV
$pwdpath = Get-Location
$File = "$($pwdpath.Path)\S01_Pharmgreen.csv"

### Main program
$Domain = (Get-ADDomain).DistinguishedName

Clear-Host
If (-not(Get-Module -Name activedirectory)) {
    Import-Module activedirectory
}

$Users = Import-Csv -Path $File -Delimiter "," -Header "civilite","prenom","nom","societe","site","departement","service","fonction","manager-prenom","manager-nom","nom de pc","marque pc","date de naissance","telephone fixe","telephone portable" -Encoding UTF8 | Select-Object -Skip 1

# R�cup�rer tous les SamAccountName existants dans AD
$ADUsers = Get-ADUser -Filter * -Properties SamAccountName
$existingSamAccountNames = $ADUsers | Select-Object -ExpandProperty SamAccountName

$count = 1

Foreach ($User in $Users) {
    Write-Progress -Activity "Cr�ation des utilisateurs dans l'OU" -Status "% effectu�" -PercentComplete ($Count/$Users.Length*100)

    $Name        = "$($User.nom) $($User.prenom)"
    $DisplayName = "$($User.nom) $($User.prenom)"
    
    # Cr�ation du SamAccountName de base
    $baseSamAccountName = ($User.prenom.Substring(0,1) + $User.nom).ToLower()

    # V�rifie s�il y a un doublon et ajoute un num�ro uniquement si n�cessaire
    $SamAccountName = $baseSamAccountName
    $i = 1
    while ($existingSamAccountNames -contains $SamAccountName) {
        $SamAccountName = "$baseSamAccountName$i"
        $i++
    }
    $existingSamAccountNames += $SamAccountName  # Ajouter pour �viter les doublons dans la m�me session

    # G�n�ration de l'UPN bas� sur le SamAccountName
    $UserPrincipalName = "$SamAccountName@$((Get-ADDomain).Forest)"

    # Reste des attributs
    $GivenName         = $User.prenom
    $Surname           = $User.nom
    $EmailAddress      = $UserPrincipalName
    $Path              = "ou=" + "$($User.service)" + ",ou=" + "$($User.departement)" + ",$Domain"
    $Company           = "$($User.societe)"
    $Site              = "$($User.site)"
    $Department        = "$($User.departement)"
    $Service           = "$($User.service)"
    $Fonction          = "$($User.fonction)"
    $NomPC             = "$($User.'nom de pc')"
    $DateNaissance     = "$($User.'date de naissance')"
    $TelephoneFixe     = "$($User.'telephone fixe')"
    $TelephonePortable = "$($User.'telephone portable')"

    # Cr�er l'utilisateur dans AD
    New-ADUser `
        -Name $Name `
        -DisplayName $DisplayName `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UserPrincipalName `
        -GivenName $GivenName `
        -Surname $Surname `
        -EmailAddress $EmailAddress `
        -Path "$Path" `
        -AccountPassword (ConvertTo-SecureString -AsPlainText 'Azerty1*' -Force) `
        -Enabled $true `
        -Company $Company `
        -Department $Department `
        -Title $Fonction `
        -Office $Site `
        -ChangePasswordAtLogon $true `
        -OfficePhone $TelephoneFixe `
        -MobilePhone $TelephonePortable

    Write-Host "Cr�ation du USER $SamAccountName" -ForegroundColor Green

    $Count++
    Start-Sleep -Milliseconds 100
}
