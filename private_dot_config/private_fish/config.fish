eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
if status is-interactive
    #set -g BAT_THEME Dracula
    # Commands to run in interactive sessions can go here
    #set ayu_variant mirage
    scheme set dracula
    set -x EXA_STANDARD_OPTIONS --long --all --group --header --icons
    alias ls="exa --icons"
    alias bat="bat --theme=Dracula"
    alias cat=bat
    alias vim=nvim
    set fzf_preview_dir_cmd exa --all --color=always --icons
end
