ARG CORE_BRANCH=main
ARG SUFFIX=
ARG DESKTOP=nogui

FROM ghcr.io/projm-dev-team/system-base${SUFFIX}-${DESKTOP}:main

ARG CORE_BRANCH=main
ARG VARIANT=general
ARG DESKTOP=nogui

# Changes to the base container image go here.

# IMPORTANT: Do NOT use `pacman -S` to install packages.
# Instead, use install-packages-build, as demonstrated in the following examples:

# Install the low-level multimedia framework pipewire
RUN install-packages-build pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber

# Install hyprland desktop, wezterm terminal and ly login
RUN install-packages-build hyprland wezterm ly; systemctl enable ly.service

# Install nemo file manager and it's extensions
RUN install-packages-build nemo nemo-terminal nemo-preview nemo-pastebin nemo-image-converter nemo-fileroller nemo-emblems nemo-audio-tab ffmpegthumbnailer

# Packages for theming. This includes fonts, GTK and icons 
RUN install-packages-build gruvbox-gtk-theme-git ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-extra

# If icons fail we can use the gruvbox-plus-icon-theme-git AUR package

# Packages which are hyprland utilities
RUN install-packages-build hyprshot hyprpicker swww hyprpolkitagent

# Some other utilities that hyprland will use
RUN install-packages-build playerctl brightnessctl

# Installing dependencies for hyprpm and others
RUN install-packages-build cmake meson cpio pkg-config

# Install podman and the compose script for winapps and other tasks 
RUN install-packages-build podman podman-compose

# Install dependencies for winapps
RUN install-packages-build curl dialog freerdp git iproute2 libnotify gnu-netcat

# Install extra GUI packages that I use
RUN install-packages-build steam firefox ladybird-git

# Install extra CLI packages that I use
RUN install-packages-build rclone fastfetch cava zip unzip cmus

# Install optional dependencies that I use
RUN install-packages-build chafa libxnvctrl bat yt-dlp

# Install all other packages that I use
RUN install-packages-build mangohud gamescope distrobox

# Install some packages that are required for the AUR packages and scripts
RUN install-packages-build glib2-devel lshw

# Some AUR packages will need to be installed through paru
RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_build && chown -R aur /tmp_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_build/paru-bin makepkg -si --noconfirm
    
# Compile the libadapta package with a PKGBUILD
RUN runuser -u aur -- env -C /tmp_build git clone 'https://github.com/proJM-Dev-team/custom-arch.git' && \
    runuser -u aur -- env -C /tmp_build/custom-arch/pkgbuilds/libadapta makepkg -sir --noconfirm
    
# While we still have the user and folder let's run some scripts that don't need root
RUN runuser -u aur -- env -C /tmp_build/custom-arch/scripts/color-icons git clone 'https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git' && \
    runuser -u aur -- env -C /tmp_build/custom-arch/scripts/color-icons python3 colour-icons.py

RUN rm -rf /tmp_build 

# Paru will only install 2 packages at a time 
# For debugging they are all on their own line
# Some packages will be in the chaotic AUR but I'll keep them here
# This is to make it clear it it's part of the AUR
RUN runuser -u aur -- paru -S --noconfirm downgrade; \
    runuser -u aur -- paru -S --noconfirm freetube; \
    runuser -u aur -- paru -S --noconfirm ironbar-git; \
    runuser -u aur -- paru -S --noconfirm cinnamon-sounds --assume-installed cinnamon; \
    runuser -u aur -- paru -S --noconfirm file-roller-linuxmint; \
    runuser -u aur -- paru -S --noconfirm celluloid-linuxmint; \
    runuser -u aur -- paru -S --noconfirm bulky; \
    runuser -u aur -- paru -S --noconfirm hyprshade

# Delete all things related to the aur user 
RUN userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

RUN XDG_CURRENT_DESKTOP='Hyprland'
RUN XDG_SESSION_TYPE='wayland'
RUN XDG_SESSION_DESKTOP='Hyprland'

RUN hyprpm add https://github.com/virtcode/hypr-dynamic-cursors && \
    hyprpm enable dynamic-cursors && \
    hyprpm add https://github.com/KZDKM/Hyprspace && \
    hyprpm enable Hyprspace && \
    hyprpm add https://github.com/ItsDrike/hyprland-dwindle-autogroup && \
    hyprpm enable dwindle-autogroup && \ 
    hyprpm add https://github.com/Duckonaut/split-monitor-workspaces && \
    hyprpm enable split-monitor-workspaces && \
    hyprpm add https://gitlab.com/magus/hyprslidr && \
    hyprpm enable hyprslidr

# Unsure about these plugins being used, I will need to test them 
    #hyprpm add https://github.com/hyprwm/hyprland-plugins && \
    #hyprpm enable hyprscrolling

# Install some last packages like a secondary desktop
RUN install-packages-build tde-meta

RUN yes | pacman -Scc

# Copy the configs to be created when a new user is made
COPY .config/ /etc/skel