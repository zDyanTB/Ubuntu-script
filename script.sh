#!/usr/bin/env bash


# ----------------------------- Variables ----------------------------- #

essentialLibs="
    libgnutls30:i386
    libldap-common
    libgpg-error0:i386
    libxml2:i386
    libasound2-plugins:i386
    libsdl2-2.0-0:i386
    libfreetype6:i386
    libdbus-1-3:i386
    libsqlite3-0:i386
    libgl1-mesa-dri:i386
    mesa-vulkan-drivers
    mesa-vulkan-drivers:i386
    meson
    libsystemd-dev
    pkg-config
    ninja-build
    git
    libdbus-1-dev
    libinih-dev
    dbus-user-session
    build-essential
    libvulkan1
    libvulkan1:i386
    btrfs-progs
    curl
    wget
    jq
"

# Removed 
#   snapd
#   Lutris  - Broken

# Added
#   Scrcpy

userApps="
    scrcpy
    unrar
    unzip
    gnome-tweaks
    steam-devices
    steam
    steam:i386
"
# Removed 
#   Osu!            - sh.ppy.osu
#   Blanket         - com.rafaelmardojai.Blanket
#   Brave           - com.brave.Browser
#   GFeeds          - org.gabmus.gfeeds
#   Peek            - com.uploadedlobster.peek
#   Stremio         - com.stremio.Stremio
#   Spotify         - com.spotify.Client                    - Can be used on browser
#   Element         - im.riot.Riot
#   Grapejuice      - net.brinkervii.grapejuice             - Its broken for now, check out Vinegar
#   AppImagePool    - io.github.prateekmedia.appimagepool   - Useless
#   ProtonUp-Qt     - net.davidotek.pupgui2

# Added
#   Vinegar
#   Motrix
#   Qbittorrent
#   VSCode

flatpakApps="
    org.qbittorrent.qBittorrent
    net.agalwood.Motrix
    io.github.vinegarhq.Vinegar
    com.parsecgaming.parsec
    com.discordapp.Discord
    com.github.GradienceTeam.Gradience
    com.bitwarden.desktop
    net.ankiweb.Anki
    com.mattjakeman.ExtensionManager 
    org.mozilla.Thunderbird 
    com.usebottles.bottles  
    org.telegram.desktop 
    md.obsidian.Obsidian
    com.ticktick.TickTick
    com.visualstudio.code
"

# Setting variable to match SUDO ENV variable code inside the script
ROOT_UID=0

# Current working directory
# SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Checking ROOT and USER to set paths
if [ "$UID" -eq "$ROOT_UID" ]; then
    # Root user (SUDO)
    themesDir="/usr/share/themes"
    iconsDir="/usr/share/icons"
else
    # Normal User
    themesDir="$HOME/.local/share/themes"
    iconsDir="$HOME/.local/share/icons"
fi

# EXTENSIONS_PATH="$HOME/.local/share/gnome-shell/extensions/"
# ~/.config/gnome-shell/extensions/
# --------------------------- Pre-install ----------------------------- #

# Removing possible locks on apt
sudo rm -f /var/lib/dpkg/lock-frontend /var/cache/apt/archives/lock
# sudo rm /var/lib/dpkg/lock-frontend
# sudo rm /var/cache/apt/archives/lock

# Enable 32-bits librabies
sudo dpkg --add-architecture i386

# Install AMD MESA drivers repository

sudo add-apt-repository ppa:kisak/kisak-mesa -y

echo '[~] Adding wine repositories'

sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

sudo apt install --install-recommends winehq-stable wine-stable wine-stable-i386 wine-stable-amd64 -y

echo '[~] Updating old system'
# Error handling APT update and upgrade
sudo apt update && sudo apt upgrade -y

# Installing flatpak
sudo apt install flatpak
sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# ----------------------------- Hands on ----------------------------- #

# Essential libs
echo '[~] Installing essential libraries'
sudo apt install $essentialLibs -y

# Apt packages
echo '[~] Installing user applications'
sudo apt install $userApps -y

# Flatpak packages
echo '[~] Installing flatpak applications'
flatpak install flathub $flatpakApps -y

echo '[~] Installing Feral Gamemode'
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode || exit
git checkout 1.7 # omit to build the master branch
./bootstrap.sh

# Installing ZAP AppImage Package manager
curl -fsSL https://raw.githubusercontent.com/srevinsaju/zap/main/install.sh | sh

# ------------------------- Desktop specific configuration ------------------------- #

echo '[~] Checking Desktop enviroment'
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then

    # Gnome-specific configurations
    echo '[~] Adjusting Gnome desktop configurations'



    # Gnome Flatpak applications
    gnomeFlatpakApps="
        org.gnome.Boxes
        org.gnome.Platform/x86_64/42
    "

    # 3193  Blur my shell
    # 4679  Burn my windows
    # 4839  Clipboard history
    # 1732  GTK Title bar
    # 4630  No Titlebar when maximized
    # 750   Open Weather
    # 3843  Just perfection
    # 1852  Gamemode
    # 307   Dash-to-Dock
    gnomeExtensions="
        3193
        4679
        4839
        1732
        4630
        750
        5105
        307
        1852
        3843
    "


    sudo apt install -y gnome-extensions 
    flatpak install flathub "$gnomeFlatpakApps" -y

    echo '[~] Installing extensions'
    # Script for auto installing gnome extensions
    # https://github.com/ToasterUwU/install-gnome-extensions
    rm -f ./install-gnome-extensions.sh; wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh

    ./install-gnome-extensions.sh --enable "$gnomeExtensions"

elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    echo '[~] Adjusting KDE desktop configurations'
fi

# ---------------------------- Theme install  ---------------------------- #

# Prototype
#   Script for installing catppuccin GTK seems to be broken
#
# catppuccin-version="v0.7.0"
# curl -L https://github.com/catppuccin/gtk/releases/download/${ctp-version}/Catppuccin-Frappe-Standard-Lavender-dark.zip -o ${themesDir}/catppuccin.zip


# Tweaking theme compatible with GTK 4
mkdir -p "${HOME}/.config/gtk-4.0"
ln -sf "${themesDir}/gtk-4.0/assets" "${HOME}/.config/gtk-4.0/assets"
ln -sf "${themesDir}/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"
ln -sf "${themesDir}/gtk-4.0/gtk-dark.css" "${HOME}/.config/gtk-4.0/gtk-dark.css"

# Tweaking theme compatible with flatpak apps
sudo flatpak override --filesystem="$HOME"/.themes || echo "Flatpak theme install exit with error."

# Set theme for flatpak apps
# sudo flatpak override --env=GTK_THEME=##theme## 
#  replace ##theme## with the name of the theme you want to use and run this command:

# --------------------------- Icons --------------------------- #

# Installing McMuse-Circle Icon theme
git clone https://github.com/yeyushengfan258/McMuse-circle
cd McMuse-circle/ && ./install.sh

# ----------------------------- Pos-install ----------------------------- #

sudo apt update && sudo apt dist-upgrade -y
flatpak update -y
sudo apt autoremove -y 

echo '[~] Script finished'
echo '[~] Please Logout to apply'

echo '[~] Backup your gnome-extensions settings and then run this command'
echo "dconf load /org/gnome/shell/extensions/ < settings.dconf || dconf load / < settings.dconf"