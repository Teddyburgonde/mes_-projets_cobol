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
	content: str
	description: str = ""

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
		with open(self.filename, 'r') as f:
			return f.read()

	def extract_program_id(self) -> str:
		pattern = r'PROGRAM-ID\.\s+([\w\-]+)'
		match = re.search(pattern, self.content)
		return match.group(1) if match else "UNKNOWN"

	def extract_variables(self) -> List[Variable]:
		variables = []
		pattern = r'^\s*(\d+)\s+([\w\-]+)\s+PIC\s+([\w\(\)]+)'
		for match in re.finditer(pattern, self.content, re.MULTILINE):
			variables.append(Variable(
				level=match.group(1),
				name=match.group(2),
				pic=match.group(3)
			))
		return variables

	def extract_paragraphs(self) -> List[Procedure]:
		procedures = []
		pattern = r'^\s*([A-Z\-\w]+)\.\s*$'

		# Récupere le contenu
		procedure_contents = self.extract_procedure_content()

		for match in re.finditer(pattern, self.content, re.MULTILINE):
			proc_name = match.group(1)
			if "DIVISION" not in proc_name:
				content = procedure_contents.get(proc_name, "")
				description = self.generate_procedure_description(content)
				procedures.append(Procedure(name=proc_name, content=content, description=description))
		return procedures

	def extract_procedure_content(self) -> dict:
		procedures_dict = {}
		lines = self.content.split('\n')

		# Pattern pour trouver les noms de procédures
		proc_pattern = r'^\s*([A-Z\-\w]+)\.\s*$'

		# Liste des (nom_procedure, numero_ligne)
		proc_positions = []

		for i, line in enumerate(lines):
			match = re.search(proc_pattern, line)
			if match:
				proc_name = match.group(1)
				# Exclure les DIVISIONS
				if "DIVISION" not in proc_name:
					# Ajouter (nom, numéro de ligne)
					proc_positions.append((proc_name, i))

		# Pour chaque procédure trouvée
		for idx, (proc_name, start_line) in enumerate(proc_positions):
			# Si y a une procédure suivante
			if idx + 1 < len(proc_positions):
				# La fin = le début de la prochaine procédure
				end_line = proc_positions[idx + 1][1]
			else:
				# Sinon = fin du fichier
				end_line = len(lines)

			# Prendre les lignes entre start et end
			content_lines = lines[start_line + 1:end_line]
			# Enlever les espaces inutiles au début et fin, mais garder l'indentation relative
			cleaned_lines = []
			for line in content_lines:
				cleaned_lines.append(line.strip())

			content = '\n'.join(cleaned_lines).strip()
			# Stocker dans le dictionnaire
			procedures_dict[proc_name] = content

		# Retourner tous les contenus
		return procedures_dict

	def generate_procedure_description(self, content: str) -> str:
		"""Génère une description en langage naturel des instructions COBOL"""
		if not content.strip():
			return "Aucune instruction"

		descriptions = []
		lines = content.strip().split('\n')

		for line in lines:
			line = line.strip()
			if not line or line.endswith('.'):
				line = line.rstrip('.')

			if line.startswith('MOVE'):
				# MOVE value TO variable
				match = re.search(r'MOVE\s+(.+?)\s+TO\s+(.+)', line)
				if match:
					value = match.group(1).strip()
					variable = match.group(2).strip()
					descriptions.append(f"• Assigner {value} à {variable}")

			elif line.startswith('COMPUTE'):
				# COMPUTE variable = expression
				match = re.search(r'COMPUTE\s+(.+?)\s*=\s*(.+)', line)
				if match:
					variable = match.group(1).strip()
					expression = match.group(2).strip()
					descriptions.append(f"• Calculer {variable} = {expression}")

			elif line.startswith('PERFORM'):
				# PERFORM procedure-name
				match = re.search(r'PERFORM\s+(.+)', line)
				if match:
					proc = match.group(1).strip()
					descriptions.append(f"• Exécuter la procédure: {proc}")

			elif line.startswith('ACCEPT'):
				# ACCEPT variable
				match = re.search(r'ACCEPT\s+(.+)', line)
				if match:
					variable = match.group(1).strip()
					descriptions.append(f"• Accepter une entrée pour {variable}")

			elif line.startswith('DISPLAY'):
				# DISPLAY message/variable
				match = re.search(r'DISPLAY\s+(.+)', line)
				if match:
					output = match.group(1).strip()
					descriptions.append(f"• Afficher: {output}")

			elif line.startswith('IF'):
				descriptions.append(f"• Vérifier une condition: {line}")

			elif line:
				descriptions.append(f"• {line}")

		return '\n'.join(descriptions) if descriptions else "Aucune instruction"

	def parse(self) -> CobolProgram:
		return CobolProgram(
			program_id=self.extract_program_id(),
			variables=self.extract_variables(),
			procedures=self.extract_paragraphs()
		)

