# botanist.nvim
An integrated Plant UML diagram viewer and file exporter for Neovim. Leverages auto-reload to enable seamless diagram development.

![Showcase](https://github.com/user-attachments/assets/54318a47-6adb-49b5-9553-adfdea3d2f71)
## Overview
The objective for this plugin was to create a highly integrated Plant UML diagram viewer and exporter for Neovim. With the default options, a new diagram viewer (feh process) is started whenever a Plant UML file is opened. Control is immediately returned to the terminal so you may start editing right away (this works quite scuffed as discussed in ##Caveats). When switching buffers or leaving Neovim, the diagram viewer is terminated.

## Dependencies
### Required
- [Plant UML](https://plantuml.com/): To export diagrams
- [Java](https://www.java.com/en/): To run the Plant UML program
- [feh](https://github.com/derf/feh): To open generated diagrams

### Optional
- wmctrl: used to refocus the last Neovim instance after opening a diagram with feh.

## Installation 
`Lazy`
```lua
{
    "SebastiaanBooman/botanist.nvim",
    opts = {
        -- Required settings
        -- When to re-generate (overwrite) the diagram file. choose between:
        -- save
        -- change (currently broken)
        -- disabled
        auto_refresh_event = 'save',
        -- Whether to automatically start a feh process when a PlantUML buffer is opened.
        start_image_viewer_on_buf_enter = true,
        -- Whether to automatically kill a feh process when a PlantUML buffer or neovim is closed. Only kills a feh process if it exists.
        kill_image_viewer_on_buf_leave = true,
        -- Options for the output image
        image = {
            -- Toggle darkmode
            darkmode = false,
            -- Choose between png or svg
            format = 'png',
        },
        -- Optional settings
        -- Used for the refocus_terminal.sh script to refocus to the previously active terminal. If omitted, no attempt is made to refocus the terminal
        terminal_emulator = 'Alacritty', -- change to the emulator you are using for neovim
        -- If omitted, a Plant UML .jar file is expected to be available through $PATH
        plant_uml_jar_path = '$HOME/src/plantuml/build/libs/plantuml-1.2025.1beta3.jar',
    },
}
```

## Usage
While the default setup is designed to work without additional configuration (except for setting the optional settings), the following APIs are exposed that can also be used.
|command|explanation|
|---|---|
:StartDiagramViewer|Starts a feh process with the output image of the current Plant UML file
:KillDiagramViewer|Kills a feh process with the output image of the current Plant UML file
:GenerateDiagram|Generates an output file of the current diagram using Plant UML. at ./<file_name>.<chosenextension>. Rewrites existing diagrams

## Caveats
- `auto_refresh_event` option `change` is buggy and does not work as expected.
- To focus the last opened Neovim instance after opening a diagram with wmctrl, the process name from the terminal is used. However, as Neovim runs from the terminal, I was not able to match on Neovim as a name. Instead, as a workaround the user may set the `terminal_emulator` option as described in [Installation](#Installation).

## Attribution
This plugin was adapted from [nvim-soil](https://github.com/javiorfo/nvim-soil)
