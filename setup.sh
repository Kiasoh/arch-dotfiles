#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/my-dotfiles"

echo "=== Arch Linux dotfiles setup ==="
echo ""

# --------------------------------------------------
# 1. System packages (install what this config uses)
# --------------------------------------------------
echo "==> Installing system packages..."
yay -S --needed --noconfirm \
    stow \
    zsh \
    oh-my-posh \
    neovim \
    kitty \
    hyprland \
    ml4w-hyprland \
    waybar \
    rofi \
    swaync \
    wlogout \
    wallust \
    waypaper \
    pywal \
    fastfetch \
    nwg-dock-hyprland \
    nwg-look \
    matugen \
    thefuck \
    zoxide \
    fzf \
    bat

# --------------------------------------------------
# 2. Install nvm (Node Version Manager)
# --------------------------------------------------
echo "==> Installing nvm..."
export NVM_DIR="$HOME/.config/nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    echo "    nvm already installed at $NVM_DIR"
fi

# --------------------------------------------------
# 3. Install oh-my-zsh
# --------------------------------------------------
echo "==> Installing oh-my-zsh..."
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "    oh-my-zsh already installed at $ZSH"
fi

# --------------------------------------------------
# 4. Deploy configs with stow
# --------------------------------------------------
echo "==> Deploying dotfiles with stow..."
cd "$DOTFILES"

# Packages to stow (each mirrors a ~/.config/<name> directory)
PACKAGES=(
    bashrc
    fastfetch
    hypr
    kitty
    matugen
    ml4w
    nvim
    nwg-dock-hyprland
    nwg-look
    ohmyposh
    rofi
    sway
    swaync
    wal
    wallust
    waybar
    waypaper
    wlogout
    zshrc
)

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "    stow $pkg"
        stow "$pkg" 2>/dev/null || echo "    WARNING: stow $pkg failed (may already be deployed)"
    fi
done

# Deploy .zshrc (separate because it goes to ~/, not ~/.config/)
if [ -d ".zshrc" ]; then
    echo "    stow .zshrc"
    stow ".zshrc" 2>/dev/null || echo "    WARNING: stow .zshrc failed"
fi

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Notes:"
echo "  - nvm was installed to \$HOME/.config/nvm (sourced in .zshrc)"
echo "  - oh-my-zsh was installed to \$HOME/.oh-my-zsh (sourced in .zshrc)"
echo "  - ml4w wallpaper cache is auto-generated — not tracked in git"
echo "  - Run 'chsh -s /usr/bin/zsh' to set zsh as default shell"
