# Roadmap - Générateur de Documentation COBOL (Python)

## 1. SETUP

### [✅] Étape 1.1 : Créer start_env.sh

---

### [✅] Étape 1.2 : Structure des fichiers

```
cobol-doc-generator/
├── venv/
├── src/
│   ├── parser.py
│   ├── generator.py
│   └── main.py
├── templates/
│   ├── doc.md.j2
│   └── doc.html.j2
├── examples/
│   └── sample.cob
├── output/
├── start.sh
├── requirements.txt
└── README.md
```

---

## 2. PARSER COBOL

### [✅] Étape 2.1 : Lire le fichier COBOL

**À faire** :
- Fonction `read_file(path: str)` qui ouvre et retourne le contenu
- Test avec `examples/sample.cob`

---

### [✅] Étape 2.2 : Extraire le PROGRAM-ID

**Pseudo code** :
```
Fonction: extract_program_id(content: str) -> str
    CRÉER regex qui cherche "PROGRAM-ID. (n'importe quel mot)"
    CHERCHER avec re.search()
    SI trouvé:
        RETOURNER match.group(1)
    SINON:
        RETOURNER "UNKNOWN"
```


---

### [✅] Étape 2.3 : Extraire les VARIABLES

**Pseudo code** :
```
Fonction: extract_variables(content: str) -> List[Variable]
    CRÉER liste vide
    CRÉER regex qui cherche "01 NOM PIC TYPE" (pattern: ^\s*(\d+)\s+(\w+)\s+PIC\s+([\w\(\)]+))
    POUR CHAQUE match avec re.finditer():
        CRÉER Variable(level, name, pic)
        AJOUTER à la liste
    RETOURNER liste
```


---

### [✅] Étape 2.4 : Extraire les paragraphs

**Pseudo code** :
```
Fonction: extract_paragraphs(content: str) -> List[Procedure]
    CRÉER liste vide
    CRÉER regex qui cherche "NOM-PROCEDURE." (pattern: ^([A-Z\-\w]+)\.\s*$)
    POUR CHAQUE match avec re.finditer():
        SI "DIVISION" pas dans le nom:
            CRÉER Procedure(name)
            AJOUTER à la liste
    RETOURNER liste
```


---

### [✅] Étape 2.5 : Créer les dataclasses et la classe CobolParser

**Fichier : `src/parser.py`**

```python
import re
from dataclasses import dataclass
from typing import List

@dataclass
class Variable:
    level: str
    name: str
    pic: str

@dataclass
class Procedure:
    name: str

@dataclass
class CobolProgram:
    program_id: str
    variables: List[Variable]
    procedures: List[Procedure]

class CobolParser:
    def __init__(self, filename):
        self.filename = filename
        self.content = self._read_file()
    
    def _read_file(self):
        with open(self.filename, 'r', encoding='utf-8') as f:
            return f.read()
    
    def parse(self) -> CobolProgram:
        program_id = self.extract_program_id()
        variables = self.extract_variables()
        procedures = self.extract_paragraphs()
        
        return CobolProgram(
            program_id=program_id,
            variables=variables,
            procedures=procedures
        )
    
    def extract_program_id(self) -> str:
        # Code
        pass
    
    def extract_variables(self) -> List[Variable]:
        # Code
        pass
    
    def extract_paragraphs(self) -> List[Procedure]:
        # Code
        pass
```

---

### [✅] Étape 2.6 : Tester le parser complet

**Test** :
```bash
python3 src/parser.py
```

Résultat attendu :
```
Program: SAMPLE-PROG
Variables: 4
Procedures: 2
```

---

## 3. GÉNÉRATEUR MARKDOWN

### [✅] Étape 3.1 : Créer le template Markdown

**Fichier : `templates/doc.md.j2`**

```markdown
# {{ program.program_id }}

## Description

{{ program.description }}

---

## Variables

{% for var in program.variables %}
- **{{ var.name }}** (Level: {{ var.level }}, PIC: {{ var.pic }})
{% endfor %}

## Procédures

{% for proc in program.procedures %}
- `{{ proc.name }}`
{% endfor %}

---
*Généré automatiquement par COBOL Doc Generator*
```

---

### [✅] Étape 3.2 : Créer le générateur

**Fichier : `src/generator.py`**

```python
from jinja2 import Template, FileSystemLoader, Environment
from pathlib import Path

class MarkdownGenerator:
	def __init__(self, template_path):
		self.template_path = template_path
	
	def generate(self, program, output_path):
		with open(self.template_path, 'r') as f:
			template_str = f.read()
		
		template = Template(template_str)
		md_content = template.render(program=program)
		
		with open(output_path, 'w') as f:
			f.write(md_content)
		
		print(f"✅ Markdown généré: {output_path}")
		return md_content

class HtmlGenerator:
	def __init__(self, template_path):
		self.template_path = template_path
	
	def generate(self, program, output_path):
		with open(self.template_path, 'r') as f:
			template_str = f.read()
		
		template = Template(template_str)
		html_content = template.render(program=program)
		
		with open(output_path, 'w') as f:
			f.write(html_content)
		
		print(f"✅ HTML généré: {output_path}")
		return html_content
```

---

## 4. GÉNÉRATEUR HTML

### [✅] Étape 4.1 : Créer le template HTML

**Fichier : `templates/doc.html.j2`**

```html
<!DOCTYPE html>
<html lang="fr">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>{{ program.program_id }} - Documentation</title>
	<style>
		body {
			font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
			max-width: 900px;
			margin: 0 auto;
			padding: 20px;
			background: #f5f5f5;
			color: #333;
		}
		h1 {
			color: #667eea;
			border-bottom: 3px solid #667eea;
			padding-bottom: 10px;
		}
		h2 {
			color: #764ba2;
			margin-top: 30px;
		}
		.description {
			background: white;
			padding: 15px;
			border-left: 4px solid #667eea;
			border-radius: 4px;
			margin: 15px 0;
		}
		.variable {
			background: white;
			padding: 12px;
			margin: 8px 0;
			border-left: 4px solid #667eea;
			border-radius: 4px;
		}
		.procedure {
			background: white;
			padding: 10px 12px;
			margin: 8px 0;
			border-left: 4px solid #764ba2;
			border-radius: 4px;
			font-family: 'Courier New', monospace;
		}
		.footer {
			text-align: center;
			margin-top: 40px;
			color: #999;
			font-size: 12px;
		}
	</style>
</head>
<body>
	<h1>{{ program.program_id }}</h1>
	
	<h2>📝 Description</h2>
	<div class="description">
		{{ program.description }}
	</div>
	
	<h2>📋 Variables</h2>
	{% for var in program.variables %}
	<div class="variable">
		<strong>{{ var.name }}</strong> 
		<span style="color: #999;">(Level: {{ var.level }}, PIC: {{ var.pic }})</span>
	</div>
	{% endfor %}
	
	<h2>⚙️ Procédures</h2>
	{% for proc in program.procedures %}
	<div class="procedure">{{ proc.name }}</div>
	{% endfor %}
	
	<div class="footer">
		<p>Généré automatiquement par COBOL Doc Generator</p>
	</div>
</body>
</html>
```

---

## 5. MAIN SCRIPT

### [✅] Étape 5.1 : Créer le point d'entrée

**Fichier : `src/main.py`**

```python
import sys
from pathlib import Path
from parser import CobolParser
from generator import MarkdownGenerator, HtmlGenerator

def main(cobol_file):
	# Parse le fichier COBOL
	# Génère le Markdown
	# Génère le HTML

if __name__ == "__main__":
```

---

## 6. TESTS

### [❌] Étape 6.1 : Tester le générateur

```bash
# Créer le dossier output
mkdir output

# Générer la doc
python src/main.py examples/sample.cob
```

**Résultat attendu :**
```
📂 Lecture: examples/sample.cob
✅ Programme trouvé: SAMPLE-PROG
   Variables: 4
   Procédures: 2
✅ Markdown généré: output/SAMPLE-PROG.md
✅ HTML généré: output/SAMPLE-PROG.html

✨ Génération terminée!
   Markdown: output/SAMPLE-PROG.md
   HTML: output/SAMPLE-PROG.html
```

---

### [ ] Étape 6.2 : Vérifier les outputs

```bash
# Voir le Markdown
cat output/SAMPLE-PROG.md

# Ouvrir le HTML dans le navigateur
open output/SAMPLE-PROG.html  # macOS
xdg-open output/SAMPLE-PROG.html  # Linux
start output/SAMPLE-PROG.html  # Windows
```

---

## 7. README

### ❌ ] Étape 7.1 : Créer le README

**Fichier : `README.md`**

```markdown
# COBOL Doc Generator

Générateur automatique de documentation pour fichiers COBOL.

Transforme un fichier `.cob` en documentation `.md` et `.html`.

## Installation

\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`bash
python src/main.py path/to/program.cob
\`\`\`

Génère:
- `output/PROGRAM-ID.md`
- `output/PROGRAM-ID.html`

## Features

- ✅ Extraction automatique des DIVISIONS
- ✅ Parsing des variables (PIC)
- ✅ Extraction des procédures
- ✅ Génération Markdown
- ✅ Génération HTML avec styles

## Exemples

Voir `examples/sample.cob`
```

---

## Résumé des commandes

```bash
# Installation (automatique avec start.sh)
chmod +x start.sh
./start.sh

# Après l'installation, créer un dossier output
mkdir -p cobol-doc-generator/output

# Test
cd cobol-doc-generator
python src/main.py examples/sample.cob

# Voir le résultat
cat output/SAMPLE-PROG.md
open output/SAMPLE-PROG.html
```

---

## Structure finale

```
cobol-doc-generator/
├── venv/                # Environnement virtuel
├── src/
│   ├── parser.py        # Parse le COBOL
│   ├── generator.py     # Génère MD/HTML
│   └── main.py          # Point d'entrée
├── templates/
│   ├── doc.md.j2        # Template Markdown
│   └── doc.html.j2      # Template HTML
├── examples/
│   └── sample.cob       # Exemple COBOL
├── output/              # Fichiers générés
├── start.sh             # Script d'installation
├── requirements.txt
└── README.md
```

---
