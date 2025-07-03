ARG CORE_BRANCH=main
ARG SUFFIX=
ARG DESKTOP=nogui

FROM ghcr.io/projm-dev-team/system-base${SUFFIX}-${DESKTOP}:main

ARG VARIANT=general
#ARG CORE_BRANCH=main
#ARG DESKTOP=nogui

# Changes to the base container image go here.

# IMPORTANT: Do NOT use `pacman -S` to install packages.
# Instead, use install-packages-build, as demonstrated in the following examples:

# Install the low-level multimedia framework pipewire
RUN install-packages-build pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber

# Install zsh with some packages that extend the functionality 
RUN install-packages-build zsh zsh-autocomplete zsh-completions zsh-autosuggestions zsh-syntax-highlighting

# Install hyprland desktop, terminals and ly login
RUN install-packages-build hyprland wezterm kitty ly; systemctl enable ly.service

# Install nemo file manager and its extensions
RUN install-packages-build nemo nemo-terminal nemo-preview nemo-image-converter nemo-emblems nemo-audio-tab ffmpegthumbnailer

# Install related theme packages
# If icons fail we can use the gruvbox-plus-icon-theme-git AUR package
RUN install-packages-build ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-extra kvantum nwg-look

# Packages and utilities that hyprland/hyprpm will use
RUN install-packages-build hyprpicker swww polkit-gnome playerctl brightnessctl satty dunst grim cmake meson cpio pkg-config

# Install dependencies for winapps
RUN install-packages-build dialog freerdp git libnotify gnu-netcat dnsmasq qemu-full virt-manager; systemctl enable libvirtd.socket

# Install extra CLI and GUI packages that I use
RUN install-packages-build steam ladybird-git mintstick rclone fastfetch zip unzip cmus btop mpd cava

# Install optional dependencies that I use along with other sandboxing/containerization software
RUN install-packages-build podman podman-compose distrobox flatpak chafa libxnvctrl bat yt-dlp

# Install all other packages that I use
RUN install-packages-build mangohud gamescope tailscale fwupd; systemctl enable fwupd.service

# Install some packages that are required for the AUR packages and scripts
RUN install-packages-build glib2-devel lshw python-pip

# Some AUR packages will need to be installed through paru
RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_build && chown -R aur /tmp_build && \
    install-packages-build git base-devel; \
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
RUN runuser -u aur -- paru -S --noconfirm --removemake libadwaita-without-adwaita-git; \
    runuser -u aur -- paru -S --noconfirm --removemake bulky; \
    runuser -u aur -- paru -S --noconfirm --removemake cinnamon-sounds --assume-installed cinnamon; \
    runuser -u aur -- paru -S --noconfirm --removemake file-roller-linuxmint; \
    runuser -u aur -- paru -S --noconfirm --removemake celluloid-linuxmint; \
    runuser -u aur -- paru -S --noconfirm --removemake cake-wallet-bin; \
    runuser -u aur -- paru -S --noconfirm --removemake gruvbox-gtk-theme-git


# Installing all hyprland related packages 
# Then remove packages that are not used anymore
RUN runuser -u aur -- paru -S --noconfirm --removemake eww; \
    runuser -u aur -- paru -S --noconfirm --removemake walker-bin; \
    runuser -u aur -- paru -S --noconfirm --removemake pyprland; \
    runuser -u aur -- paru -S --noconfirm --removemake hyprfreeze; \
    runuser -u aur -- paru -S --noconfirm --removemake hyprnotify; \
    runuser -u aur -- paru -S --noconfirm --removemake hyprshade; \
    runuser -u aur -- paru -S --noconfirm --removemake syshud

# Delete all things related to the aur user 
RUN userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur /tmp_build;

# Install some last packages like a secondary desktop and clean package cache
RUN install-packages-build tde-tdebase xorg-xrandr && pacman --noconfirm -Scc

# Copy some scripts opt and the user config
COPY opt/ /opt/

# Copy the system configs to etc
COPY etc/ /etc/

# Link the user configs to be created when a new user is made
RUN ln -s /opt/config/dunst /etc/skel/.config/dunst \
    ln -s /opt/config/eww /etc/skel/.config/eww && \
    ln -s /opt/config/Kvantum /etc/skel/.config/Kvantum && \
    ln -s /opt/config/wallpapers /etc/skel/.config/wallpapers && \
    ln -s /opt/config/wezterm /etc/skel/.config/wezterm && \
# Since we allow a custom config as part of hyprland we link each file
    ln -s /opt/config/hypr/decor.conf /etc/skel/.config/hypr/decor.conf && \
    ln -s /opt/config/hypr/envs.conf /etc/skel/.config/hypr/envs.conf && \
    ln -s /opt/config/hypr/execs.conf /etc/skel/.config/hypr/execs.conf && \
    ln -s /opt/config/hypr/hyprland.conf /etc/skel/.config/hypr/hyprland.conf && \
    ln -s /opt/config/hypr/inputs.conf /etc/skel/.config/hypr/inputs.conf && \
    ln -s /opt/config/hypr/pyprland.toml /etc/skel/.config/hypr/pyprland.toml
