# CLOUD - Cloud-Init ISO Maker

## Contexte

Ce projet fournit une solution d'automatisation PowerShell permettant de générer dynamiquement des images ISO (`NoCloud`) destinées au provisionnement de machines virtuelles Windows via Cloud-Init. Il résout la problématique de configuration initiale en injectant à la volée l'identité (nom d'hôte) et les paramètres réseau (IP, masque, passerelle, DNS) au sein de l'image, facilitant ainsi les déploiements automatisés et l'Infrastructure as Code.

---

## Structure du dépôt

L’organisation du dépôt suit la logique suivante :

```text
.
├── NoCloud/
│   ├── meta-data
│   ├── network-config
│   └── user-data
├── isoMakerLinux.ps1
└── README.md

```

* **`NoCloud/`** : Répertoire contenant les fichiers Cloud-Init destinés au lecteur de configuration ISO NoCloud.
* **`NoCloud/meta-data`** : Modèle de données définissant le nom d'hôte (`hostname`) et d'autres métadonnées de la machine.
* **`NoCloud/network-config`** : Configuration réseau statique appliquée par Cloud-Init au premier démarrage.
* **`NoCloud/user-data`** : Script ou configuration d'initialisation exécuté par Cloud-Init.
* **`isoMakerLinux.ps1`** : Script principal automatisant la copie des modèles, le remplacement des valeurs cibles et la compilation de l'ISO finale.

---

## Utilisation de Cloudbase-Init ISO Maker

### 1. Cloner le dépôt localement

```bash
git clone https://github.com/FireToak/cloud-init-isomaker.git
cd cloud-init-isomaker
```

### 2. Installer les prérequis

L'utilitaire `oscdimg.exe` est strictement requis pour compiler l'image ISO. Vous devez installer le **Windows ADK (Assessment and Deployment Kit)** sur votre poste de travail. Le script s'attend à trouver l'exécutable au chemin par défaut :
`C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe`

### 3. Exécuter le script de génération

Le script `isoMakerLinux.ps1` doit être exécuté en ligne de commande. Il requiert cinq paramètres obligatoires (tous de type `[string]`) pour personnaliser l'image.

| Paramètre | Type | Description |
| --- | --- | --- |
| `-NomMachine` | `string` | Nom d'hôte de la machine virtuelle ciblée. |
| `-AdresseIP` | `string` | Adresse IPv4 statique à attribuer. |
| `-Masque` | `string` | Longueur du préfixe réseau (ex : "24"). |
| `-Passerelle` | `string` | Adresse IPv4 de la passerelle par défaut. |
| `-DNS` | `string` | Adresse IPv4 du serveur DNS. |

**Exemple de commande :**

```powershell
.\isoMakerLinux.ps1 -NomMachine "loutik-test-01" -AdresseIP "10.0.0.99" -Masque "24" -Passerelle "10.0.0.254" -DNS "9.9.9.9"
```

*Note : L'ISO générée sera automatiquement placée à la racine du projet sous le format de nommage `cloudbase-[NomMachine]-[UUID].iso`.*

---

## 👨‍💻 Mainteneurs

* **Louis MEDO** | [LinkedIn](https://www.linkedin.com/in/louismedo/) | [Portfolio](https://louis.loutik.fr/) | [GitHub](https://github.com/FireToak) | [louis.medo@loutik.fr](mailto:louis.medo@loutik.fr)

---

<div align="center">
<br>
<small><i>Dernière mise à jour : 10 juin 2026</i></small>
</div>