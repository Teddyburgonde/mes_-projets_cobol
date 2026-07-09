from parser import CobolParser, CobolProgram
from jinja2 import Environment, FileSystemLoader

class MarkdownGenerator:
	def generate(self, program: CobolProgram) -> str:
		env = Environment(loader=FileSystemLoader('templates'))
		template = env.get_template('doc.md.j2')
		result = template.render(program=program)
		return result

	def save(self, program: CobolProgram, output_path: str) -> None:
		markdown = self.generate(program)
		with open(output_path, 'w') as f:
			f.write(markdown)
		print(f"Markdown saved: {output_path}")
		
class HtmlGenerator:
    def generate(self, program: CobolProgram) -> str:
        env = Environment(loader=FileSystemLoader('templates'))
        template = env.get_template('doc.html.j2')
        result = template.render(program=program)
        return result
    def save(self, program: CobolProgram, output_path: str) -> None:
        html = self.generate(program)
        with open(output_path, 'w') as f:
            f.write(html)
        print(f"Html saved: {output_path}")
        
