local dracula = require 'dracula';
local wezterm = require 'wezterm';
local act = wezterm.action
local mux = wezterm.mux

wezterm.on('mix-startup', function()
  local tab, pane, window = mux.spawn_window {}
  pane:split { direction = 'Top' }
end)

return {
    colors = dracula,
    color_scheme = "Dracula (Official)",
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
      }
    },
    default_gui_startup_args = { 'connect', 'unix' },
}
