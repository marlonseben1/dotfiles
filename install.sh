#!/bin/bash

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

TOTAL_STEPS=10
step() {
    echo ""
    echo "[$1/$TOTAL_STEPS] $2"
}

echo " --- Starting the setup --- "

step 1 "Installing base packages"
sudo dnf upgrade -y
sudo dnf install -y git zsh util-linux-user curl

step 2 "Setting Zsh as the default terminal"
sudo chsh -s $(which zsh) $USER

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

step 3 "Installing pnpm"

curl -fsSL https://get.pnpm.io/install.sh | sh -

step 4 "Linking configuration files for Zsh"

ln -sf "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"

# The sync() helper in .zshrc reads personal/work emails and repo paths from
# ~/.config/fedora-setup.env, which is never committed to this repo.
if [ ! -f "$HOME/.config/fedora-setup.env" ]; then
    mkdir -p "$HOME/.config"
    cp "$DOTFILES_DIR/config/fedora-setup.env.example" "$HOME/.config/fedora-setup.env"
    echo "Created ~/.config/fedora-setup.env — fill it in with your real emails/repo paths before using the 'sync' command."
fi

step 5 "Installing Node and TypeScript globally"
export PATH="$HOME/.local/share/pnpm:$PATH"
PNPM_BIN="$HOME/.local/share/pnpm/pnpm"
$PNPM_BIN env use --global lts
$PNPM_BIN add -g typescript

step 6 "Idiom setup (English)"
sudo localectl set-locale LANG=en_US.UTF-8

step 7 "Installing and setting up Zed"

curl -f https://zed.dev/install.sh | sh

ZED_CONFIG_DIR="$HOME/.config/zed"
mkdir -p "$ZED_CONFIG_DIR"
ln -sf "$DOTFILES_DIR/config/settings.json" "$ZED_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_DIR/config/keymap.json" "$ZED_CONFIG_DIR/keymap.json"

step 8 "Installing SF Pro Font"
if [ -d "$DOTFILES_DIR/fonts" ]; then
    mkdir -p ~/.local/share/fonts
    cp -r "$DOTFILES_DIR/fonts/"* ~/.local/share/fonts/
    fc-cache -f
fi

step 9 "Setting up the theme I am currently using (I still do a few tweaks manually here)"
sudo dnf install -y sassc optipng inkscape

git clone https://github.com/vinceliuice/WhiteSur-kde.git /tmp/WhiteSur-kde
/tmp/WhiteSur-kde/install.sh --dest "$HOME/.local/share/aurorae/themes"

lookandfeeltool -a com.github.vinceliuice.WhiteSur-dark

git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons
/tmp/WhiteSur-icons/install.sh -a

step 10 "Custom KDE global shortcuts (window management)"
KGLOBALSHORTCUTS="$HOME/.config/kglobalshortcutsrc"
KWINRC="$HOME/.config/kwinrc"

# Meta alone opens KRunner
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group services --group org.kde.krunner.desktop --key "_launch" "Meta"

# Meta+Tab opens Overview (multiple windows)
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Overview" "Meta+Tab,Meta+W,Toggle Overview"

# Alt+Tab cycles through windows
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Walk Through Windows" $'\tAlt+Tab,Alt+Tab\tMeta+Tab,Walk Through Windows'

# Meta+Up / Meta+Down: restore minimized window or maximize/unmaximize (custom KWin script)
KWIN_SCRIPT_DIR="$HOME/.local/share/kwin/scripts/metaupdownrestore"
mkdir -p "$KWIN_SCRIPT_DIR/contents/code"
ln -sf "$DOTFILES_DIR/config/kwin/metaupdownrestore/metadata.json" "$KWIN_SCRIPT_DIR/metadata.json"
ln -sf "$DOTFILES_DIR/config/kwin/metaupdownrestore/contents/code/main.js" "$KWIN_SCRIPT_DIR/contents/code/main.js"

# Free up Meta+Up/Meta+Down/Meta+PgUp/Meta+PgDown from the native tiling/maximize/minimize shortcuts
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Window Quick Tile Top" "none,Meta+Up,Quick Tile Window to the Top"
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Window Quick Tile Bottom" "none,Meta+Down,Quick Tile Window to the Bottom"
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Window Maximize" "none,Meta+PgUp,Maximize Window"
kwriteconfig6 --file "$KGLOBALSHORTCUTS" --group kwin --key "Window Minimize" "none,Meta+PgDown,Minimize Window"

kwriteconfig6 --file "$KWINRC" --group Plugins --key "metaupdownrestoreEnabled" true

# Restart the compositor to apply the KWin script and shortcut changes
kwin_wayland --replace & disown

echo " --- Setup finished --- "
