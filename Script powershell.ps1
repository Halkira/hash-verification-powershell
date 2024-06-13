function Calculer-Hash {
    param (
        [string]$CheminFichier,
        [string]$Algorithme = "SHA256"
    )

    try {
        $stream = New-Object System.IO.FileStream($CheminFichier, [System.IO.FileMode]::Open)
        $hashProvider = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithme)
        $hashBytes = $hashProvider.ComputeHash($stream)
        $hash = [BitConverter]::ToString($hashBytes) -replace '-'
        return $hash
    } catch {
        Write-Host "Erreur lors du calcul du hash pour le fichier $($CheminFichier): $_"
        return $null
    } finally {
        if ($stream) {
            $stream.Close()
            $stream.Dispose()
        }
        if ($hashProvider) {
            $hashProvider.Clear()
        }
    }
}

#J'ai du séparer le dossier des images disques et le restes par question de place
$CheminDossier1 = "PATH IMAGES DISQUES (sha 512)"
$CheminDossier2 = "PATH dossier à vérifier (sha 256)"
$CheminFichierCSV = "PATH du fichier CSV"

# Comparer des fichiers en SHA512
if ((Test-Path $CheminDossier1) -and (Get-Item $CheminDossier1).PSIsContainer) {
    $fichiers = Get-ChildItem -Path $CheminDossier1 -File
    if ($fichiers.Count -gt 0) {
        # Charger les hash depuis le fichier CSV
        $hashesCSV = Import-Csv $CheminFichierCSV | Select-Object -ExpandProperty Hash

        foreach ($fichier in $fichiers) {
            $hash = Calculer-Hash -CheminFichier $fichier.FullName -Algorithme "SHA512"
            Write-Host "$($fichier.Name): $hash"

            # Comparer le hash généré avec celui du fichier CSV
            if ($hashesCSV -contains $hash) {
                Write-Host "Le hash du fichier $($fichier.Name) correspond à un hash SHA512 du fichier CSV."
            } else {
                Write-Host "Le hash du fichier $($fichier.Name) ne correspond pas à un hash SHA512 du fichier CSV."
            }
        }
    } else {
        Write-Host "Aucun fichier trouvé dans le dossier spécifié."
    }
} else {
    Write-Host "Le chemin spécifié n'est pas un dossier valide."
}

# Comparer d'autres fichiers en SHA256
if ((Test-Path $CheminDossier2) -and (Get-Item $CheminDossier2).PSIsContainer) {
    $fichiers = Get-ChildItem -Path $CheminDossier2 -File
    if ($fichiers.Count -gt 0) {
        # Charger les hash depuis le fichier CSV
        $hashesCSV = Import-Csv $CheminFichierCSV | Select-Object -ExpandProperty Hash

        foreach ($fichier in $fichiers) {
            $hash = Calculer-Hash -CheminFichier $fichier.FullName
            Write-Host "$($fichier.Name): $hash"

            # Comparer le hash généré avec celui du fichier CSV
            if ($hashesCSV -contains $hash) {
                Write-Host "Le hash du fichier $($fichier.Name) correspond à un hash du fichier CSV."
            } else {
                Write-Host "Le hash du fichier $($fichier.Name) ne correspond pas à un hash du fichier CSV."
            }
        }
    } else {
        Write-Host "Aucun fichier trouvé dans le dossier spécifié."
    }
} else {
    Write-Host "Le chemin spécifié n'est pas un dossier valide."
}
