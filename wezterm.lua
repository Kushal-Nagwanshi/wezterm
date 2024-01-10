-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local wallpaper_dir = require("env").WALLPAPER_DIR
local wallpaper_dir_dd = require("env").WALLPAPER_DIR_DD
local project_zoro = require("env").PROJECT_ZORO
local project_japdict = require("env").PROJECT_JAPDICT
-- This table will hold the configuration.
local config = {}

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
        workspace = 'wezterm-config',
        cwd = home_dir,
        args = { 'nvim', "./.wezterm.lua" },
        width = 90,
        height = 60,
        x = 10,
        y = 300,
    }

    -- Main Workspace
    local tab, pane, window = mux.spawn_window {
        workspace = 'nvim',
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
    mux.set_active_workspace 'nvim'
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
    -- Prompt for a name to use for a new workspace and switch to it.
    {
        -- Start a new workspace or switch to existing one with a prompt asking
        -- for name
        key = 'w',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = wezterm.format {
                { Attribute = { Intensity = 'Bold' } },
                { Foreground = { Color = 'hsl(200,45%,55%)' } },
                { Text = 'Enter name for new workspace' .. wallpaper_dir },
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
        key = 'Z',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            --workspace = 'project',
            cwd = project_zoro,
            args = { 'nvim' },
        }
    },
    {
        key = 'J',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            --workspace = 'project',
            cwd = project_japdict,
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
        key = 'h',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Down',
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
}

-- and finally, return the configuration to wezterm
return config
