local dracula = require 'dracula';
local wezterm = require 'wezterm';
local act = wezterm.action
return {
    colors = dracula,
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    font_shaper = "Harfbuzz",
    -- default_prog = { "/home/linuxbrew/.linuxbrew/bin/fish", "-l" },
    -- font = wezterm.font("OperatorMono Nerd Font", {weight="Regular"}),
    -- font = wezterm.font("SFMono Nerd Font"),
    -- font = wezterm.font("FiraCode Nerd Font Mono", {}),
    font = wezterm.font_with_fallback({
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
    font_size = 10,
    window_background_opacity = 0.8,
    window_padding = {
      top = 0,
      bottom = 0,
      left = 0,
      right = 0
    },
    leader = { key="/", mods="SUPER", timeout_milliseconds=1000 },
    keys = {
      {key="\\", mods="LEADER", action=act.SplitHorizontal{domain="CurrentPaneDomain"}},
    },
    -- cursor_blink_rate = 800,
}
