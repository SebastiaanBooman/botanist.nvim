vim.api.nvim_create_user_command(
	"StartDiagramViewer",
	'lua require("botanist.core").start_plant_uml_diagram_viewer()',
	{}
)

vim.api.nvim_create_user_command(
	"KillDiagramViewer",
	'lua require("botanist.core").kill_plant_uml_diagram_viewer()',
	{}
)

vim.api.nvim_create_user_command("GenerateDiagram", 'lua require("botanist.core").generate_plant_uml_diagram()', {})
