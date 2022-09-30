#!/usr/bin/env bash
# ----------------------------- Variables ----------------------------- #
essential="libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 lutris libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev dbus-user-session build-essential libvulkan1 libvulkan1:i386
"

userApps="
    unrar
    unzip
    gnome-tweaks
    btrfs-progs
    steam-installer
    steam-devices
    steam:i386
    snapd
"

flatpakApps="
    net.ankiweb.Anki
    com.mattjakeman.ExtensionManager 
    org.mozilla.Thunderbird 
    com.uploadedlobster.peek 
    com.usebottles.bottles 
    net.davidotek.pupgui2 
    com.rafaelmardojai.Blanket 
    org.gabmus.gfeeds 
    sh.ppy.osu 
    org.telegram.desktop 
    com.stremio.Stremio 
    com.spotify.Client 
    io.github.prateekmedia.appimagepool
    md.obsidian.Obsidian
    com.ticktick.TickTick
    flathub im.riot.Riot
    net.brinkervii.grapejuice
"

# --------------------------- Pre-install ----------------------------- #
# Removing possible locks on apt
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

# Enable 32-bits librabies
sudo dpkg --add-architecture i386

# Install AMD MESA drivers
sudo add-apt-repository ppa:kisak/kisak-mesa -y

echo '[~] Adding new system repositories'

wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' -y
sudo add-apt-repository ppa:lutris-team/lutris -y
sudo apt update
sudo apt-get install --install-recommends winehq-staging winehq-stable wine-stable wine-stable-i386 wine-stable-amd64 -y

echo '[~] Updating old system'
sudo apt update && sudo apt upgrade -y
# ----------------------------- Hands on ----------------------------- #

# Essential libs #
sudo apt install $essential -y

# Some essential applications #
sudo apt install $userApps -y

# Flatpak packages install #
flatpak install flathub $flatpakApps -y

echo '[~] Installing user applications'
# Some user applications #
sudo apt install parsec steam motrix discord qbittorrent visual-studio-code -y

# Desktop specifit configuration #
echo '[~] Checking Desktop enviroment'
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then

    # Gnome variables #
    echo '[~] Installing Gnome desktop configurations'.
    themes="/usr/share/themes"
    icons="/usr/share/icons"

    # Gnome flatpak applications #
    gnome_flatpak="
    org.gnome.Boxes
    org.gnome.Platform/x86_64/42
    "
    
    flatpak install flathub $gnome_flatpak -y
    
elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    echo Using KDE
fi

# Snapd apps # 
snap install scrcpy

echo '[~] Installing Feral Gamemode'

# Installing Feral Gamemode #
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode
git checkout 1.7 # omit to build the master branch
./bootstrap.sh

# Installing ZAP AppImage Package manager #
curl -fsSL curl https://raw.githubusercontent.com/srevinsaju/zap/main/install.sh | sh
# ----------------------------- Pos-install ----------------------------- #

sudo apt update && sudo apt dist-upgrade -y
flatpak update

echo '[~] Script finished'
# ---------------------------------------------------------------------- #