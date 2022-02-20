local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local hotkeys_popup = require("awful.hotkeys_popup").widget
local alttab = require("gobo.awesome.alttab")
require("awful.hotkeys_popup.keys")
require("modules.autostart")


-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true
		naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = tostring(err)
			})
		in_error = false
	end)
end

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.

local webbrowser = "firefox"
local filebrowser = "pcmanfm"
local terminal = "st"
local themes = {"notheme"}
local editor = "geany"
local chosen_theme = themes[1]
local modkey = "Mod4"
local altkey = "Mod1"
local vi_focus = false
local cycle_prev = true 
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/" .. chosen_theme 


awful.layout.layouts = {
	awful.layout.suit.tile, 
	awful.layout.suit.tile.bottom, 
	awful.layout.suit.fair,
	awful.layout.suit.spiral.dwindle
}


awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t) t:view_only()  end),
	awful.button({modkey}, 1,
		function(t)
			if client.focus then
				client.focus:move_to_tag(t.screen)
			end
		end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({modkey}, 3,
		function(t)
			if client.focus then
				client.focus:toggle_tag(t.screen)
			end
		end),
	awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
)

awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1,
		function(c)
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
	awful.button({}, 2, function(c) c:kill() end),
	awful.button({}, 4, function() awful.client.focus.byidx(-1) end),
	awful.button({}, 5, function() awful.client.focus.byidx(1) end)
)


beautiful.init(string.format("%s/theme.lua", theme_path))

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}


--{{{ Move client to same tag across screens
local function move_client_to_screen (c,s)
	local index = c.first_tag.index
	c:move_to_screen(s)
	local tag = c.screen.tags[index]
	c:move_to_tag(tag)
	if tag then tag:view_only() end
end

--}}}

-----------------------------------------------------
--------------  Global Key bindings   ---------------
-----------------------------------------------------
globalkeys = my_table.join(
    awful.key({ modkey,           }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ "Mod4", "Mod1" }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ "Mod4", "Mod1" }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey, "Shift" }, "b", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,         }, "b",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}
    ),

    -- Focus by index
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),


    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "f", function () awful.spawn(filebrowser) end,
              {description = "open file manager", group = "launcher"}),
    awful.key({ modkey,           }, "w", function () awful.spawn(web_browser) end,
              {description = "open web browser", group = "launcher"}),
    awful.key({ "Control",           }, "space", function () naughty.destroy_all_notifications() end,
              {description = "dismiss notifications", group = "awesome"}),
    awful.key({  }, "Print", function ()
        awful.spawn("scrot '%S.png' -e 'mv $f $$(xdg-user-dir PICTURES)/SS-%S-$wx$h.png ; feh --scale-down -B black $$(xdg-user-dir PICTURES)/SS-%S-$wx$h.png'")
        naughty.notify({ text = "Screenshot taken", icon = icons.camera })
    end,
              {description = "take screenshot", group = "launcher"}),
    -- Audio TODO CHECK IF WORKS OUT OF VM
    
	awful.key({}, "XF86AudioRaiseVolume",
		function()
			os.execute(string.format("amixer set %s 5%%+", beautiful.volume.channel))
			beautiful.volume.update()
		end, {description = "volume up", group = "hotkeys"}),
	awful.key({}, "XF86AudioLowerVolume",
		function()
			os.execute(string.format("amixer set %s 5%%-", beautiful.volume.channel))
			beautiful.volume.update()
		end, {description = "volume down", group = "hotkeys"}),
	awful.key({}, "XF86AudioMute",
		function()
			os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
			beautiful.volume.update()
		end, {description = "toggle mute", group = "hotkeys"}),
              
    -- Brightness TODO CHECK IF WORKS OUT OF VM
    awful.key({}, "XF86MonBrightnessDown", function()
            awful.spawn.with_shell("light -U 5")
            awesome.emit_signal("brightness")
        end, {
            description = "decrease brightness",
            group = "brightness",
        }),

	awful.key({}, "XF86MonBrightnessUp", function()
            awful.spawn.with_shell("light -A 5")
            awesome.emit_signal("brightness")
        end, {
            description = "increase brightness",
            group = "brightness",
        }),
        
        
    -- Awesome
              
    awful.key({modkey, "Control"}, "r",
		awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	awful.key({modkey, "Control"}, "q",
		awesome.quit,
		{description = "quit awesome", group = "awesome"}),
	
		
		
    -- Exit screen
    awful.key({ modkey, "Shift" }, "x", function() exit_screen_show() end,
              {description = "show exit screen", group = "awesome"}),
    awful.key({ modkey,           }, "Escape", function () exit_screen_show() end,
              {description = "show exit screen", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous layout", group = "layout"}),

    awful.key({ modkey, "Shift" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompts
    awful.key({ modkey },            "r",     function ()
        awful.prompt.run {
            prompt       = "<b>Run: </b>",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.spawn,
            completion_callback = awful.completion.shell,
            history_path = awful.util.get_cache_dir() .. "/history"
        }
    end,
    {description = "run prompt", group = "prompts"}),

    -- Lua execute prompt
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "<b>Run Lua code: </b>",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "prompts"}),
              
        -- Switch windows
   awful.key({ "Mod1" }, "Tab",
      function()
         alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
      end,
      { description = "Switch between windows", group = "awesome" }
   ),
   awful.key({ "Mod1", "Shift" }, "Tab",
      function()
         alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
      end,
      { description = "Switch between windows backwards", group = "awesome" }
   ),         
     

    -- Rofi
    awful.key({ modkey }, "d", function () awful.spawn("launch") end,
              {description = "rofi launcher", group = "launcher"})
)

-----------------------------------------------------
--------------  Client Key bindings   ---------------
-----------------------------------------------------
clientkeys = gears.table.join(
    -- Focus client by direction (arrow keys)
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),

    -- Relative move floating client (arrow keys)
    awful.key({ modkey, "Control", "Shift"   }, "Down",   function (c) c:relative_move(  0,  dpi(40),   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "Up",     function (c) c:relative_move(  0, -dpi(40),   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "Left",   function (c) c:relative_move(-dpi(40),   0,   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "Right",  function (c) c:relative_move( dpi(40),   0,   0,   0) end,
        {description = "relative move", group = "client"}),

    -- Resize client (arrow keys)
    -- Check helper function "resize" if you need to tweak the resize amount
    awful.key({ modkey, "Control"  }, "Down",
        function (c)
            resize(c, "down")
        end,
        {description = "resize downwards", group = "client"}),
    awful.key({ modkey, "Control"  }, "Up",
        function (c)
            resize(c, "up")
        end,
        {description = "resize upwards", group = "client"}),
    awful.key({ modkey, "Control"  }, "Left",
        function (c)
            resize(c, "left")
        end,
        {description = "resize to the left", group = "client"}),
    awful.key({ modkey, "Control"  }, "Right",
        function (c)
            resize(c, "right")
        end,
        {description = "resize to the right", group = "client"}),

    -- Move FLOATING client to edge or swap TILED client by direction (arrow keys)
    awful.key({ modkey, "Shift"  }, "Down",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "down")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("down", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Up",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "up")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("up", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Left",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "left")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("left", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Right",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "right")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("right", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),

    -- Toggle fullscreen
    awful.key({ modkey, "Shift"  }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    -- Close client
    awful.key({ modkey, 		  }, "q",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ "Mod1",           }, "F4",      function (c) c:kill() end,
              {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey }, "c",  function (c) awful.placement.centered(c,{honor_workarea=true})
             end,
              {description = "center", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag or go back to last tag if it is already selected
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           if tag == screen.selected_tag then
                               awful.tag.history.restore()
                           else
                               tag:view_only()
                           end
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Set Mouse buttons
clientbuttons = gears.table.join(
	awful.button({}, 1,
		function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
		end),
	awful.button({modkey, altkey}, 1, awful.client.movetotag),
	awful.button({modkey}, 1,
		function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			awful.mouse.client.move(c)
		end),
	awful.button({modkey}, 3,
		function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			awful.mouse.client.resize(c)
		end),
	awful.button({modkey}, 4,
		function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			awful.client.floating.toggle(c)
		end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	{rule = {},
	properties = {
		maximized_horizontal = false,
		maximized_vertical = false,
		maximized = false,
		border_width = beautiful.border_width + 1,
		border_color = beautiful.border_normal,
		focus = awful.client.focus.filter,
		raise = true,
		keys = clientkeys,
		buttons = clientbuttons,
		screen = awful.screen.preferred,
		placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		size_hints_honor = false}	
	},
	-- Floating clients
	{rule_any = {instance = {
				"DTA", -- Firefox addon DownThemAll. 
				"copyq", -- Includes session name in class.
				"pinentry",
				},
			class = {
				"Arandr", "Nautilus", "Gnome-calculator", "feh", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
				"Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui", "veromix", "xtightvncviewer",
				"xvkbd"},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {"Event Tester", -- xev.
				"xvkbd - Virtual Keyboard"
				},
			role = {"AlarmWindow", -- Thunderbird's calendar.
					"ConfigManager", -- Thunderbird's about:config.
					"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				}},
		properties = {floating = false}},
	{rule_any = {type = {"dialog", "normal"}}, properties = {titlebars_enabled = false}},
	{rule = {class = "Notepadqq", name = "Search"}, properties = {ontop = true}},
	{rule = {class = "Mate-calc", name = "Calculator"}, properties = {ontop = true}},
	{rule = {class = "CMST - Connman System Tray", name = "Connman System Tray"}, properties = {ontop = true}},
	{rule = {class = "Lxrandr", name = "Display Settings"}, properties = {ontop = true}},
		-- Set Firefox to always map on the tag named "2" on screen 1.
		-- { rule = { class = "Firefox" }, properties = { screen = 1, tag = "2" } },
}


-- Signal function to execute when a new client appears.
client.connect_signal("manage",
	function(c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end
		if awesome.startup 
			and not c.size_hints.user_position 
			and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
				awful.placement.no_offscreen(c)
		end
		c.shape = function(cr,w,h)
			gears.shape.rounded_rect(cr,w,h,6)
		end
	end
)


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter",
	function(c)
		c:emit_signal("request::activate", "mouse_enter", {raise = vi_focus})
	end
)
client.connect_signal("focus",
	function(c)
		c.border_color = beautiful.border_focus
 	end
)
client.connect_signal("unfocus",
	function(c)
		c.border_color = beautiful.border_normal
	end
)

-- Autostart
os.execute("picom -b --config ~/.config/picom/picom.conf --xrender-sync-fence --experimental-backends")
