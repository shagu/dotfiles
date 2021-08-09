-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Monkey widgets
local widgets = require("monkeywidgets")
widgets.color = "#E59C19"

local print = function(msg)
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Print()",
    text = tostring(msg)
  })
end

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

autorun = {}
terminal = "mate-terminal"
webbrowser = "firefox"
filemanager = "caja --no-desktop"
ide = "code"
lockscreen = "i3lock -i " .. beautiful.wallpaper .. " -t -e -f"
screenshot = 'scrot'
screenshot_select = 'scrot -s'

launcher = [[
rofi -combi-modi run,drun,window,windowcd,ssh -show combi -modi combi -drun-show-actions \
   -font "Iosevka 10" -hide-scrollbar -bw 1 -padding 5 \
  -color-window "#181818, #000000, #181818" \
  -color-normal "#242424, #aaaaaa, #242424, #2a2a2a, #E59C19" \
  -color-active "#2a2a2a, #ffffff, #242424, #2a2a2a, #E59C19" \
  -color-urgent "#2a2a2a, #E59C19, #242424, #2a2a2a, #E59C19" \
  -display-combi "launch" -display-run "exec" -display-drun "xdg" \
  -line-margin 2 -width 600 -icon-theme "Papirus" -show-icons -kb-cancel Super_L,Escape
]]

editor = "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod1"
appkey = "Mod4"

-- Host specific settings
hostname = io.popen("uname -n"):read()
if hostname == "loki" then
  notebook = true
  display = { "eDP" }
else
  display = { "HDMI-A-1", "DisplayPort-1", "HDMI-A-0" }
  table.insert(autorun, "xrandr --output HDMI-A-1 --mode 1920x1080 --pos 0x1080 --output DisplayPort-1 --mode 3840x2160 --pos 1920x0 --output HDMI-A-0 --mode 1920x1080 --pos 5760x1080")
end

table.insert(autorun, "xsetroot -def") -- reset X defaults
table.insert(autorun, "xset s off") -- disable X screensaver
table.insert(autorun, "xset -dpms") -- disable X powersaving
table.insert(autorun, "xsetroot -cursor_name left_ptr")
table.insert(autorun, "xcape -e 'Super_L=Super_L|0'")
table.insert(autorun, "nitrogen --restore")

for id, command in pairs(autorun) do
  awful.util.spawn(command, false)
end

-- where can be 'left' 'right' 'top' 'bottom' 'center' 'topleft' 'topright' 'bottomleft' 'bottomright' nil
function snap_edge(c, where, geom)
    local sg = screen[c.screen].geometry --screen geometry
    local sw = screen[c.screen].workarea --screen workarea
    local workarea = { x_min = sw.x, x_max=sw.x + sw.width, y_min = sw.y, y_max = sw.y + sw.height }
    local cg = geom or c:geometry()
    local border   = c.border_width
    local cs = c:struts()
    cs['left'] = 0 cs['top'] = 0 cs['bottom'] = 0 cs['right'] = 0
  if where ~= nil then
    c:struts(cs) -- cancel struts when snapping to edge
  end
    if where == 'right' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height
        cg.x = workarea.x_max - cg.width
        cg.y = workarea.y_min
    elseif where == 'left' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height
        cg.x = workarea.x_min
        cg.y = workarea.y_min
    elseif where == 'bottom' then
        cg.width  = sw.width
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_min
        cg.y = workarea.y_max - cg.height
        awful.placement.center_horizontal(c)
    elseif where == 'top' then
        cg.width  = sw.width
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_min
        cg.y = workarea.y_min
        awful.placement.center_horizontal(c)
    elseif where == 'topright' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_max - cg.width
        cg.y = workarea.y_min
    elseif where == 'topleft' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_min
        cg.y = workarea.y_min
    elseif where == 'bottomright' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_max - cg.width
        cg.y = workarea.y_max - cg.height
    elseif where == 'bottomleft' then
        cg.width  = sw.width / 2 - 2*border
        cg.height = sw.height / 2 - 2*border
        cg.x = workarea.x_min
        cg.y = workarea.y_max - cg.height
    elseif where == 'center' then
        awful.placement.centered(c)
        return
    elseif where == nil then
        c:struts(cs)
        c:geometry(cg)
        return
    end
    c.snapped = where
    c.floating = true
    if c.maximized then c.maximized = false end
    c:geometry(cg)
    awful.placement.no_offscreen(c)
    return
end

awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.corner.nw,
  awful.layout.suit.fair,
}

mymainmenu = awful.menu({
  items = {
    { "Open Terminal", terminal },
    { "Web Browser", webbrowser },
    { "File Manager", filemanager },
    { "Session", {
      { "Reload", awesome.restart },
      { "Lock", lockscreen },
      { "Quit", function() awesome.quit() end}
    }}
  }
})

local myclosebutton = wibox.container.margin(wibox.widget.imagebox(beautiful.titlebar_close_button_focus), 0, 2, 6, 6)
myclosebutton:buttons(awful.util.table.join(awful.button({}, 1, function()
  local c = client.focus
  if not c then return end
  c:kill()
end)))

local mymaximizebutton = wibox.container.margin(wibox.widget.imagebox(beautiful.titlebar_maximized_button_focus_active), 0, 2, 6, 6)
mymaximizebutton:buttons(awful.util.table.join(awful.button({}, 1, function()
  local c = client.focus
  if not c then return end

  if c.maximized or c.maximized_horizontal or maximized_vertical then
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    c:geometry(c.oldgeom)
  else
    c.oldgeom = c:geometry()
    c.maximized, c.maximized_vertical, c.maximized_horizontal = true, true, true
  end
end)))

local myminimizebutton = wibox.container.margin(wibox.widget.imagebox(beautiful.titlebar_minimize_button_focus), 0, 2, 6, 6)
myminimizebutton:buttons(awful.util.table.join(awful.button({}, 1, function()
  local c = client.focus
  if not c then return end
  c.minimized = not c.minimized
end)))

local spacer = wibox.widget {
  shape        = gears.shape.circle,
  color        = beautiful.bg_normal,
  border_width = 1,
  border_color = beautiful.bg_normal,
  widget       = wibox.widget.separator,
  forced_width = 4,
}

local mybattery = widgets.battery('BAT1')
local mybacklight = widgets.backlight('amdgpu_bl0')
local mynight = widgets.night(display)
local mywifi = widgets.wifi()
local myvolume = widgets.volume()

local mytextclock = awful.widget.textclock('<span color="#ffffff"><b>%H</b>:<b>%M</b>:<b>%S</b> </span>', 1)
mytextclock.forced_width = 55
local myclock_t = awful.tooltip {
  objects        = { mytextclock },
  timer_function = function()
    return os.date('%A\n%d.%m.%Y (%B)')
  end,
}

local mymarginsystray = wibox.container.margin(wibox.widget.systray(), 4, 4, 2, 2)

local taglist_buttons = awful.util.table.join(
  awful.button({ }, 1, function(t)
    t:view_only()
  end),

  awful.button({ modkey }, 1, function(t)
    if client.focus then client.focus:move_to_tag(t) end
  end),

  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then client.focus:toggle_tag(t) end
  end),

  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      client.focus = c
      c:raise()
    end
  end),

  awful.button({ }, 3, function()
    local instance = nil

    return function ()
      if instance and instance.wibox.visible then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ theme = { width = 250 } })
      end
    end
  end),

  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
  end),

  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
  end)
)

local current_client
local num_clients
awful.keygrabber {
  keybindings = {
    {{'Mod1'}, 'Tab', function()
      if current_client and num_clients and num_clients > 0 then
        current_client = (current_client + 1) % num_clients
        local c = awful.client.focus.history.get(awful.screen.focused(), current_client)
        if c then client.focus = c; c:raise() end
      end
    end},
  },

  stop_key           = 'Mod1',
  stop_event         = 'release',
  export_keybindings = true,
  start_callback     = function()
    awful.client.focus.history.disable_tracking()
    current_client = 0
    num_clients = #awful.screen.focused().clients
  end,
  stop_callback      = function()
    awful.client.focus.history.enable_tracking()
    awful.client.focus.history.add(client.focus)
  end
}

awful.screen.connect_for_each_screen(function(s)
  --gears.wallpaper.tiled(beautiful.wallpaper, s)
  awful.tag({ " ❶ ", " ❷ ", " ❸ ", " ❹ " }, s, awful.layout.layouts[1])

  if s ~= screen[1] then
    return
  end

  s.mypromptbox = awful.widget.prompt()
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)
  ))

  s.mymarginlayout = wibox.container.margin(s.mylayoutbox, 4, 4, 4, 4)

  s.mytaglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {
      font = 'Cantarell 12',
      spacing = 0,
      shape  = gears.shape.rectangle,
    },
    buttons = taglist_buttons,
  }

  s.mytasklist = awful.widget.tasklist(s, function(c, screen)
    return awful.widget.tasklist.filter.currenttags(c, screen) -- and ( c.floating or c.minimized )
  end, tasklist_buttons)

  s.mytasklist = awful.widget.tasklist {
    screen   = s,
    filter   = awful.widget.tasklist.filter.currenttags,
    buttons  = tasklist_buttons,
    widget_template = {
      forced_width = 300,
      id     = 'background_role',
      widget = wibox.container.background,
      {
        left = 5,
        right = 5,
        widget = wibox.container.margin,
        {
          layout = wibox.layout.fixed.horizontal,
          {
            margins = 5,
            widget  = wibox.container.margin,
            {
              id     = 'icon_role',
              widget = wibox.widget.imagebox,
            },
          },
          {
            id     = 'text_role',
            widget = wibox.widget.textbox,
          },
        },
      },
    },
  }

  s.mywibox = awful.wibar({ position = "top", height = 28, border_width = 4, border_color = beautiful.bg_normal, screen = s })
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- left
      layout = wibox.layout.fixed.horizontal,
      s.mymarginlayout,
      spacer,
      s.mytaglist,
      spacer,
      s.mypromptbox,
    },
    { -- middle
      layout = wibox.layout.fixed.horizontal,
      s.mytasklist,
    },
    { -- right
      layout = wibox.layout.fixed.horizontal,

      notebook and mywifi.icon,
      notebook and mywifi,
      notebook and spacer,

      notebook and mybattery.icon,
      notebook and mybattery,
      notebook and spacer,

      mynight.icon,
      mynight,
      spacer,

      notebook and mybacklight.icon,
      notebook and mybacklight,
      notebook and spacer,

      myvolume.icon,
      myvolume,
      spacer,

      mymarginsystray,
      spacer,

      mytextclock,
      spacer,

      myminimizebutton,
      mymaximizebutton,
      myclosebutton,
    },

    color = "#80aa80",
    widget = wibox.container.margin,
  }
end)

-- reload wallpaper on geometry changes
screen.connect_signal("property::geometry", function(s)
  gears.wallpaper.tiled(beautiful.wallpaper, s)
end)

for i = 1, 4 do -- initialize tag keybinds
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "F" .. i, function ()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then tag:view_only() end
    end),

    awful.key({ modkey, "Shift" }, "F" .. i, function ()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then client.focus:move_to_tag(tag) end
      end
    end)
  )
end

-- set root keybinds
root.keys(awful.util.table.join(globalkeys,
  -- Applications
  awful.key({ appkey, }, "0", function () awful.spawn(launcher) end),
  awful.key({ appkey, }, "1", function () awful.spawn(terminal) end),
  awful.key({ appkey, }, "2", function () awful.spawn(webbrowser) end),
  awful.key({ appkey, }, "3", function () awful.spawn(filemanager) end),
  awful.key({ appkey, }, "l", function () awful.spawn(lockscreen) end),

  -- Media Keys
  awful.key({}, "XF86AudioLowerVolume", function () awful.spawn("pamixer -d 2") end),
  awful.key({}, "XF86AudioRaiseVolume", function () awful.spawn("pamixer -i 2") end),
  awful.key({}, "XF86AudioMute", function () awful.spawn("pamixer -t") end),

  awful.key({}, "XF86MonBrightnessUp", function () awful.spawn("brightnessctl s +10") end),
  awful.key({}, "XF86MonBrightnessDown", function () awful.spawn("brightnessctl s 1ß-") end),

  -- Utilities
  awful.key({ }, "Print", function () awful.spawn(screenshot, false) end),
  awful.key({ "Shift", }, "Print", function () awful.spawn(screenshot_select, false) end),

  -- AwesomeWM
  awful.key({ "Control", }, "Escape", function () mymainmenu:show() end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),

  awful.key({ modkey, }, "Left", function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, }, "Right", function () awful.tag.incmwfact( 0.05) end),


  awful.key({ modkey, "Shift" }, "Left", function () awful.tag.incnmaster( 1, nil, true) end),
  awful.key({ modkey, "Shift" }, "Right", function () awful.tag.incnmaster(-1, nil, true) end),
  awful.key({ modkey, }, "space", function () awful.layout.inc(1) end),

  awful.key({ modkey, }, "Up", function ()
    beautiful.useless_gap = beautiful.useless_gap + 1
    awful.tag.setgap(beautiful.useless_gap)
  end),

  awful.key({ modkey, }, "Down", function ()
    if beautiful.useless_gap > 0 then
      beautiful.useless_gap = beautiful.useless_gap - 1
    end
    awful.tag.setgap(beautiful.useless_gap)
  end)
))

-- set root mouse binds
root.buttons(awful.util.table.join(
  awful.button({ }, 1, function () mymainmenu:hide() end),
  awful.button({ }, 3, function () mymainmenu:toggle() end)
  --awful.button({ }, 4, awful.tag.viewnext),
  --awful.button({ }, 5, awful.tag.viewprev)
))

-- define client keys
clientkeys = awful.util.table.join(
  awful.key({ modkey, }, "c", function (c) c:kill() end),

  awful.key({ modkey, }, "v", function (c)
    if awful.client.floating.get(c) or (awful.layout.get(s) == awful.layout.suit.floating) then
      if c.maximized or c.maximized_horizontal or maximized_vertical then
        c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
        c:geometry(c.oldgeom)
      else
        c.oldgeom = c:geometry()
        c.maximized, c.maximized_vertical, c.maximized_horizontal = true, true, true
      end
    else
      c:swap(awful.client.getmaster())
    end
  end),

  awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end),
  awful.key({ modkey, }, "s", function (c) c.minimized = true end),
  awful.key({ modkey, }, "f", function (c)
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    awful.client.floating.toggle()
  end),
  awful.key({ appkey, }, "Left", function (c)
    if c.snapped == "top" then
      snap_edge(c, 'topleft')
    elseif c.snapped == "bottom" then
      snap_edge(c, 'bottomleft')
    else
      snap_edge(c, 'left')
    end
  end),
  awful.key({ appkey, }, "Right", function (c)
    if c.snapped == "top" then
      snap_edge(c, 'topright')
    elseif c.snapped == "bottom" then
      snap_edge(c, 'bottomright')
    else
      snap_edge(c, 'right')
    end
end),

  awful.key({ appkey, }, "Up", function (c)
    if c.snapped == "left" then
      snap_edge(c, 'topleft')
    elseif c.snapped == "right" then
      snap_edge(c, 'topright')
    else
      snap_edge(c, 'top')
    end
  end),
  awful.key({ appkey, }, "Down", function (c)
    if c.snapped == "left" then
      snap_edge(c, 'bottomleft')
    elseif c.snapped == "right" then
      snap_edge(c, 'bottomright')
    else
      snap_edge(c, 'bottom')
    end
  end)
)

-- define client buttons
clientbuttons = awful.util.table.join( -- mouse move and resize
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, function (c)
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    awful.mouse.client.move(c)
    client.focus = c; c:raise()
  end),

  awful.button({ modkey }, 3, function (c)
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    awful.mouse.client.resize(c)
    client.focus = c; c:raise()
  end)
)

awful.rules.rules = {
  {
    rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      size_hints_honor = false,
      maximized = false,
      maximized_horizontal = false,
      maximized_vertical = false,
      fullscreen = false,
      --floating = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.centered,
      --placement = awful.placement.no_offscreen+awful.placement.centered
    },
  },

  {
    rule_any = {type = { "normal", "dialog" }},
    properties = { TItlebars_enabled = false }
  },
}

local function decide_border(c)
  local border = true
  local title = true

  -- no clients, hide panel buttons
  if #c.screen.clients == 0 then
    title = nil
  end

  if c then
    if c.floating and ( c.maximized_horizontal or c.maximized_vertical or c.maximized ) then
      border = nil
      title = nil
    elseif not c.floating and not (awful.layout.get(s) == awful.layout.suit.floating) and #c.screen.clients == 1 then
      border = nil
      title = nil
    end

    -- hide border
    c.border_width = border and beautiful.border_width or 0

    -- hide decoration
    if not title then
      awful.titlebar.hide(c)
    else
      awful.titlebar.show(c)
    end
  end

  -- hide panel buttons
  if not title then
    myclosebutton.visible = true
    mymaximizebutton.visible = true
    myminimizebutton.visible = true
  else
    myclosebutton.visible = false
    mymaximizebutton.visible = false
    myminimizebutton.visible = false
  end
end

client.connect_signal("property::floating", decide_border)
client.connect_signal("property::maximized", decide_border)
client.connect_signal("property::maximized_horizontal", decide_border)
client.connect_signal("property::maximized_vertical", decide_border)
client.connect_signal("unfocus", decide_border)
client.connect_signal("focus", decide_border)
client.connect_signal("property::hidden", decide_border)
client.connect_signal("property::activated", decide_border)

client.connect_signal("property::geometry", function(c)
  decide_border(c)

  if c.maximized or c.maximized_horizontal or maximized_vertical then
    return
  elseif c.oldgeom then
    c:geometry(c.oldgeom)

    -- force geometry up to five times, due to mate-terminal
    c.oldgeomc = c.oldgeomc or 5
    c.oldgeomc = c.oldgeomc - 1

    if c.oldgeomc < 0 then
      c.oldgeomc = nil
      c.oldgeom = nil
    end
  end
end)

client.connect_signal("manage", function (c)
  if not awesome.startup then awful.client.setslave(c) end
  decide_border(c)
end)

local function minimizebutton(c)
  local widget = awful.titlebar.widget.button(c, "minimize", function() return "" end, function(cl) cl.minimized = not cl.minimized end)
  c:connect_signal("property::minimized", widget.update)
  return widget
end

local function maximizedbutton(c)
  local widget = awful.titlebar.widget.button(c, "maximized", function(cl)
      return cl.maximized
  end, function(cl, state)
      cl.maximized = not state
  end)
  c:connect_signal("property::maximized", widget.update)
  return widget
end

local function closebutton(c)
  return awful.titlebar.widget.button(c, "close", function() return "" end, function(cl) cl:kill() end)
end

function double_click_event_handler(double_click_event)
  if double_click_timer then
    double_click_timer:stop()
    double_click_timer = nil
    return true
  end

  double_click_timer = gears.timer.start_new(0.20, function()
    double_click_timer = nil
    return false
  end)
end

client.connect_signal("request::titlebars", function(c)
  titlebarcaption = awful.titlebar.widget.titlewidget(c)
  titlebarcaption.text = "  " .. titlebarcaption.text

  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({ }, 1, function()
      if double_click_event_handler() then
        if c.maximized or c.maximized_horizontal or maximized_vertical then
          c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
          c:geometry(c.oldgeom)
        else
          c.oldgeom = c:geometry()
          c.maximized, c.maximized_vertical, c.maximized_horizontal = true, true, true
        end
      else
        c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
        awful.mouse.client.move(c)
        client.focus = c; c:raise()
      end
    end),
    awful.button({ }, 3, function()
      c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
      awful.mouse.client.resize(c)
      client.focus = c; c:raise()
    end)
  )

  -- disable titlebars
  awful.titlebar(c, { position = "top", size = 24 }) : setup {
    layout = wibox.layout.align.horizontal,
    { -- left
    layout  = wibox.layout.fixed.horizontal,
      awful.titlebar.widget.floatingbutton (c),
    },
    { -- middle
      {
        layout  = wibox.layout.flex.horizontal,
        {
          align  = "center",
          widget = titlebarcaption,
          font = beautiful.font_title,
        },
        buttons = buttons
      },
      margins = 4,
      widget = wibox.container.margin
    },
    { -- right
      {
        layout = wibox.layout.fixed.horizontal(),
        minimizebutton(c),
        maximizedbutton(c),
        closebutton(c)
      },
      margins = 4,
      widget = wibox.container.margin
    }
  }
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
