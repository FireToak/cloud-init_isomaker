# ---
# Type        : SCRIPT
# Auteur      : Louis MEDO - louis.medo@loutik.fr
# Date        : 10/06/2026
# Rôle        : Création d'une image ISO NoCloud pour cloud-init (Linux) avec personnalisation
# ---

param (
    [Parameter(Mandatory=$true)][string]$NomMachine,
    [Parameter(Mandatory=$true)][string]$AdresseIP,
    [Parameter(Mandatory=$true)][string]$Masque,
    [Parameter(Mandatory=$true)][string]$Passerelle,
    [Parameter(Mandatory=$true)][string]$DNS,
    [string]$TemplateDir = "$PSScriptRoot\NoCloud",
    [string]$TempDir = "$PSScriptRoot\tmp\NoCloud",
    [string]$IsoDir = "$PSScriptRoot"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Définition stricte de l'encodage UTF-8 sans BOM pour Linux
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 0. Vérification de l'outil oscdimg
$OscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if (-not (Test-Path -Path $OscdimgPath)) {
    Write-Error "L'utilitaire oscdimg.exe est introuvable. Veuillez installer le Windows ADK."
    exit 1
}

# 1. Création du dossier temporaire et copie
if (-not (Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}
Copy-Item -Path "$TemplateDir\*" -Destination $TempDir -Recurse -Force

# 2. Remplacement du nom d'hôte dans user-data
$UserDataFile = "$TempDir\user-data"
if (Test-Path $UserDataFile) {
    # Lecture en bloc brut
    $UserDataContent = Get-Content -Path $UserDataFile -Raw
    $UserDataContent = $UserDataContent -replace '(?m)^hostname:.*$', "hostname: $NomMachine"
    $UserDataContent = $UserDataContent -replace '(?m)^fqdn:.*$', "fqdn: $NomMachine.domain.lan"
    
    # Conversion forcée en LF (Unix) et écriture
    $UserDataContent = $UserDataContent -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($UserDataFile, $UserDataContent, $Utf8NoBom)
}

# 3. Remplacement des configurations réseau dans network-config
$NetworkFile = "$TempDir\network-config"
if (Test-Path $NetworkFile) {
    # Lecture en bloc brut
    $NetworkContent = Get-Content -Path $NetworkFile -Raw
    
	Write-Host "IP : $($AdresseIP)"
    $NetworkContent = $NetworkContent -replace '@@IP@@', $AdresseIP
    $NetworkContent = $NetworkContent -replace '@@MASQUE@@', $Masque
    $NetworkContent = $NetworkContent -replace '@@PASSERELLE@@', $Passerelle
    $NetworkContent = $NetworkContent -replace '@@DNS@@', $DNS
    
    # Conversion forcée en LF (Unix) et écriture
    $NetworkContent = $NetworkContent -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($NetworkFile, $NetworkContent, $Utf8NoBom)
}

# Nettoyage préventif des retours chariot sur meta-data
$MetaDataFile = "$TempDir\meta-data"
if (Test-Path $MetaDataFile) {
    $MetaDataContent = Get-Content -Path $MetaDataFile -Raw
    $MetaDataContent = $MetaDataContent -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($MetaDataFile, $MetaDataContent, $Utf8NoBom)
}

# 4. Génération de l'ISO avec oscdimg
$UuidCourt = (New-Guid).Guid.Substring(0,8)
$IsoPath = "$IsoDir\cloudinit-$NomMachine-$UuidCourt.iso"
Write-Host "Génération de l'ISO NoCloud en cours..." -ForegroundColor Cyan
& $OscdimgPath -m -o -j1 -lcidata "$TempDir" "$IsoPath"

# 5. Nettoyage du dossier temporaire
Remove-Item -Path "$PSScriptRoot\tmp" -Recurse -Force
Write-Host "Opération terminée avec succès !" -ForegroundColor Green