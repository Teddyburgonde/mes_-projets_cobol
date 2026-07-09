from parser import CobolParser
from generator import MarkdownGenerator, HtmlGenerator
import shutil

def main(cobol_file):
	# Créer un CobolParser
	parser = CobolParser(cobol_file)

	# Parser le fichier COBOL    
	program = parser.parse()

	# Créer un MarkdownGenerator
	md_generator = MarkdownGenerator()
	html_generator = HtmlGenerator()

	shutil.copy('templates/style.css', 'output/style.css')

	# sauvegarder le Markdown
	md_generator.save(program, f'output/{program.program_id}.md')
	html_generator.save(program, f'output/{program.program_id}.html')

if __name__ == "__main__":
	main('examples/sample.cob')

