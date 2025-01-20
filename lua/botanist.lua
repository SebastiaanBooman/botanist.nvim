local M = {}
M.options = {}

M.debounceTimeSeconds = 0.2
M.lastExecution = -0.2 -- ensure it can be started immediately

--TODO: define agrup better, or pass it to methods
local augroup = vim.api.nvim_create_augroup("BotanistAutoCmdGroup", { clear = true })

local function create_botanist_autocommand(event, callback)
	vim.api.nvim_create_autocmd(event, {
		group = augroup,
		pattern = { "*.plantuml", "*.puml", "*.uml", "*.pu" },
		callback = callback,
	})
end

local function setup_auto_refresh_event_option(auto_refresh_event_option, botanist_core)
	assert(auto_refresh_event_option, '"auto_refresh_event" opt must be set in opts')
	assert(
		auto_refresh_event_option == "save"
			or auto_refresh_event_option == "change"
			or auto_refresh_event_option == "disabled",
		'auto_refresh_event opt must be either "save", "change" or "disabled"'
	)

	M.options.auto_refresh_event = auto_refresh_event_option

	if M.options.auto_refresh_event == "change" then
		-- TODO: This is broken
		create_botanist_autocommand({ "TextChangedI", "TextChanged" }, function()
			local currentTime = os.clock()
			if (currentTime - M.lastExecution) > M.debounceTimeSeconds then
				M.lastExecution = currentTime
				botanist_core.generate_plant_uml_diagram()
			end
		end)
	elseif M.options.auto_refresh_event == "save" then
		create_botanist_autocommand("BufWritePost", function()
			botanist_core.generate_plant_uml_diagram()
			-- On empty new buffers no diagram viewer is started, this ensures it is started on save
			botanist_core.start_plant_uml_diagram_viewer_if_not_exists()
		end)
	end
end

local function setup_auto_manage_image_viewer_options(opts, botanist_core)
	assert(opts.start_image_viewer_on_buf_enter ~= nil, '"start_image_viewer_on_buf_enter" must be set in opts')
	assert(
		type(opts.start_image_viewer_on_buf_enter) == "boolean",
		'"start_image_viewer_on_buf_enter" opt must be of type boolean'
	)

	M.options.start_image_viewer_on_buf_enter = opts.start_image_viewer_on_buf_enter

	assert(opts.kill_image_viewer_on_buf_leave ~= nil, '"kill_image_viewer_on_buf_leave" must be set in opts')
	assert(
		type(opts.kill_image_viewer_on_buf_leave) == "boolean",
		'"kill_image_viewer_on_buf_leave" opt must be of type boolean'
	)

	M.options.kill_image_viewer_on_buf_leave = opts.kill_image_viewer_on_buf_leave

	if M.options.start_image_viewer_on_buf_enter then
		create_botanist_autocommand("BufWinEnter", function()
			local file_has_content = vim.fn.filereadable(vim.fn.expand("%:p"))
			if file_has_content == 1 then
				botanist_core.generate_plant_uml_diagram_if_not_exists()
				botanist_core.start_plant_uml_diagram_viewer()
			end
		end)
	end
	if M.options.kill_image_viewer_on_buf_leave then
		create_botanist_autocommand({ "BufWinLeave", "VimLeavePre" }, function()
			botanist_core.kill_plant_uml_diagram_viewer()
		end)
	end
end

local function setup_image_options(image_options)
	assert(image_options, '"image" opt must be set in opts')
	assert(image_options.format, '"opts.image.format" must be set')
	assert(
		image_options.format == "png" or image_options.format == "svg",
		'opts.image_options.format must be either "png", "svg"'
	)
	M.options.image = {}

	M.options.image.format = image_options.format

	assert(image_options.darkmode ~= nil, '"opts.image.darkmode" must be set')
	assert(type(image_options.darkmode) == "boolean", '"opts.image.darkmode" must be of type boolean')
	M.options.image.darkmode = image_options.darkmode
end

local function setup_plant_uml_jar_path(plant_uml_jar_path)
	if plant_uml_jar_path ~= nil then
		assert(type(plant_uml_jar_path) == "string", '"opts.plant_uml_jar_path" must be of type string')
	end
	M.options.plant_uml_jar_path = plant_uml_jar_path
end

local function setup_terminal_emulator(terminal_emulator)
	if terminal_emulator ~= nil then
		assert(type(terminal_emulator) == "string", '"opts.terminal_emulator" must be of type string')
	end
	M.options.terminal_emulator = terminal_emulator
end

function M.setup(opts)
	assert(opts, "required opts variable not found in M.setup")

	local botanist_core = require("botanist.core")
	setup_auto_refresh_event_option(opts.auto_refresh_event, botanist_core)
	setup_auto_manage_image_viewer_options({
		start_image_viewer_on_buf_enter = opts.start_image_viewer_on_buf_enter,
		kill_image_viewer_on_buf_leave = opts.kill_image_viewer_on_buf_leave,
	}, botanist_core)

	setup_image_options(opts.image)
	setup_plant_uml_jar_path(opts.plant_uml_jar_path)
	setup_terminal_emulator(opts.terminal_emulator)
end

return M
