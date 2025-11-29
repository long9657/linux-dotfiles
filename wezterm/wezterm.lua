-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
-- This will hold the configuration.
-- This is where you actually apply your config choices

local brightness = 0.05

-- Check if the OS is Windows or Unix-based
local background_folder = wezterm.config_dir .. "/bg"
local bg_image = wezterm.config_dir .. "/bg/m.jpg"
local function pick_random_background(folder)
	local file_name = string.char(math.random(string.byte("d"), string.byte("p")))
	return folder .. "/" .. file_name .. ".jpg"
end

-- Gpu Setup
-- local gpus = wezterm.gui.enumerate_gpus()
-- config.webgpu_preferred_adapter = gpus[2]
-- config.front_end = "WebGpu"
config.front_end = "OpenGL"
config.prefer_egl = true

-- Performance Settings
config.max_fps = 144
config.animation_fps = 60

-- Window Configuration
config.window_padding = {
	left = "0",
	right = "0",
	top = "0",
	bottom = "0",
}
config.adjust_window_size_when_changing_font_size = false
config.default_prog = { "pwsh.exe", "-NoLogo" }
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
-- config.colors.cursor_bg = "green"
-- config.colors.cursor_fg = "white"
-- config.colors.cursor_border = "purple"
config.window_close_confirmation = "NeverPrompt"

config.term = "xterm-256color" -- Set the terminal type

-- For example, changing the color scheme:
config.color_scheme = "Tokyo Night"
-- config.colors = require("cyberdream")
-- config.color_scheme = "Shades of Purple (base16)"

-- Font Setup
-- config.font = wezterm.font("FiraCode Nerd Font Mono")
-- config.font = wezterm.font("Monaspace Neon NF")
-- config.font = wezterm.font("BlexMono Nerd Font Mono")
-- config.font = wezterm.font("D2CodingLigature Nerd Font Mono")
config.font = wezterm.font("Comic Code")
-- config.font = wezterm.font("Iosevka Nerd Font")
-- config.font = wezterm.font("Hack Nerd Font Mono")
-- config.font = wezterm.font("Inconsolata Nerd Font Mono", { weight = "Regular", stretch = "Expanded" })
-- config.font = wezterm.font("Fixedsys Excelsior", { weight = "Bold" })
-- config.cell_width = 0.9
config.font_size = 18
-- config.custom_block_glyphs = false
config.allow_win32_input_mode = false
-- config.line_height = 1.2

-- Transperancy
config.window_background_opacity = 0.8 -- Set window opacity to 95% for better readability
-- config.window_background_opacity = 0.5
config.win32_system_backdrop = "Acrylic"

wezterm.on('window-resized', function(window, pane)
  -- Lấy kích thước cửa sổ hiện tại
  local dim = window:get_dimensions()
  
  -- Màn hình 4K thường rộng 3840px. 
  -- Ta đặt ngưỡng > 3000px để nhận diện là màn hình lớn/4K.
  if dim.pixel_width > 3000 then
    local tab = window:active_tab()
    if not tab then return end
    
    local panes = tab:panes()

    -- LOGIC CHÍNH:
    -- Chỉ thực hiện chia nếu tab hiện tại đang CHỈ CÓ 1 pane.
    -- Điều này tránh việc nó cứ chia liên tục mỗi khi bạn kéo nhẹ cửa sổ.
    if #panes == 1 then
      pane:split({
        direction = "Left",
        size = 0.3, -- Kích thước pane phụ (30%)
      })
      
      -- Sau khi chia xong, focus lại về pane chính bên phải
      window:perform_action(wezterm.action.ActivatePaneDirection("Right"), pane)
    end
  end
end)

-- Background
-- config.window_background_image = bg_image
-- config.window_background_image_hsb = {
-- 	-- Darken the background image by reducing it to 1/3rd
-- 	brightness = brightness,
--
-- 	-- You can adjust the hue by scaling its value.
-- 	-- a multiplier of 1.0 leaves the value unchanged.
-- 	hue = 1.0,
--
-- 	-- You can adjust the saturation also.
-- 	saturation = 0.8,
-- }
-- config.foreground_text_hsb = {
-- 	hue = 1.0,
-- 	saturation = 1.2,
-- 	brightness = 1.0,
-- }

--Keymaps
config.keys = {
	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT|ALT",
		action = act.ScrollByPage(-0.5),
	},

	{
		key = "j",
		mods = "CTRL|SHIFT|ALT",
		action = act.ScrollByPage(0.5),
	},
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local panes = tab:panes()

			if #panes == 1 then
				-- only one pane: create left split
				pane:split({
					direction = "Left",
					size = 0.3,
				})
				-- refocus original (right) pane
				window:perform_action(wezterm.action.ActivatePaneDirection("Right"), pane)
			else
				-- multiple panes: toggle off (close left one)
				-- move focus left, close it, then return to right
				window:perform_action(wezterm.action.ActivatePaneDirection("Left"), pane)
				window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), pane)
			end
		end),
	},
	-- {
	-- 	key = "H",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.ActivatePaneDirection("Left"),
	-- },
	-- {
	-- 	key = "L",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.ActivatePaneDirection("Right"),
	-- },
	--
	-- {
	-- 	key = "K",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.ActivatePaneDirection("Up"),
	-- },
	-- {
	-- 	key = "J",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = act.ActivatePaneDirection("Down"),
	-- },
	{
		key = "G",
		mods = "CTRL|SHIFT",
		action = act.OpenLinkAtMouseCursor,
	},
	{
		key = "U",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "O",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window)
			bg_image = pick_random_background(background_folder)
			window:set_config_overrides({
				window_background_image = bg_image,
			})
		end),
	},
	{
		key = ">",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window)
			brightness = math.min(brightness + 0.01, 1.0)
			window:set_config_overrides({
				window_background_image_hsb = {
					brightness = brightness,
					hue = 1.0,
					saturation = 0.8,
				},
				window_background_image = bg_image,
			})
		end),
	},
	{
		key = "<",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window)
			brightness = math.max(brightness - 0.01, 0.01)
			window:set_config_overrides({
				window_background_image_hsb = {
					brightness = brightness,
					hue = 1.0,
					saturation = 0.8,
				},
				window_background_image = bg_image,
			})
		end),
	},
}

-- and finally, return the configuration to wezterm
return config
