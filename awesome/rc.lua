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

-- Autostart
local autorun = {
  "xset s off",
  "xset -dpms",
  "xsetroot -cursor_name left_ptr",
}

for id, command in pairs(autorun) do
  awful.util.spawn(command, false)
end

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

local display = "eDP"

terminal = "alacritty"
webbrowser = "chromium"
filemanager = "thunar"
ide = "code"
lockscreen = "i3lock -i " .. beautiful.wallpaper .. " -t -e -f"
screenshot_select = 'scrot -s'

screenshot = [[
  bash -c '
    xrandr --output ]]..display..[[ --brightness .2;
    scrot;
    sleep .001;
    xrandr --output ]]..display..[[ --brightness 1
  '
]]

launcher = [[
rofi -combi-modi run,drun,window,windowcd,ssh -show combi -modi combi -drun-show-actions \
   -font "Envy Code R 11" -hide-scrollbar -bw 1 -padding 5 \
  -color-window "#181818, #000000, #181818" \
  -color-normal "#242424, #aaaaaa, #242424, #2a2a2a, #8AB4F8" \
  -color-active "#2a2a2a, #ffffff, #242424, #2a2a2a, #8AB4F8" \
  -color-urgent "#2a2a2a, #8AB4F8, #242424, #2a2a2a, #8AB4F8" \
  -display-combi "launch" -display-run "exec" -display-drun "xdg" \
  -line-margin 2 -width 600 -icon-theme "Papirus" -show-icons
]]

editor = "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod1"
appkey = "Mod4"

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.corner.nw,
  awful.layout.suit.fair,
  awful.layout.suit.floating,
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

local myclosebutton = wibox.widget.imagebox(beautiful.titlebar_close_button_focus)
myclosebutton:buttons(awful.util.table.join(awful.button({}, 1, function()
  local c = client.focus
  if not c then return end
  c:kill()
end)))

local mymaximizebutton = wibox.widget.imagebox(beautiful.titlebar_maximized_button_focus_active)
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

local myminimizebutton = wibox.widget.imagebox(beautiful.titlebar_minimize_button_focus)
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
mytextclock.forced_width = 60
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
  gears.wallpaper.tiled(beautiful.wallpaper, s)
  awful.tag({ "❶", "❷", "❸", "❹" }, s, awful.layout.layouts[1])

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
      spacing = 2,
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

  s.mywibox = awful.wibar({ position = "top", height = 28, border_width = 2, border_color = beautiful.bg_normal, screen = s })
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
      mywifi.icon,
      mywifi,
      spacer,
      mybattery.icon,
      mybattery,
      spacer,
      mynight.icon,
      mynight,
      space,
      mybacklight.icon,
      mybacklight,
      spacer,
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
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
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
    properties = { titlebars_enabled = true }
  },
}

local function decide_border(c)
  local border = true
  local title = true
  if c then
    if c.floating and ( c.maximized_horizontal or c.maximized_vertical or c.maximized ) then
      border = nil
      title = nil
    elseif not c.floating and #c.screen.clients == 1 then
      border = nil
      title = nil
    end

    c.border_width = border and beautiful.border_width or 0

    -- update widget
    if not title then
      myclosebutton.image = beautiful.titlebar_close_button_focus
      mymaximizebutton.image = beautiful.titlebar_maximized_button_focus_active
      myminimizebutton.image = beautiful.titlebar_minimize_button_focus
      awful.titlebar.hide(c)
    else
      myclosebutton.image = nil
      mymaximizebutton.image = nil
      myminimizebutton.image = nil
      awful.titlebar.show(c)
    end

  end
end

client.connect_signal("property::floating", decide_border)
client.connect_signal("property::maximized", decide_border)
client.connect_signal("property::maximized_horizontal", decide_border)
client.connect_signal("property::maximized_vertical", decide_border)
client.connect_signal("unfocus", decide_border)
client.connect_signal("focus", decide_border)
client.connect_signal("manage", decide_border)
client.connect_signal("property::geometry", function(c)
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
  awful.titlebar(c, { position = "top", --[[size = 30]] }) : setup {
    layout = wibox.layout.align.horizontal,
    { -- left
    layout  = wibox.layout.fixed.horizontal,
      awful.titlebar.widget.floatingbutton (c),
    },
    { -- middle
      layout  = wibox.layout.flex.horizontal,
      {
        align  = "center",
        widget = titlebarcaption,
      },
      buttons = buttons
    },
    { -- right
      layout = wibox.layout.fixed.horizontal(),
      minimizebutton(c),
      maximizedbutton(c),
      closebutton(c)
    }
  }
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
