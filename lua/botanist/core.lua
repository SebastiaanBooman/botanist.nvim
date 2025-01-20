local options = require("botanist").options
local M = {}

-- Gets the base plugins base path (full path to /botanist/lua)
-- Thanks Chat GPT :grimace:
local function get_base_path()
	local script_path = debug.getinfo(1).source:match("@(.*)")
	return script_path:match("(.*/)")
end

local function is_able_to_generate_diagram()
	if vim.bo.filetype ~= "plantuml" then
		vim.notify("Cannot generate Plant UML diagram: this is not a Plant UML file", vim.log.levels.ERROR)
		return false
	end
	if vim.fn.executable("java") == 0 then
		vim.notify(
			'Cannot generate Plant UML diagram: "java" is required and not installed/accessible',
			vim.log.levels.ERROR
		)
		return false
	end
	if vim.fn.executable("feh") == 0 then
		vim.notify(
			'Cannot generate Plant Uml diagram: "feh" is required but not installed/accessible',
			vim.log.levels.ERROR
		)
		return false
	end
	return true
end

local function execute_command(command, error_msg)
	error_msg = error_msg or "Execution error!"
	--TODO: Validate command output, use vim.system
	vim.fn.system(command)
	-- if result ~= nil and string.len(result) ~= 0 and tonumber(result) ~= 0 then
	-- 	--vim.notify(error_msg) vim.log.levels.ERROR)
	-- end
end

function M.generate_plant_uml_diagram_if_not_exists()
	local file_without_extension = vim.fn.expand("%:p:r")
	local image_file = string.format("%s.%s", file_without_extension, options.image.format)

	local f = io.open(image_file, "r")
	local file_exists = f ~= nil and io.close(f)
	if not file_exists then
		vim.notify("Output file does not exist. Generating diagram...", vim.log.levels.INFO)
		M.generate_plant_uml_diagram()
	end
end

-- Attempts to (re)create an output image file for the current plantuml buffer
function M.generate_plant_uml_diagram()
	if not is_able_to_generate_diagram() then
		return
	end

	local file_with_extension = vim.fn.expand("%:p")
	local format = options.image.format
	local darkmode = options.image.darkmode and "-darkmode" or ""

	local puml_command

	if options.plant_uml_jar_path == nil then
		puml_command = string.format("plantuml %s -t %s %s", file_with_extension, format, darkmode)
	else
		puml_command =
			string.format("java -jar %s %s -t %s %s", options.plant_uml_jar_path, file_with_extension, format, darkmode)
	end

	execute_command(puml_command, "Error during generation of Plant UML diagram")
end

function M.start_plant_uml_diagram_viewer_if_not_exists()
	local is_feh_process_active_script_path = get_base_path() .. "../../scripts/is_feh_process_active.sh"

	local file_without_extension = vim.fn.expand("%:p:r")
	local image_file = string.format("%s.%s", file_without_extension, options.image.format)

	local status_code = os.execute(string.format("%s %s", is_feh_process_active_script_path, image_file))
	if status_code ~= 0 then
		M.start_plant_uml_diagram_viewer()
	end
end

-- Attempts to open feh with given image.
function M.start_plant_uml_diagram_viewer()
	local file_without_extension = vim.fn.expand("%:p:r")
	local image_file = string.format("%s.%s", file_without_extension, options.image.format)

	local feh_command = string.format("sh -c 'feh %s --auto-reload & disown; echo $?'", image_file)

	execute_command(feh_command, 'Could not open image: "' .. image_file .. '"in feh')

	if options.terminal_emulator ~= nil then
		local refocus_terminal_script_path = get_base_path() .. "../../scripts/refocus_terminal.sh"
		local refocus_terminal_command =
			string.format("sh -c '%s %s & disown; echo $?'", refocus_terminal_script_path, options.terminal_emulator)
		execute_command(refocus_terminal_command, "Could not refocus on terminal")
	end
end

-- Attempts to terminate a feh process with same name as the plantuml file
function M.kill_plant_uml_diagram_viewer()
	local file_without_extension = vim.fn.expand("%:p:r")
	local img = string.format("%s.%s", file_without_extension, options.image.format)
	os.execute(string.format("ps aux | grep -m 1 %s | awk '{print $2}' | xargs kill -9", img))
end

return M
