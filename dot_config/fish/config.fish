if test -z "$HOMEBREW_PREFIX"
  if test -e /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  end
end
if status is-interactive
    #set -g BAT_THEME Dracula
    # Commands to run in interactive sessions can go here
    #set ayu_variant mirage
    # set -a fish_complete_path ~/.local/share/fish/vendor_completions.d
    if test -n "$HOMEBREW_PREFIX"
      set -ag fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
      scheme set dracula
      set -x EXA_STANDARD_OPTIONS --long -aa --group --header --icons
      alias ls="exa --icons -a"
      alias bat="bat --theme=Dracula"
      alias cat=bat
      alias vim=nvim
      set fzf_preview_dir_cmd exa --all --color=always --icons
      zoxide init fish | source
    end
end

function ssh
  set ps_res (ps -p (ps -p %self -o ppid= | xargs) -o comm=)
  # if [ "$ps_res" = "tmux" ]
  if set -q TMUX
    tmux rename-window (echo $argv | cut -d . -f 1)
    command ssh "$argv"
    tmux set-window-option automatic-rename "on" 1>/dev/null
  else
    command ssh "$argv"
  end
end
