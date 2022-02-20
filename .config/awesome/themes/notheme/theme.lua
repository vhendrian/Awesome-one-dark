--{{{ Import necessary modules
local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")
--local dpi = require("beautiful.xresources").apply_dpi
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme = {}


--Catppuccin Colorscheme for lain widget
--	normal
--   1 black:   "#6E6C7E"
--   2 red:     "#F28FAD"
--   3 green:   "#ABE9B3"
--   4 yellow:  "#FAE3B0"
--   5 blue:    "#96CDFB"
--   6 magenta: "#F5C2E7"
--   7 cyan:    "#89DCEB"
--   8 white:   "#D9E0EE"

-- bright
--    black:   '0x988BA2'
--    red:     '0xF28FAD'
--    green:   '0xABE9B3'
--    yellow:  '0xFAE3B0'
--    blue:    '0x96CDFB'
--    magenta: '0xF5C2E7'
--    cyan:    '0x89DCEB'
--    white:   '0xD9E0EE'

theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/notheme"
--theme.font = "Dejavu Sans 9"
theme.font = "Sauce Code Pro Bold 9"
theme.icon_theme = "Adwaita"
--theme.mono_font = "Liberation Mono 10"
theme.mono_font = "Sauce Code Pro Semibold 9"
theme.opacity_normal = 0.95
theme.opacity_active = 1
theme.fg_normal = '#ABB2BF'
theme.fg_focus = '#ABB2BF'
theme.fg_urgent = '#ABB2BF'
theme.bg_normal = '#1e222a'
theme.bg_focus = '#383C44'
theme.bg_urgent = '#120900'
theme.bg_hover = '#515865'
theme.border_normal = '#383C44'
theme.border_focus = '#555C69'
theme.border_marked = '#ABB2BF'
theme.border_hover = '#515865'
theme.border_width = 1
theme.tasklist_bg_focus = '#383C44'
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = 4
theme.gap_single_client = true

theme.notification_font = theme.font
theme.notification_shape = gears.shape.rounded_rect
theme.notification_border_color = theme.border_focus
theme.notification_border_width = theme.border_width
theme.notification_opacity = theme.opacity_normal

theme.taglist_font = "Sauce Code Pro Bold 9"
theme.taglist_font_small = "Sauce Code Pro Bold 8"

theme.hotkeys_hide_without_description = false
theme.hotkeys_border_color = theme.border_hover
theme.hotkeys_border_width = theme.border_width
theme.hotkeys_font = theme.mono_font
theme.hotkeys_description_font = theme.mono_font
theme.hotkeys_shape = gears.shape.rounded_rect

beautiful.tooltip_border_color = theme.border_focus
beautiful.tooltip_border_width = theme.border_width
beautiful.tooltip_opacity = theme.opacity_normal
beautiful.tooltip_bg = theme.bg_normal
beautiful.tooltip_fg = theme.fg_normal
beautiful.tooltip_font = theme.font
beautiful.tooltip_shape = gears.shape.rounded_rect
beautiful.tooltip_align = "bottom"


theme.taglist_squares_sel = theme.dir .. "/icons/square.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square.png"


--}}}

local terminal = "st"

awful.util.tagnames = {" 1 ", " 2 ", " 3 ", " 4 ", " 5 "}


-- Textclock
local clock = awful.widget.watch("date +'%R'", 60, function(widget, stdout)
	widget:set_markup(" " .. stdout)
end)
-- Calendar
theme.cal = lain.widget.cal({
	attach_to = {clock},
	notification_preset = {
		font = theme.mono_font,
		fg = theme.fg_normal,
		bg = theme.bg_normal,
	}
})

-- MEM
local memicon = wibox.widget.textbox('<span color="#FAE3B0">MEM:  </span>')
local mem = lain.widget.mem({
	settings = function()
		widget:set_markup('<span color="#FAE3B0">' .. mem_now.used .. 'MB</span>')
	end
})

local mem_tooltip = awful.tooltip {
	objects = { memicon },
	margins_topbottom = 6,
	margins_leftright = 10,
	font = theme.mono_font,
	timer_function = function()
		local cmd = [[free -h | awk '{if ($NL<2) printf("\t%s\t%s\t%s\n",$1,$2,$3); else {for (i=1;i<=4;i++){printf("%s\t",$i)}print "" };}']]
		awful.spawn.easy_async_with_shell(cmd, function(result) mem_tooltip_text = result end)
		mem_tooltip_text = string.format("%s\n\n%s", "<b>Memory information</b>", mem_tooltip_text):gsub("\n[^\n]*$", "")
		return mem_tooltip_text
	end,
}

-- CPU
local cpuicon = wibox.widget.textbox('<span color="#F28FAD">CPU:  </span>')
local cpu = lain.widget.cpu({
		settings = function()
				widget:set_markup('<span color="#F28FAD">' .. cpu_now.usage .. '%</span>')
		end
})

local cpu_tooltip = awful.tooltip {
	objects = { cpuicon },
	margins_topbottom = 6,
	margins_leftright = 10,
	font = theme.mono_font,
	timer_function = function()
		local cmd = [[top -bn 1 | awk 'NR==7,NR==17 {printf("%s\t%s\t%s\t%s\n",$1,$2,$9,$12)}']]
		awful.spawn.easy_async_with_shell(cmd, function(result) cpu_tooltip_text = result end)
		cpu_tooltip_text = string.format("%s\n\n%s", "<b>Process information</b>", cpu_tooltip_text):gsub("\n[^\n]*$", "")
		return cpu_tooltip_text
	end,
}

-- FileSystem
local fsicon = wibox.widget.textbox('<span color="#F5C2E7">FS:  </span>')
local fsroot = awful.widget.watch([[bash -c "df -h / | tail -n 1 | awk '{print $(NF-1)}'"]], 15, function(widget,stdout) 
	widget:set_markup('<span color="#F5C2E7">' .. stdout .. '</span>')
end)

local fs_tooltip = awful.tooltip {
	objects = { fsicon },
	font = theme.mono_font,
	margins_topbottom = 6,
	margins_leftright = 10,
	timer_function = function()
		local cmd = [[df -h | grep -v 'tmpfs\|/sys']]
		awful.spawn.easy_async_with_shell(cmd, function(result) fs_tooltip_text = result end)
		fs_tooltip_text = string.format("%s", fs_tooltip_text):gsub("\n[^\n]*$", "")
		if fs_tooltip_text == "nil" then
			fs_tooltip_text = "<b>Filesystem not found</b>"
		else
			fs_tooltip_text = string.format("%s\n\n%s", "<b>Filesystem information</b>", fs_tooltip_text)
		end
		return fs_tooltip_text
	end,
}

-- Battery
local baticon = wibox.widget.textbox('<span color="#ABE9B3">BAT:  </span>')
local bat = lain.widget.bat({
		battery = "BAT1",
		settings = function()
			if bat_now.status ~= "N/A" then
				widget:set_markup('<span color="#ABE9B3">' .. bat_now.perc .. '%</span>')
			else
				widget:set_markup('<span color="#ABE9B3">' .. "AC" .. '</span>')
			end
		end
})

local bat_tooltip = awful.tooltip {
	objects = { baticon },
	margins_topbottom = 6,
	margins_leftright = 10,
	timer_function = function()
		if bat_now.status == "Charging" then
			bat_tooltip_text = "<b>Battery status</b>\n\n" .. bat_now.status .. "\n" .. bat_now.time .. " to charge\n" .. bat_now.watt .. "W (+)"
		elseif bat_now.status == "Discharging" then
			bat_tooltip_text = "<b>Battery status</b>\n\n" .. bat_now.status .. "\n" .. bat_now.time .. " remains\n" .. bat_now.watt .. "W (-)"
		elseif bat_now.status == "Full" then
			bat_tooltip_text = "<b>Battery status</b>\n\nBattery is full.\nYou can unplug."
		else
			bat_tooltip_text = "<b>Battery status</b>\n\nNot Available"
		end
		return bat_tooltip_text
	end,
}

-- Net
local neticon = wibox.widget.textbox('<span color="#ABE9B3">NET:  </span>')
local net = lain.widget.net({
	settings = function()
		widget:set_markup('<span color= "#ABE9B3">' .. net_now.received .. " ↓↑ " .. net_now.sent .. '</span>')
	end
})

local net_tooltip = awful.tooltip {
	objects = { neticon },
	font = theme.mono_font,
	margins_topbottom = 6,
	margins_leftright = 10,
	timer_function = function()
		local cmd = [[ip route get 1.1.1.1 | awk '{print "<b>Interface : </b>" $5 ORS "<b>Gateway   : </b>" $3 ORS "<b>Local IP  : </b>" $7}' | head -n 3 && echo -ne "<b>Public IP : </b>" && wget -T 1 -qO- ipecho.net/plain && ip addr show $(ip route get 1.1.1.1 | awk '{print $5}')  | head -n 2 | tail -n 1 | awk '{print ORS "<b>Device    : </b>" $2}']]
		awful.spawn.easy_async_with_shell(cmd, function(result) net_tooltip_text = result end)
		net_tooltip_text = string.format("%s", net_tooltip_text):gsub("\n[^\n]*$", "")
		if net_tooltip_text == "nil" or net_tooltip_text == "<b>No Network</b>" or net_tooltip_text == "<b>Public IP : </b>" then
			net_tooltip_text = "<b>No Network</b>"
		else
			net_tooltip_text = string.format("%s\n\n%s", "<b>Network information</b>", net_tooltip_text)
		end
		return net_tooltip_text
	end,
}

-- ALSA volume
local volicon = wibox.widget.textbox('<span color="#96CDFB">VOL:  </span>')
theme.volume = lain.widget.alsa({
		settings = function()
			if volume_now.status == "off" then
				volicon:set_markup('<span color="#96CDFB">VOL muted:  </span>')
			else
				volicon:set_markup('<span color="#96CDFB">VOL:  </span>')
			end
			widget:set_markup('<span color="#96CDFB">' .. volume_now.level .. '%</span>')
		end
	})

theme.volume.widget:buttons(awful.util.table.join(
	awful.button({}, 2, function()
		os.execute(string.format("%s set %s 100%%", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 1, function()
		os.execute(string.format("%s set %s toggle", theme.volume.cmd, theme.volume.togglechannel or theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 4, function ()
		awful.util.spawn("amixer set Master 5%+")
		theme.volume.update()
	end),
	awful.button({}, 5, function ()
		awful.util.spawn("amixer set Master 5%-")
		theme.volume.update()
	end)
))

volicon:buttons(awful.util.table.join(
	awful.button({}, 3, function()
		awful.spawn(string.format("%s -e pulsemixer", terminal))
	end))
)

local vol_tooltip = awful.tooltip {
	objects = { volicon },
	margins_topbottom = 6,
	margins_leftright = 10,
	timer_function = function()
		local cmd = [[pacmd list-sinks | sed -n '/*/,$!d; s/Built-in\ Audio\ //g; /device.description/ {s/.*"\(.*\)"[^"]*$/    \1/; s/[ \t]\?,[ \t]\?/,/g; s/^[ \t]\+//g; s/[ \t]\+$//g; p;q;}' | awk '{print "<b>Sink : </b>" $0}' && pacmd list-sources | sed -n '/*/,$!d; /device.description/ {s/.*"\(.*\)"[^"]*$/\1/;p;q;}' | awk '{print "<b>Source : </b>" $0}']]
		awful.spawn.easy_async_with_shell(cmd, function(result) vol_tooltip_text = result end)
		vol_tooltip_text = string.format("%s\n\n%s", "<b>Audio devices</b>", vol_tooltip_text):gsub("\n[^\n]*$", "")
	return vol_tooltip_text
	end,
}

--Systray
local systemtray = wibox.widget.systray()
systemtray:set_base_size(20)


-- Separators
local spr = wibox.widget.textbox('   ')
local slspr = wibox.widget.textbox(' ')

--}}}

--{{{ function that configures virtual spaces 
function theme.at_screen_connect(s)
	
	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.suit.tile)
	
	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt{prompt='<b>Run: </b>',fg='#BC3D39',bg_cursor='#BC3D39'}

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {shape = gears.shape.rounded_bar},
		layout = {
			spacing = 0,
			spacing_widget = {
				color = '#dddddd',
				bg_focus = '#daeeff',
				fg_focus = '#003040',
				shape = gears.shape.rounded_bar,
			},
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{
				{
					{
						id = 'text_role',
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin
			},
			id = 'background_role',
			widget = wibox.container.background,
		},
		buttons = awful.util.taglist_buttons
	}

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = awful.util.tasklist_buttons,
		style = {
			shape_border_width = theme.border_width,
			shape_border_color = theme.border_focus, 
			shape = gears.shape.rounded_bar,
		},
		layout = {
			spacing = 20,
			spacing_widget = {
				{
					forced_width = 5,
					shape = gears.shape.circle,
					widget = wibox.widget.separator
				},
				valign = 'center',
				halign = 'center',
				widget = wibox.container.place,
			},
			layout = wibox.layout.flex.horizontal
		},
		-- Notice that there is *NO* wibox.wibox prefix, it is a template,
		-- not a widget instance.
		widget_template = {
			{
				{
					{
						id	 = 'text_role',
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin
			},
			id	 = 'background_role',
			widget = wibox.container.background,
		},
	}
	--}}}
	local sgeo = s.geometry
	s.mywibox = wibox {
		position = "top",
		screen = s,
		bg = theme.bg_normal,
		fg = theme.fg_normal,
		width = screen[s].geometry.width - 16,
		height = 22, y = sgeo.y + 4, x = sgeo.x + 8,
		shape = gears.shape.rounded_bar,
		border_width = theme.border_width,
		border_color = theme.border_normal,
		visible = true,
	}
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			slspr,
			s.mypromptbox,
			slspr,
		},
		s.mytasklist,
		{
			spr,
			eth_icon,
			neticon,
			net,
			spr,
			cpuicon,
			cpu,
			spr,
			memicon,
			mem,
			spr,
			fsicon,
			fsroot,
			spr,
			volicon,
			theme.volume,
			spr,
			baticon,
			bat,
			slspr,
			layout = wibox.layout.fixed.horizontal,
			clock,
			slspr,
			wibox.layout.margin(systemtray,0,0,0,0),
			slpr,slspr,
		}
	}
	s.mywibox:struts({
		left=0, 
		right=0, 
		top=30, 
		bottom=0
	})
	--}}}
end
--}}}

return theme
