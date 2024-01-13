-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local wallpaper_dir = require("env").WALLPAPER_DIR
local wallpaper_dir_dd = require("env").WALLPAPER_DIR_DD

local project_dir = require("env").PROJECT_DIR
local project_zoro = require("env").PROJECT_ZORO
local project_japdict = require("env").PROJECT_JAPDICT

local xdg_config_home = os.getenv("xdg_config_home")
-- This table will hold the configuration.
local config = {}
local newtabs = require("newtabs")
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-------------------------------------------------------------------------------
config.initial_cols = 90
config.default_prog = { 'pwsh' }
config.front_end = "WebGpu"
-------------------------------Startup-----------------------------------------

wezterm.on('gui-startup', function()
    local home_dir = wezterm.home_dir
    local tab, build_pane, window = mux.spawn_window {
        cwd = xdg_config_home .. "/wezterm",
        args = { 'nvim', './wezterm.lua' },
        width = 90,
        workspace = 'wezterm-config',
        height = 60,
        x = 10,
        y = 300,
    }

    -- Main Workspace
    local tab, pane, window = mux.spawn_window {
        workspace = 'project',
        cwd = project_dir,
        args = { 'nvim' },
    }

    local tab, pane, window = mux.spawn_window {
        workspace = 'logseq',
        cwd = "D:/Logseq",
        args = { 'nvim', './pages/Important.md' },
    }

    pane:send_text ' pf'

    local tab, pane, window = mux.spawn_window {
        workspace = 'main',
        args = { 'pwsh' },
    }

    local editor_pane = pane:split {
        direction = 'Top',
        size = 0.9,
        cwd = home_dir,
        args = { 'pwsh' },
    }


    -- We want to startup in the coding workspace
    mux.set_active_workspace 'project'
end)

------------------------TITLE and RESIZE---------------------------------------

local window_title_enabled = false
local window_resize_enabled = false
local decoration = "NONE"

if window_title_enabled then
    decoration = "TITLE | "
end

if window_resize_enabled == true then
    decoration = decoration .. "RESIZE"
end
-- options -> RESIZE , NONE , TITLE , TITLE | RESIZE
config.window_decorations = decoration
config.enable_tab_bar = false
-------------------------------------------------------------------------------

config.color_scheme = 'AdventureTime'
config.window_background_opacity = 0.8

-----------------------------------Background----------------------------------

local background_enabled = true
local background_transparent = true
local background_color = 'hsl(250,40%,10%)'

if background_enabled == true then -- configure background
    local wallpapers = {}
    for dir in io.popen("dir \"" .. wallpaper_dir .. "\" /b"):lines() do
        table.insert(wallpapers, dir)
        print(dir)
    end

    local wallpaper = wallpaper_dir_dd .. wallpapers[math.random(#wallpapers)]
    config.background = {
        {
            source = {
                File = wallpaper,
                --config.window_background_image = 'E:/WALLPAPERS/GIFS/FMAB.gif'
            },
            --height = "Contain",
            --width = '100%',
            --height = "Cover",
            repeat_x = 'NoRepeat',
            vertical_align = 'Bottom',
            hsb = { brightness = 0.05, hue = 1, saturation = 1, },
            --attachment = "Scroll",
            opacity = 1,
        },
    }
end

if background_transparent == true then
    config.window_background_opacity = 0.8
end

-------------------------------------------------------------------------------

config.colors = {
    -- The default text color
    foreground = 'silver',
    -- The default background color
    background = background_color,
    -- The color of the split line b/w panes
    split = '#444444',
    -- Overrides the cell background color when the current cell is occupied by the
    -- cursor and the cursor style is set to Block
    cursor_bg = 'hsl(200,100%,100%)',
    -- Overrides the text color when the current cell is occupied by the cursor
    cursor_fg = 'hsl(200, 40%, 55%)',
    -- Specifies the border color of the cursor when the cursor style is set to Block,
    -- or the color of the vertical or horizontal bar when the cursor style is set to
    -- Bar or Underline.
    cursor_border = '#d2aa70',
}
-------------------------------------font--------------------------------------
config.font_size = 14
config.line_height = 0.9
config.max_fps = 65

config.font = wezterm.font_with_fallback {
    'MesloLGM Nerd Font Regular',
    'VictorMono NF Medium',
    'Meiryo UI',
    'BIZ UDGothic',
    'Sanskrit Text',
    'DengXian',
}

-------------------------------------KEYMAPPINGS-------------------------------
config.disable_default_key_bindings = true

wezterm.on('update-right-status', function(window, pane)
    window:set_right_status(window:active_workspace())
end)

wezterm.on('toggle-opacity', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_background_opacity then
        overrides.window_background_opacity = 1
    else
        overrides.window_background_opacity = nil
    end
    window:set_config_overrides(overrides)
end)

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    {
        key = 'a',
        mods = 'LEADER|CTRL',
        action = act.SendKey { key = 'a', mods = 'CTRL' },
    },
    -- ToggleFullScreen
    {
        key = 'F11',
        action = act.ToggleFullScreen,
    },
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ReloadConfiguration,
    },
    ------------------------------------opacity---------------------------------
    {
        key = 'o',
        mods = 'CTRL|META',
        action = wezterm.action.EmitEvent 'toggle-opacity',
    },
    -----------------------------------command pallet-------------------------------
    {
        key = ';',
        mods = 'LEADER',
        action = act.ActivateCommandPalette,
    },
    --potential bug --- mapping this makes us unable to map <C-l> in insert mode
    --no idea why it was not working earlier but after  reloading it works
    --always reload !!
    { key = 'L', mods = 'CTRL',     action = act.ShowDebugOverlay },
    ---------------------------------WorkSpaces------------------------------------
    {
        key = '8',
        mods = 'CTRL|ALT',
        action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
    },
    { key = '9', mods = 'CTRL|ALT', action = act.SwitchWorkspaceRelative(1) },
    { key = '0', mods = 'CTRL|ALT', action = act.SwitchWorkspaceRelative(-1) },
    {
        -- Prompt for a name to use for a new workspace and switch to it.
        -- Start a new workspace or switch to existing one with a prompt asking
        -- for name
        key = '8',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = wezterm.format {
                --{ Attribute = { Intensity = 'Bold' } },
                { Foreground = { Color = 'hsl(200,45%,55%)' } },
                { Text = 'Enter name for new workspace' },
            },
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace {
                            name = line,
                        },
                        pane
                    )
                end
            end),
        },
    },
    ----------------------------------------Windows----------------------------
    { key = 'n', mods = 'LEADER',   action = act.SpawnWindow },
    {
        -- Start a new Tab from the options (preconfigured)
        key = '2',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = wezterm.format {
                { Foreground = { Color = 'hsl(30,100%,50%)' } },
                { Text = [[Chose from the following (either type the name or enter the number):
1.wezterm
2.project
3.zoro
4.japdict
5.logseq
                ]], },
            },

            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        act.SpawnCommandInNewTab {
                            cwd = newtabs[line].cwd,
                            args = newtabs[line].args,
                        },
                        pane)
                end
            end),
        },
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            cwd = xdg_config_home .. "/wezterm",
            args = { 'nvim', './wezterm.lua' },
        }
    },
    {
        key = 'p',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            cwd = project_dir,
            args = { 'nvim', '.' },
        }
    },
    {
        key = 'z',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            cwd = project_zoro,
            args = { 'nvim' },
        }
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            cwd = project_japdict,
            args = { 'nvim', '.' },
        }
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            cwd = "D:/Logseq/pages",
            args = { 'nvim', '.' },
        }
    },

    ----------------------------------------Tabs-------------------------------
    { key = '[', mods = 'ALT|CTRL', action = act.ActivateTabRelative(-1) },
    { key = ']', mods = 'ALT|CTRL', action = act.ActivateTabRelative(1) },
    {
        key = 't',
        mods = 'LEADER',
        action = act.SpawnTab 'CurrentPaneDomain',
    },
    ---------------------------------------Panes------------------------------
    {
        key = '\\',
        mods = 'LEADER',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '-',
        mods = 'LEADER',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'q',
        mods = 'LEADER',
        action = act.CloseCurrentPane { confirm = true },
    },
    {
        key = 'LeftArrow',
        mods = 'META',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'RightArrow',
        mods = 'META',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'UpArrow',
        mods = 'META',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'DownArrow',
        mods = 'META',
        action = act.ActivatePaneDirection 'Down',
    },
    {
        key = 'C',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
    },
    {
        key = 'V',
        mods = 'CTRL|SHIFT',
        action = act.PasteFrom 'Clipboard',
    },
}

-- and finally, return the configuration to wezterm
return config
