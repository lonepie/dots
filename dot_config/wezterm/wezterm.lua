-- local dracula = require 'dracula';
local wezterm = require 'wezterm';
local act = wezterm.action
local mux = wezterm.mux

local hostname = wezterm.hostname();
-- Powerline dividers
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0); -- The  symbol
local RIGHT_ARROW = utf8.char(0xe0b1);       -- The  symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2);  -- The  symbol
local LEFT_ARROW = utf8.char(0xe0b3);        -- The  symbol
-- Foreground color for the text across the tabs
local tab_text_fg = "#f8f8f2";
-- Color of the empty space in the middle of the status bar
local tab_empty_bg = "#282a36";

-- Color palette for the backgrounds of right status tab cells
local tab_segment_colors = {
  "#bd93f9",
  "#6272a4",
  "#44475a",
  "#282a36",
};
wezterm.on("toggle-ligature", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.harfbuzz_features then
    -- If we haven't overridden it yet, then override with ligatures disabled
    overrides.harfbuzz_features =  {"calt=0", "clig=0", "liga=0"}
  else
    -- else we did already, and we should disable our override now
    overrides.harfbuzz_features = nil
  end
  window:set_config_overrides(overrides)
end)



wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local edge_background = "#282a36"
  local background = "#6272a4"
  local foreground = tab_text_fg

  if tab.is_active then
    background = "#bd93f9"
  elseif hover then
    background = "#ffb86c"
  end

  local edge_foreground = background

  -- ensure that the titles plus decorations fit in the available space,
  -- and that we have room for the edges.
  local title = wezterm.truncate_right(tab.active_pane.title, max_width-5)
  local elements = {};
  if tab.tab_index > 0 then
     table.insert(elements, {Background={Color=edge_foreground}});
     table.insert(elements, {Foreground={Color=edge_background}});
     table.insert(elements, {Text=SOLID_RIGHT_ARROW});
  else
     table.insert(elements, {Text=" "});
  end
  table.insert(elements, {Background={Color=background}});
  table.insert(elements, {Foreground={Color=foreground}});
  table.insert(elements, {Text=(tab.tab_index + 1) .. " › " .. title .. " "});
  table.insert(elements, {Background={Color=edge_background}});
  table.insert(elements, {Foreground={Color=edge_foreground}});
  table.insert(elements, {Text=SOLID_RIGHT_ARROW});
  return elements;
end)

wezterm.on("update-right-status", function(window, pane)
  -- Each element holds the text for a cell
  local cells = {};

  -- Show which key table is active in status area
  -- local tablename = window:active_key_table();
  -- table.insert(cells, tablename or "no table");

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    cwd_uri = cwd_uri:sub(8);
    local slash = cwd_uri:find("/")
    local cwd = ""
    local hostname = ""
    if slash then
      hostname = cwd_uri:sub(1, slash-1)
      -- Remove the domain name portion of the hostname
      local dot = hostname:find("[.]")
      if dot then
        hostname = hostname:sub(1, dot-1)
      end
      -- and extract the cwd from the uri
      cwd = cwd_uri:sub(slash)

      table.insert(cells, cwd);
      table.insert(cells, hostname);
    end
  end

  -- Show which workspace is active in status area
  local workspacename = window:active_workspace();
  table.insert(cells, workspacename);

  -- I like my date/time in this style: "Wed Mar 3 08:14"
  -- local date = wezterm.strftime("%a %Y-%m-%d %H:%M");
  local date = wezterm.strftime("%H:%M");
  table.insert(cells, date);

  -- The elements to be formatted
  local elements = {};
  local total_cells = #cells; -- How many cells to format
  local num_cells = 0;        -- How many cells have been formatted

  -- Translate a cell into elements in a "powerline" style << fade
  function push(text, is_last)
    local segment_color_idx = total_cells - num_cells
    if num_cells == 0 then
      table.insert(elements, {Background={Color=tab_empty_bg}})
      table.insert(elements, {Foreground={Color=tab_segment_colors[segment_color_idx]}})
      table.insert(elements, {Text=LEFT_ARROW})
      table.insert(elements, {Text=SOLID_LEFT_ARROW})
    end
    table.insert(elements, {Foreground={Color=tab_text_fg}})
    table.insert(elements, {Background={Color=tab_segment_colors[segment_color_idx]}})
    table.insert(elements, {Text=" "..text.." "})
    if not is_last then
      table.insert(elements, {Foreground={Color=tab_segment_colors[segment_color_idx - 1]}})
      table.insert(elements, {Text=SOLID_LEFT_ARROW})
    end
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements));
end);

wezterm.on('mux-startup', function()
  local tab, pane, window = mux.spawn_window {}
  pane:split { direction = 'Top' }
end);

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  pane:split { direction = 'Top' }
  local tab2, pane2, window2 = window:spawn_tab {}
  pane2:split { direction = 'Top' }
end);

local font_normal = {
  family = 'FiraCode Nerd Font',
  weight = 'Regular',
  italic = false
}

local font_italic = {
  family = 'VictorMono Nerd Font',
  weight = 'DemiBold',
  italic = true
}

function load_font(font)
  return wezterm.font(font.family, {
    weight = font.weight,
    italic = font.italic
  })
end

function load_colors(colors)
    --[[
    -- Appearance of non-fancy tab bar
    colors = {
      selection_fg = "#cccccc",
      selection_bg = "#444488",

      tab_bar = {
         -- The color of the strip that goes along the top of the window
         -- (does not apply when fancy tab bar is in use)
         background = tab_empty_bg,
         active_tab = {bg_color = "#00cc00", fg_color = tab_text_fg,},
         inactive_tab = {bg_color = "#005500", fg_color = tab_text_fg,},
         inactive_tab_hover = {bg_color = "#008800", fg_color = tab_text_fg,},
         new_tab = {bg_color = "#999900", fg_color = tab_text_fg,},
         new_tab_hover = {bg_color = "#dddd00", fg_color = tab_text_fg,}
      }
    },
  ]]
  --local my_dracula = wezterm.color.get_builtin_schemes()['Dracula (Official)']
  colors.cursor_bg = "#ffb86c";
    -- Overrides the text color when the current cell is occupied by the cursor
  colors.cursor_fg = "#282a36";
    -- Specifies the border color of the cursor when the cursor style is set to Block,
    -- or the color of the vertical or horizontal bar when the cursor style is set to
    -- Bar or Underline.
  colors.cursor_border = "#ffb86c";
  return colors;
end

return {
    -- color_scheme = "Dracula (Official)",
    colors = load_colors(wezterm.color.get_builtin_schemes()['Dracula (Official)']),
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    font_shaper = "Harfbuzz",
    -- default_prog = { "/home/linuxbrew/.linuxbrew/bin/fish", "-l" },
    -- font = wezterm.font("OperatorMono Nerd Font", {weight="Regular"}),
    -- font = wezterm.font("SFMono Nerd Font"),
    -- font = wezterm.font("FiraCode Nerd Font Mono", {}),
    font = wezterm.font_with_fallback({
      { family="VictorMono Nerd Font Mono", weight="DemiBold"},
      { family="Cascadia Code", harfbuzz_features={"zero"} },
      { family="FiraCode Nerd Font Mono", weight="Regular" },
      -- { family="CaskaydiaCove Nerd Font", harfbuzz_features={"zero"} },
      -- { family="MonoLisa", harfbuzz_features={"zero"} },
      -- { family="SFMono Nerd Font" },
      -- { family="Inconsolata Nerd Font", weight="Regular"},
      -- { family="Monoid Nerd Font", weight="Regular"},
      -- { family="FantasqueSansMono Nerd Font Mono", weight="Regular"},
      -- "FiraCode Nerd Font Mono",
    }),
    -- Fonts
    -- font = load_font(font_normal),
    font_rules = {
      {
        italic = true,
        font = load_font(font_italic) 
      }
    },
    font_size = 10,
    window_background_opacity = 0.8,
    window_padding = {
      top = 0,
      bottom = 0,
      left = 0,
      right = 0
    },
    leader = { key="a", mods="ALT", timeout_milliseconds=2000 },
    keys = {
      {key="\\", mods="LEADER", action=act.SplitHorizontal{domain="CurrentPaneDomain"}},
      {key="-", mods="LEADER", action=act.SplitVertical{domain="CurrentPaneDomain"}},
      {key="t", mods="LEADER", action=act.SpawnTab "CurrentPaneDomain" },
      {key="c", mods="LEADER", action=act.CloseCurrentPane{confirm=true}},
      {key="p", mods="LEADER", action=act.PasteFrom("PrimarySelection")},
      {key="a", mods="LEADER", action=act.AttachDomain "unix"},
      {key="d", mods="LEADER", action=act.DetachDomain {DomainName="unix"}},
      {key="y", mods="LEADER", action=act.ActivateCopyMode},
      {key="s", mods="LEADER", action=act.QuickSelect},
      {key="n", mods="LEADER", action=act.ActivateTabRelative(1)},
      {key="N", mods="LEADER", action=act.ActivateTabRelative(-1)},
      {key="h", mods="LEADER", action=act.ActivatePaneDirection('Left')},
      {key="j", mods="LEADER", action=act.ActivatePaneDirection('Down')},
      {key="k", mods="LEADER", action=act.ActivatePaneDirection('Up')},
      {key="l", mods="LEADER", action=act.ActivatePaneDirection('Right')},
      {key="H", mods="LEADER", action=act.AdjustPaneSize({'Left', 5})},
      {key="J", mods="LEADER", action=act.AdjustPaneSize({'Down', 5})},
      {key="K", mods="LEADER", action=act.AdjustPaneSize({'Up', 5})},
      {key="L", mods="LEADER", action=act.AdjustPaneSize({'Right', 5})},
      {key="`", mods="LEADER", action=act.ShowLauncher},
      -- default keybinds
      { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
      { key = 'Tab', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
      { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
      { key = '"', mods = 'ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
      { key = '"', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
      { key = '%', mods = 'CTRL', action = act.ActivateTab(4) },
      { key = '%', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
      { key = '%', mods = 'ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
      { key = '%', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
      { key = "'", mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
      { key = ')', mods = 'CTRL', action = act.ResetFontSize },
      { key = ')', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
      { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
      { key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
      { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
      { key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
      { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
      { key = '-', mods = 'LEADER', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
      { key = '0', mods = 'CTRL', action = act.ResetFontSize },
      { key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
      { key = '0', mods = 'SUPER', action = act.ResetFontSize },
      { key = '1', mods = 'SHIFT|CTRL', action = act.ActivateTab(0) },
      { key = '1', mods = 'SUPER', action = act.ActivateTab(0) },
      { key = '2', mods = 'SHIFT|CTRL', action = act.ActivateTab(1) },
      { key = '2', mods = 'SUPER', action = act.ActivateTab(1) },
      { key = '3', mods = 'SHIFT|CTRL', action = act.ActivateTab(2) },
      { key = '3', mods = 'SUPER', action = act.ActivateTab(2) },
      { key = '4', mods = 'SHIFT|CTRL', action = act.ActivateTab(3) },
      { key = '4', mods = 'SUPER', action = act.ActivateTab(3) },
      { key = '5', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
      { key = '5', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
      { key = '5', mods = 'SUPER', action = act.ActivateTab(4) },
      { key = '6', mods = 'SHIFT|CTRL', action = act.ActivateTab(5) },
      { key = '6', mods = 'SUPER', action = act.ActivateTab(5) },
      { key = '7', mods = 'SHIFT|CTRL', action = act.ActivateTab(6) },
      { key = '7', mods = 'SUPER', action = act.ActivateTab(6) },
      { key = '8', mods = 'SHIFT|CTRL', action = act.ActivateTab(7) },
      { key = '8', mods = 'SUPER', action = act.ActivateTab(7) },
      { key = '9', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
      { key = '9', mods = 'SUPER', action = act.ActivateTab(-1) },
      { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
      { key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
      { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
      { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
      { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
      { key = 'F', mods = 'CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
      { key = 'F', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
      { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize{ 'Left', 5 } },
      { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize{ 'Down', 5 } },
      { key = 'K', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
      { key = 'K', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
      { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize{ 'Up', 5 } },
      { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
      { key = 'L', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
      { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize{ 'Right', 5 } },
      { key = 'M', mods = 'CTRL', action = act.Hide },
      { key = 'M', mods = 'SHIFT|CTRL', action = act.Hide },
      { key = 'N', mods = 'CTRL', action = act.SpawnWindow },
      { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
      { key = 'N', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
      { key = 'P', mods = 'CTRL', action = act.PaneSelect{ alphabet =  '', mode =  'Activate' } },
      { key = 'P', mods = 'SHIFT|CTRL', action = act.PaneSelect{ alphabet =  '', mode =  'Activate' } },
      { key = 'R', mods = 'CTRL', action = act.ReloadConfiguration },
      { key = 'R', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
      { key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
      { key = 'T', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
      { key = 'U', mods = 'CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
      { key = 'U', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
      { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
      { key = 'V', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
      { key = 'W', mods = 'CTRL', action = act.CloseCurrentTab{ confirm = true } },
      { key = 'W', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
      { key = 'X', mods = 'CTRL', action = act.ActivateCopyMode },
      { key = 'X', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
      { key = 'Z', mods = 'CTRL', action = act.TogglePaneZoomState },
      { key = 'Z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
      { key = '[', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
      { key = '\\', mods = 'LEADER', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
      { key = ']', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
      { key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
      { key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
      { key = '`', mods = 'LEADER', action = act.ShowLauncher },
      { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
      { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
      { key = 'c', mods = 'LEADER', action = act.CloseCurrentPane{ confirm = true } },
      { key = 'f', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
      { key = 'f', mods = 'SUPER', action = act.Search 'CurrentSelectionOrEmptyString' },
      { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
      { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
      { key = 'k', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
      { key = 'k', mods = 'SUPER', action = act.ClearScrollback 'ScrollbackOnly' },
      { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
      { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
      { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
      { key = 'm', mods = 'SHIFT|CTRL', action = act.Hide },
      { key = 'm', mods = 'SUPER', action = act.Hide },
      { key = 'n', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
      { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
      { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
      { key = 'p', mods = 'SHIFT|CTRL', action = act.PaneSelect{ alphabet =  '', mode =  'Activate' } },
      { key = 'p', mods = 'LEADER', action = act.PasteFrom 'PrimarySelection' },
      { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
      { key = 'r', mods = 'SUPER', action = act.ReloadConfiguration },
      { key = 's', mods = 'LEADER', action = act.QuickSelect },
      { key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
      { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
      { key = 'u', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
      { key = 'v', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
      { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
      { key = 'w', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
      { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab{ confirm = true } },
      { key = 'x', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
      { key = 'y', mods = 'LEADER', action = act.ActivateCopyMode },
      { key = 'z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
      { key = '{', mods = 'SUPER', action = act.ActivateTabRelative(-1) },
      { key = '{', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
      { key = '}', mods = 'SUPER', action = act.ActivateTabRelative(1) },
      { key = '}', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
      { key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },
      { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
      { key = 'PageUp', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
      { key = 'PageUp', mods = 'SHIFT|SUPER', action = act.MoveTabRelative(-1) },
      { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
      { key = 'PageDown', mods = 'CTRL', action = act.ActivateTabRelative(1) },
      { key = 'PageDown', mods = 'SHIFT|SUPER', action = act.MoveTabRelative(1) },
      { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
      { key = 'LeftArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Left', 1 } },
      { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
      { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Right', 1 } },
      { key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
      { key = 'UpArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Up', 1 } },
      { key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
      { key = 'DownArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Down', 1 } },
      { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
      { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
      { key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
      { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
    },
    default_cursor_style = "BlinkingBlock",
    cursor_blink_rate = 1000,
    cursor_blink_ease_in = "EaseOut",
    cursor_blink_ease_out = "EaseOut",
    ssh_domains = {
      {
        name = 'birbserv',
        remote_address = 'birbserv',
        username = 'jon'
      },
      {
        name = 'procyon',
        remote_address = 'procyon',
        username = 'jon'
      }
    },
    unix_domains = {
      {
        name = 'unix',
      },
      {
        name = 'localhost',
      }
    },
    default_gui_startup_args = { 'connect', 'unix' },
    tab_bar_style = {
      -- new_tab = "",
      new_tab = wezterm.format({
        {Background={Color="#282a36"}},
        {Foreground={Color="#282a36"}},
        {Text=SOLID_LEFT_ARROW},
        {Background={Color="#282a36"}},
        {Foreground={Color=tab_text_fg}},
        {Text="+"},
        {Background={Color="#282a36"}},
        {Foreground={Color="#282a36"}},
        {Text=SOLID_RIGHT_ARROW},
      }),
    },
    key_tables = {
      copy_mode = {
        { key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
        { key = 'Tab', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
        { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'Space', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
        { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
        { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
        { key = 'H', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
        { key = 'L', mods = 'NONE', action = act.CopyMode 'MoveToViewportBottom' },
        { key = 'L', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
        { key = 'M', mods = 'NONE', action = act.CopyMode 'MoveToViewportMiddle' },
        { key = 'M', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
        { key = 'O', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
        { key = 'O', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
        { key = 'V', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Line' } },
        { key = 'V', mods = 'SHIFT', action = act.CopyMode{ SetSelectionMode =  'Line' } },
        { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'b', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
        { key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
        { key = 'f', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
        { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
        { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
        { key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
        { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
        { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        { key = 'm', mods = 'ALT', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
        { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'v', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
        { key = 'v', mods = 'CTRL', action = act.CopyMode{ SetSelectionMode =  'Block' } },
        { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
        { key = 'y', mods = 'NONE', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
        { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'LeftArrow', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        { key = 'RightArrow', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
      },
      search_mode = {
        { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
        { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
        { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
        { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
      },
    }
}
