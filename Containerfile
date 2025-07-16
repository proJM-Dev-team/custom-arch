ARG CORE_BRANCH=main
ARG SUFFIX=
ARG DESKTOP=nogui

FROM ghcr.io/projm-dev-team/system-base${SUFFIX}-${DESKTOP}:main

ARG VARIANT=general

# IMPORTANT: Do NOT use `pacman -S` to install packages.
# Instead, use install-packages-build, as demonstrated in the following examples:

# Install the low-level multimedia framework pipewire
RUN install-packages-build pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber && \

# Install zsh with some packages that extend the functionality  
install-packages-build zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions zoxide fzf && \

# Install some required/optional dependencies for other packages
install-packages-build chafa libxnvctrl bat yt-dlp glib2-devel lshw python-pip && \

# Install hyprland desktop, terminals and ly login
install-packages-build hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk kitty ly && \

# Install nemo file manager and its extensions
install-packages-build nemo nemo-terminal nemo-image-converter nemo-emblems nemo-audio-tab ffmpegthumbnailer && \

# Install related theme packages
# If icons fail we can use the gruvbox-plus-icon-theme-git AUR package
install-packages-build ttf-jetbrains-mono-nerd noto-fonts-emoji kvantum kvantum-qt5 qt5ct qt6ct qt5-wayland qt6-wayland nwg-look libadwaita-without-adwaita-git && \

# Packages and utilities that hyprland/hyprpm will use
install-packages-build hyprpicker swww polkit-gnome rofi-wayland playerctl brightnessctl satty dunst grim cmake meson cpio pkg-config && \

# Install sandboxing/containerization software
install-packages-build podman podman-compose distrobox flatpak qemu-desktop virt-manager && \

# Install extra CLI and GUI packages that I use
install-packages-build steam ladybird-git mintstick rclone fastfetch zip unzip cmus btop mpd cava && \

# Install all other packages that I use
install-packages-build mangohud tailscale fwupd

# Enable all the services/sockets which are required
RUN systemctl enable ly.service fwupd.service libvirtd.socket

# Some AUR packages will need to be installed through paru
RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_build && chown -R aur /tmp_build && \
    install-packages-build base-devel; \
    runuser -u aur -- env -C /tmp_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_build/paru-bin makepkg -si --noconfirm

RUN runuser -u aur -- env -C /tmp_build mkdir pkgbuilds
COPY --chown=1000:1000 /tmp_build/pkgbuilds/ /tmp_build/pkgbuilds/
    
# Compile the libadapta package with a PKGBUILD
#RUN runuser -u aur -- env -C /tmp_build/pkgbuilds/libadapta makepkg -sir --noconfirm
    
RUN runuser -u aur -- env -C /tmp_build mkdir scripts
COPY --chown=1000:1000 /tmp_build/scripts/ /tmp_build/scripts/

# While we still have the user and folder let's run some scripts that don't need root
RUN runuser -u aur -- env -C /tmp_build/scripts/colour-icons git clone 'https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git' && \
    runuser -u aur -- env -C /tmp_build/scripts/colour-icons pip install --user --break-system-packages basic_colormath && \
    chown -R aur:aur /usr/share/icons && \
    runuser -u aur -- env -C /tmp_build/scripts/colour-icons python colour-icons.py

# Paru will only install 2 packages at a time 
# For debugging they are all on their own line
# Some packages will be in the chaotic AUR but I'll keep them here
# This is to make it clear it it's part of the AUR
RUN runuser -u aur -- paru -S --noconfirm --removemake bulky; \
    runuser -u aur -- paru -S --noconfirm --removemake cinnamon-sounds --assume-installed cinnamon; \
    runuser -u aur -- paru -S --noconfirm --removemake file-roller-linuxmint; \
    runuser -u aur -- paru -S --noconfirm --removemake celluloid-linuxmint; \
    runuser -u aur -- paru -S --noconfirm --removemake cake-wallet-bin; \
    runuser -u aur -- paru -S --noconfirm --removemake gruvbox-gtk-theme-git; \
    runuser -u aur -- paru -S --noconfirm --removemake fzf-tab-git; \
    runuser -u aur -- paru -S --noconfirm --removemake oh-my-posh-bin


# Installing all hyprland related packages 
RUN runuser -u aur -- paru -S --noconfirm --removemake eww; \
    runuser -u aur -- paru -S --noconfirm --removemake pyprland; \
    runuser -u aur -- paru -S --noconfirm --removemake hyprshade; \
    runuser -u aur -- paru -S --noconfirm --removemake syshud

# Delete all things related to the aur user 
RUN userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur /tmp_build;

# Install some last packages like a secondary desktop and clean package cache
RUN install-packages-build tde-tdebase; \
    yes | pacman -Scc

# Copy the system configs to etc
COPY etc/ /etc/