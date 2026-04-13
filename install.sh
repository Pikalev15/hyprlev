#!/bin/bash
set -e

echo "Installing hyprlev dotfiles..."

# Install dependencies
echo "Installing stow..."
sudo pacman -S --needed stow git

# Clone if not already present
if [ ! -d "$HOME/hyprlev" ]; then
    git clone https://github.com/Pikalev15/hyprlev.git "$HOME/hyprlev"
fi

cd "$HOME/hyprlev/configs"

# Stow all packages
for dir in */; do
    echo "Stowing $dir..."
    stow --target="$HOME" "$dir"
done

echo "Done! Dotfiles installed."
