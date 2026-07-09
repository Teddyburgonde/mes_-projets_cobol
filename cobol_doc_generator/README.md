# COBOL Doc Generator

Un générateur automatique de documentation pour fichiers COBOL en Python. Transforme un fichier `.cob` en documentation professionnelle au format **Markdown** et **HTML**.

## Fonctionnalités

- ✅ **Parser COBOL** : Extraction automatique de la structure du programme
- ✅ **Variables** : Détection et documentation des variables avec leurs niveaux et types PIC
- ✅ **Procédures** : Extraction des paragraphes/sections COBOL avec leur contenu
- ✅ **Descriptions automatiques** : Génération de descriptions en langage naturel pour chaque instruction
- ✅ **Génération Markdown** : Crée des fichiers `.md` bien formatés avec descriptions
- ✅ **Génération HTML** : Produit des pages HTML stylisées avec mise en forme avancée
- ✅ **Support des instructions** : MOVE, COMPUTE, DISPLAY, PERFORM, ACCEPT
- ✅ **Environnement virtuel** : Script automatisé `start_env.sh` pour la configuration

## Prérequis

- Python 3.7+
- `pip` (gestionnaire de paquets Python)

## Installation rapide

### Option 1 : Script automatisé (Recommandé)

```bash
cd cobol_doc_generator
chmod +x start_env.sh
./start_env.sh
```

Ce script va automatiquement :
1. Créer un environnement virtuel Python
2. L'activer
3. Installer les dépendances (`jinja2`)

### Option 2 : Installation manuelle

```bash
cd cobol_doc_generator

# Créer l'environnement virtuel
python3 -m venv venv

# Activer l'environnement
source venv/bin/activate  # macOS/Linux
# ou
venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r requirements.txt
```

## 💻 Utilisation

### Générer la documentation

```bash
# Activer l'environnement (si pas déjà activé)
source venv/bin/activate

# Générer la documentation
python3 src/main.py examples/sample.cob
```

### Résultat

Deux fichiers sont générés dans le dossier `output/` :
- `PROGRAM-ID.md` - Documentation en Markdown
- `PROGRAM-ID.html` - Documentation en HTML (ouvrir dans un navigateur)

## Structure du projet

```
cobol_doc_generator/
├── src/
│   ├── main.py              # Point d'entrée principal
│   ├── parser.py            # Parser COBOL (extraction des infos)
│   └── generator.py         # Générateurs Markdown et HTML
├── templates/
│   ├── doc.md.j2            # Template Jinja2 pour Markdown
│   ├── doc.html.j2          # Template Jinja2 pour HTML
│   └── style.css            # Styles CSS pour le HTML
├── examples/
│   └── sample.cob           # Fichier COBOL d'exemple
├── output/                  # Dossier pour les fichiers générés
├── venv/                    # Environnement virtuel (créé après start_env.sh)
├── start_env.sh             # Script d'installation automatisée
├── requirements.txt         # Dépendances Python
└── README.md                # Ce fichier
```

## Exemple

### Fichier COBOL d'entrée (`examples/sample.cob`)

```cobol
IDENTIFICATION DIVISION.
    PROGRAM-ID. CALCUL-SALAIRE.

DATA DIVISION.
    WORKING-STORAGE SECTION.
    01 WS-EMPLOYEE-ID PIC 9(5).
    01 WS-EMPLOYEE-NAME PIC X(50).
    01 WS-SALARY-BASE PIC 9(7)V99.
    01 WS-BONUS PIC 9(7)V99 VALUE 0.

PROCEDURE DIVISION.
    ACCEPT WS-EMPLOYEE-ID.
    PERFORM GET-EMPLOYEE-DATA.
    PERFORM CALCULATE-GROSS.
    STOP RUN.

GET-EMPLOYEE-DATA.
    MOVE "Jean Dupont" TO WS-EMPLOYEE-NAME.
    MOVE 3000.00 TO WS-SALARY-BASE.
```

### Fichier généré

**Markdown** (`output/CALCUL-SALAIRE.md`) :
```markdown
# CALCUL-SALAIRE

## Variables
- **WS-EMPLOYEE-ID** (Level: 01, PIC: 9(5))
- **WS-EMPLOYEE-NAME** (Level: 01, PIC: X(50))
- **WS-SALARY-BASE** (Level: 01, PIC: 9(7)V99)
- **WS-BONUS** (Level: 01, PIC: 9(7)V99)

## Procédures

### GET-EMPLOYEE-DATA

**Description:**
• Assigner "Jean Dupont" à WS-EMPLOYEE-NAME
• Assigner 3000.00 à WS-SALARY-BASE

**Code COBOL:**
MOVE "Jean Dupont" TO WS-EMPLOYEE-NAME.
MOVE 3000.00 TO WS-SALARY-BASE.
```

**HTML** (`output/CALCUL-SALAIRE.html`) : 
- Page web avec layout professionnel
- Grille des variables avec hover effects
- Cartes des procédures avec descriptions et code COBOL
- Styles modernes avec gradients et ombres

## Composants

### Parser (`src/parser.py`)

Classe `CobolParser` qui :
- Lit le fichier COBOL
- Extrait le `PROGRAM-ID`
- Détecte les variables avec leurs niveaux et types PIC
- Identifie les paragraphes/procédures

**Dataclasses** :
- `Variable` : level, name, pic
- `Procedure` : name, content, description (généré automatiquement)
- `CobolProgram` : program_id, variables, procedures

**Méthodes principales** :
- `extract_program_id()` : Extrait l'ID du programme COBOL
- `extract_variables()` : Détecte les variables déclarées (niveau et type PIC)
- `extract_paragraphs()` : Récupère tous les paragraphes/procédures
- `extract_procedure_content()` : Récupère le contenu de chaque procédure
- `generate_procedure_description()` : Génère des descriptions en français naturel

### Générateurs (`src/generator.py`)

Deux générateurs utilisant **Jinja2** :
- `MarkdownGenerator` : Crée des fichiers Markdown
- `HtmlGenerator` : Crée des pages HTML stylisées

### Templates

- `doc.md.j2` : Template Jinja2 pour le Markdown
- `doc.html.j2` : Template Jinja2 pour le HTML (avec CSS intégré)
- `style.css` : Feuille de styles CSS pour la mise en forme HTML

## 🧠 Génération des descriptions

Le programme analyse automatiquement chaque instruction COBOL et génère une description en français naturel :

| Instruction | Exemple | Description générée |
|---|---|---|
| **MOVE** | `MOVE 100 TO WS-VALUE` | • Assigner 100 à WS-VALUE |
| **COMPUTE** | `COMPUTE TOTAL = A + B` | • Calculer TOTAL = A + B |
| **DISPLAY** | `DISPLAY "Bonjour"` | • Afficher: "Bonjour" |
| **PERFORM** | `PERFORM INIT-DATA` | • Exécuter la procédure: INIT-DATA |
| **ACCEPT** | `ACCEPT WS-INPUT` | • Accepter une entrée pour WS-INPUT |

## Dépendances

```
jinja2==3.1.2
```

## Désactiver l'environnement

Après avoir terminé votre travail, désactivez l'environnement virtuel :

```bash
deactivate
```

## Réactiver l'environnement

Pour réactiver l'environnement lors d'une prochaine session :

```bash
source venv/bin/activate  # macOS/Linux
# ou
venv\Scripts\activate  # Windows
```

---
