#!/bin/bash

# Install Zsh
sudo apt-get update
sudo apt-get install -y zsh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone plugins and themes
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Set ZSH_THEME to Powerlevel10k in .zshrc
sed -i 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Enable the installed plugins by adding them to the plugins list in .zshrc
sed -i 's/plugins=.*/plugins=(zsh-autosuggestions zsh-syntax-highlighting kubectl docker git helm aliases)/' ~/.zshrc

# Restart the shell
exec zsh
