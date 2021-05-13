local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local assets = os.getenv("HOME") .. "/.config/awesome/assets/"
local theme = {}

-- text
theme.font          = "Cantarell 9"
theme.icon_theme    = nil

-- backgrounds
theme.bg_normal     = "#1a1a1a"
theme.bg_focus      = "#212121"
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal
theme.bg_systray    = theme.bg_normal

-- foregrounds
theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

-- borders
theme.border_width      = 1
theme.border_normal     = "#1a1a1a"
theme.border_focus      = "#686868"
theme.border_marked     = "#4A89C7"
theme.useless_gap       = 5
theme.gap_single_client = false

-- tasklist
theme.tasklist_plain_task_name = true
theme.tasklist_spacing = 2

-- titlebars
theme.titlebar_bg_normal = theme.bg_normal
theme.titlebar_fg_normal = "#888888"
theme.titlebar_bg_focus = theme.bg_normal
theme.titlebar_fg_focus = "#ffffff"

-- menu
theme.menu_height = dpi(25)
theme.menu_width  = dpi(200)

-- tray icon
theme.systray_icon_spacing = 8

-- assets: menu
theme.menu_submenu_icon = assets .. "maximized_normal_inactive.png"

-- assets: titlebars
theme.titlebar_close_button_normal = assets .. "close_normal.png"
theme.titlebar_close_button_focus  = assets .. "close_focus.png"
theme.titlebar_maximized_button_normal_inactive = assets .. "maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = assets .. "maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = assets .. "maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = assets .. "maximized_focus_active.png"
theme.titlebar_floating_button_normal_inactive = assets .. "floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = assets .. "floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = assets .. "floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = assets .. "floating_focus_active.png"
theme.titlebar_minimize_button_normal = assets .. "minimized_normal.png"
theme.titlebar_minimize_button_focus  = assets .. "minimized_focus.png"
theme.titlebar_sticky_button_normal_inactive = assets .. "sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = assets .. "sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = assets .. "sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = assets .. "sticky_focus_active.png"

-- assets: layouts
theme.layout_tile = assets .. "tilew.png"
theme.layout_tilebottom = assets .. "tilebottomw.png"
theme.layout_cornernw = assets .. "cornernww.png"
theme.layout_fairv = assets .. "fairvw.png"
theme.layout_floating  = assets .. "floatingw.png"

-- assets: wallpaper
theme.wallpaper = assets .. "background.png"

return theme
