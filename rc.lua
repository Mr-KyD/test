-- VARIABLES--{{{
-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
wibox = require("wibox")

-- Theme handling library
beautiful = require("beautiful")

-- Notification library
naughty = require("naughty")
menubar = require("menubar")

-- Vicious Library
vicious = require("vicious")--}}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/ferb/.config/awesome/themes/dot/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
uterminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating, 				--1
--    awful.layout.suit.tile,					--2
--    awful.layout.suit.tile.left,			--3
--    awful.layout.suit.tile.bottom,		--4
--    awful.layout.suit.tile.top,			--5
    awful.layout.suit.fair,					--6
--    awful.layout.suit.fair.horizontal,	--7
--    awful.layout.suit.spiral,				--8
--    awful.layout.suit.spiral.dwindle,	--9
--    awful.layout.suit.max,					--10
--    awful.layout.suit.max.fullscreen,	--11
--    awful.layout.suit.magnifier			--12
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags 
-- Define a tag table which hold all screen tags.
tags = {
	names = {"F", "U", "N", "T", "O", "O"},
	layout = { layouts[1], layouts[1], layouts[2], layouts[1], layouts[1], layouts[1] },
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

myterminals= {
				{ "Terminator", "/usr/bin/terminator" },
				{ "Xterm", "/usr/bin/xterm" },
				{ "Urxvt", "/usr/bin/urxvt" }
}

mywebclient = {
				{ "Firefox", "/usr/bin/firefox-bin" },
				{ "Chromium", "/usr/bin/chromium" }
			}

mymailclient = {
				{ "Claws", "/usr/bin/claws-mail" }
}

myoffice = {
				{ "Libre Office", "/usr/bin/libreoffice" },
				{ "Calc", "/usr/bin/localc" },
				{ "Writer", "/usr/bin/lowriter" },
				{ "Gvim", "/usr/bin/gvim" }
}

mygames = {
			{ "Steam", "STEAM_RUNTIME=1 /usr/bin/steam"}
	}

mydonwloads = {
		{"Jdonwloader","/usr/bin/java -jar ~/.jd/jdupdate.jar NIGHTLY"}
	}
myconfigs = {
			{ "Adobe Flash", "/usr/bin/flash-player-properties"},
			{ "Java", "/usr/bin/jcontrol"}
	}

mymainmenu = awful.menu({ items = { { "HOME", "/usr/bin/thunar", beautiful.awesome_icon },
												{ "Terminals", myterminals },
												{ "Web", mywebclient },
												{ "Mail", mymailclient },
												{ "Office", myoffice },
												{ "Games", mygames },
												{ "awesome", myawesomemenu },
												{ "Configs", myconfigs }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

--- {{{Date
date_icon = wibox.widget.imagebox()
date_icon:set_image(beautiful.widget_reloj)
date_widget = wibox.widget.textbox()
vicious.register(date_widget, vicious.widgets.date, "%b %d, %T", 1)

--- {{{ CALENDARIO
-- Calendar attached to the textclock
local os = os
local string = string
local table = table
local util = awful.util

char_width = nil
text_color = theme.fg_normal or "#FFFFFF"
today_color = theme.fg_focus or "#00FF00"
calendar_width = 21

local calendar = nil
local offset = 0

local data = nil

local function pop_spaces(s1, s2, maxsize)
   local sps = ""
   for i = 1, maxsize - string.len(s1) - string.len(s2) do
      sps = sps .. " "
   end
   return s1 .. sps .. s2
end

local function create_calendar()
   offset = offset or 0

   local now = os.date("*t")
   local cal_month = now.month + offset
   local cal_year = now.year
   if cal_month > 12 then
      cal_month = (cal_month % 12)
      cal_year = cal_year + 1
   elseif cal_month < 1 then
      cal_month = (cal_month + 12)
      cal_year = cal_year - 1
   end

   local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
                                            month = cal_month + 1}) - 86400)
   local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
   local first_day_in_week =
      os.date("%w", first_day)
   local result = "do lu ma mi ju vi sa\n"
   for i = 1, first_day_in_week do
      result = result .. "   "
   end

   local this_month = false
   for day = 1, last_day do
      local last_in_week = (day + first_day_in_week) % 7 == 0
      local day_str = pop_spaces("", day, 2) .. (last_in_week and "" or " ")
      if cal_month == now.month and cal_year == now.year and day == now.day then
         this_month = true
         result = result ..
            string.format('<span weight="bold" foreground = "%s">%s</span>',
                          today_color, day_str)
      else
         result = result .. day_str
      end
      if last_in_week and day ~= last_day then
         result = result .. "\n"
      end
   end

   local header
   if this_month then
      header = os.date("%a, %d %b %Y")
   else
      header = os.date("%B %Y", first_day)
   end
   return header, string.format('<span font="%s" foreground="%s">%s</span>',
                                theme.font, text_color, result)
end

local function calculate_char_width()
   return beautiful.get_font_height(theme.font) * 0.555
end

function hide()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function show(inc_offset)
   inc_offset = inc_offset or 0

   local save_offset = offset
   hide()
   offset = save_offset + inc_offset

   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               position = "bottom_right",
										 timeout = 0, hover_timeout = 0.5,
                            })
end

date_widget:connect_signal("mouse::enter", function() show(0) end)
date_widget:connect_signal("mouse::leave", hide)
date_widget:buttons(util.table.join( awful.button({ }, 1, function() show(-1) end),
                                     awful.button({ }, 3, function() show(1) end)))
-- }}}

-- {{{ SEPARADOR
separador_widget = wibox.widget.textbox()
separador_widget:set_text(" |")

-- }}}

-- {{{ ESPACIO
espacio_widget = wibox.widget.textbox()
espacio_widget:set_text(" ")

-- }}}

-- {{{ OS INFO
os_icon = wibox.widget.imagebox()
os_icon:set_image(beautiful.widget_os)
os_widget = wibox.widget.textbox()
vicious.register(os_widget,vicious.widgets.os,"$1 $2")
-- }}}

-- {{{ BATERIA
bat_icon = wibox.widget.imagebox()
bat_icon:set_image(beautiful.widget_batt)
bat_widget = wibox.widget.textbox()
vicious.register(bat_widget,vicious.widgets.bat, "$3",61,"BAT0")
battperc_widget = wibox.widget.textbox()
vicious.register(battperc_widget,vicious.widgets.bat,"%\$2",61,"BAT0")
-- }}}

-- {{{ TEMPERATURA
temperature_icon = wibox.widget.imagebox()
temperature_icon:set_image(beautiful.widget_ice)
temperature_widget = wibox.widget.textbox()
vicious.register(temperature_widget,vicious.widgets.thermal,"$1\°C",60, "thermal_zone0")
-- }}}

-- {{{ UPTIME
uptime_icon = wibox.widget.imagebox()
uptime_icon:set_image(beautiful.widget_uptime)
uptime_widget = wibox.widget.textbox()
vicious.register(uptime_widget,vicious.widgets.uptime, "$4 $5 $6")
--uptime_widget:buttons( awful.button({ }, 1, function () awful.util.spawn(uterminal .. " -g 120x25+250+250 -e htop") end) )
uptime_widget:connect_signal("mouse::enter", function() awful.util.spawn(uterminal .. " -g 120x25+250+250 -e htop") end)
uptime_widget:connect_signal("mouse::leave", function() awful.util.spawn(uterminal .. " -e killall htop") end)

-- }}}

-- {{{ MEMORIA
mem_icon = wibox.widget.imagebox()
mem_icon:set_image(beautiful.widget_mem)
mem_widget = wibox.widget.textbox()
vicious.register(mem_widget,vicious.widgets.mem, "$2MB / $3MB")
-- }}}

-- {{{ DISCOS
root_icon = wibox.widget.imagebox()
root_icon:set_image(beautiful.widget_root)
root_widget = wibox.widget.textbox()
vicious.register(root_widget,vicious.widgets.fs,"${/ used_gb}GB / ${/ size_gb}GB",599)

home_icon = wibox.widget.imagebox()
home_icon:set_image(beautiful.widget_home)
home_widget = wibox.widget.textbox()
vicious.register(home_widget,vicious.widgets.fs,"${/home/ferb used_gb}GB / ${/home/ferb size_gb}GB",599)
home_widget:buttons( awful.button({ }, 1, function () awful.util.spawn(uterminal .. " -g 120x25+250+250 -e htop") end) )
-- }}}

-- {{{ CLIMA
weather_icon = wibox.widget.imagebox()
weather_icon:set_image(beautiful.widget_temp)
weather_widget = wibox.widget.textbox()
vicious.register(weather_widget,vicious.widgets.weather, "${tempc}\°C" ,1800,"SABE")
-- }}}

-- {{{ WIFI 
wifi_icon = wibox.widget.imagebox()
wifi_icon:set_image(beautiful.widget_wifi)
wifi_icon:connect_signal('mouse::enter', function () awful.util.spawn("urxvt -g 80x15+800+560 +sb -e wicd-curses") end) 
wifi_icon:connect_signal('mouse::leave', function () awful.util.spawn("killall wicd-curses") end) 
--wifi_widget = wibox.widget.textbox()
--vicious.register(wifi_widget,vicious.widgets.wifi, "${ssid} %${link}",3,"wlan0")
--wifi_icon:connect_signal("mouse::enter", function() awful.util.spawn(uterminal .. " -g 120x25+250+250 -e htop") end)
--wifi_icon:connect_signal("mouse::leave", function() awful.util.spawn(uterminal .. " -e killall htop") end)

-- }}}

--{{{ VOLUME--{{{

volume_icon = wibox.widget.imagebox()
volume_icon:set_image(beautiful.widget_vol)
volume_widget = wibox.widget.textbox()
vicious.register(volume_widget,vicious.widgets.volume,"$1", 1, "Master")
volume_widget:connect_signal("mouse::enter", function() awful.util.spawn(uterminal .. " -g 120x25+250+250 -e alsamixer") end)
volume_widget:connect_signal("mouse::leave", function() awful.util.spawn(uterminal .. " -e killall alsamixer") end)

--}}}--}}}

-- Create a wibox for each screen and add it
wibox_top = {}
wibox_bottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- WIBOX TOP
    wibox_top[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_top_layout = wibox.layout.fixed.horizontal()
    --left_top_layout:add(mylauncher)
    left_top_layout:add(mytaglist[s])
    left_top_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_top_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_top_layout:add(wibox.widget.systray()) end
    right_top_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout_top = wibox.layout.align.horizontal()
    layout_top:set_left(left_top_layout)
    layout_top:set_middle(mytasklist[s])
    layout_top:set_right(right_top_layout)

    wibox_top[s]:set_widget(layout_top)

	 --WIBOX BOTTOM
    wibox_bottom[s] = awful.wibox({ position = "bottom", screen = s })

	 -- Widgets that are aligned to the left
    left_bottom_layout = wibox.layout.fixed.horizontal()
    	 left_bottom_layout:add(mylauncher)
	 left_bottom_layout:add(espacio_widget)
	 --left_bottom_layout:add(os_icon)
	 left_bottom_layout:add(os_widget)
	 left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(bat_icon)
	 left_bottom_layout:add(bat_widget)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(battperc_widget)
    left_bottom_layout:add(separador_widget)
    left_bottom_layout:add(weather_icon)
    left_bottom_layout:add(weather_widget)
    left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(temperature_icon)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(temperature_widget)
	 left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(uptime_icon)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(uptime_widget)
	 left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(mem_icon)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(mem_widget)
	 left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(root_icon)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(root_widget)
	 left_bottom_layout:add(separador_widget)
	 left_bottom_layout:add(home_icon)
	 left_bottom_layout:add(espacio_widget)
	 left_bottom_layout:add(home_widget)

	 -- Widgets that are aligned to the right
    right_bottom_layout = wibox.layout.fixed.horizontal()
	 right_bottom_layout:add(wifi_icon)
	 --right_bottom_layout:add(espacio_widget)
	 right_bottom_layout:add(separador_widget)
	 right_bottom_layout:add(espacio_widget)
	 right_bottom_layout:add(volume_icon)
	 right_bottom_layout:add(espacio_widget)
    right_bottom_layout:add(volume_widget)
	 right_bottom_layout:add(separador_widget)
	 right_bottom_layout:add(espacio_widget)
	 right_bottom_layout:add(date_widget)
    
	 -- Now bring it all together (with the tasklist in the middle)
    local layout_bottom = wibox.layout.align.horizontal()
    layout_bottom:set_left(left_bottom_layout)
    layout_bottom:set_right(right_bottom_layout)
	 
	 --Putting Widget's
    wibox_bottom[s]:set_widget(layout_bottom)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ }, "Print", function () awful.util.spawn("scrot '%Y-%m-%d_%T.png' -e 'mv $f ~/prints 2>/dev/null'") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
 
 	 -- Control de Volumen
	 awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer sset Master 5%+") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer sset Master 5%-") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
   -- { rule = { class = "MPlayer" }, properties = { floating = true } },
   -- { rule = { class = "pinentry" }, properties = { floating = true } },
   -- { rule = { class = "gimp" },properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
     { rule = { class = "Terminator" },properties = { tag = tags[1][1] } },
     { rule = { class = "Firefox" }, properties = { tag = tags[1][2] } },
     { rule = { class = "Midori" }, properties = { tag = tags[1][2] } },
     { rule = { class = "XTerm" },properties = { tag = tags[1][3] } },
     { rule = { class = "Claws-mail" },properties = { tag = tags[1][4] } },
     { rule = { class = "Xfburn" },properties = { tag = tags[1][4] } },
     { rule = { class = "Pidgin" },properties = { tag = tags[1][5] } },
     { rule = { class = "Acroread" },properties = { tag = tags[1][5] } },
     { rule = { class = "jd-Main" },properties = { tag = tags[1][6] } },
     { rule = { class = "jd-update-Main" },properties = { tag = tags[1][6] } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
