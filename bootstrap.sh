#!/bin/bash

# get some PPAs
sudo add-apt-repository ppa:fish-shell/release-3
sudo add-apt-repository ppa:neovim-ppa/unstable

#install packages
sudo apt install -y fish neovim build-essential fzf ripgrep fd-find

#install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install chezmoi procs btop bat dog starship exa

git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
# nvim +'hi NormalFloat guibg=#1e222a' +PackerSync

chezmoi init --apply https://github.com/lonepie/dots.git
