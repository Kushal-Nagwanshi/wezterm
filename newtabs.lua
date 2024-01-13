local project_dir = require("env").PROJECT_DIR
local project_zoro = require("env").PROJECT_ZORO
local project_japdict = require("env").PROJECT_JAPDICT
local xdg_config_home = os.getenv("xdg_config_home")

M = {}

M['wezterm'] = {
    cwd = xdg_config_home .. "/wezterm",
    args = { 'nvim', './wezterm.lua' },
}
M['1'] = M['wezterm']
---------------------

M['project'] = {
    cwd = project_dir,
    args = { 'nvim', '.' },
}
M['2'] = M['project']
---------------------

M['zoro'] = {
    cwd = project_zoro,
    args = { 'nvim' },
}
M['3'] = M['zoro']
---------------------

M['japdict'] = {
    cwd = project_japdict,
    args = { 'nvim', '.' },
}
M['4'] = M['japdict']
---------------------

M['logseq'] = {

    cwd = "D:/Logseq/pages",
    args = { 'nvim', '.' },
}
M['5'] = M['logseq']
---------------------

return M;
