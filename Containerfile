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

# Install the low-level multimedia framework
RUN install-packages-build pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber

# Install hyprland desktop, wezterm terminal and ly login
RUN install-packages-build hyprland wezterm ly; systemctl enable ly.service

# Install nemo file manager and it's extensions
RUN install-packages-build nemo nemo-terminal nemo-preview nemo-pastebin nemo-image-converter nemo-fileroller nemo-emblems nemo-audio-tab ffmpegthumbnailer

# Installing dependencies for hyprpm and others
RUN install-packages-build cmake meson cpio pkg-config

# Install podman and the compose script for winapps and other tasks 
RUN install-packages-build podman podman-compose

# Install dependencies for winapps
RUN install-packages-build curl dialog freerdp git iproute2 libnotify gnu-netcat

# Install extra GUI packages that I use
RUN install-packages-build steam

# Install extra CLI packages that I use
RUN install-packages-build vim rclone fastfetch cava

# Install optional dependencies that I use
RUN install-packages-build chafa libxnvctrl bat yt-dlp

# Install all other packages that I use
RUN install-packages-build mangohud gamescope distrobox

# Install some packages that are required for the AUR packages and scripts
RUN install-packages-build glib2-devel lshw

# Some AUR packages will need to be installed through paru
RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm
    
# Compile the libadapta package with a PKGBUILD
RUN runuser -u aur -- env -C /tmp_aur_build mkdir libadapta && \
    runuser -u aur -- env -C /tmp_aur_build/libadapta curl -O 'https://raw.githubusercontent.com/proJM-Dev-team/custom-arch/refs/heads/main/pkgbuilds/libadapta/PKGBUILD' && \
    runuser -u aur -- env -C /tmp_aur_build/libadapta makepkg -sir --noconfirm
    
# Grab the sounds from the cinnamon desktop
#RUN runuser -u aur -- env -C /tmp_aur_build mkdir cinnamon-sounds && \
#    runuser -u aur -- env -C /tmp_aur_build/cinnamon-sounds curl -O 'https://raw.githubusercontent.com/proJM-Dev-team/custom-arch/refs/heads/main/pkgbuilds/cinnamon-sounds/PKGBUILD' && \
#    runuser -u aur -- env -C /tmp_aur_build/cinnamon-sounds curl -O 'https://raw.githubusercontent.com/proJM-Dev-team/custom-arch/refs/heads/main/pkgbuilds/cinnamon-sounds/cinnamon-sounds.install' && \
#    runuser -u aur -- env -C /tmp_aur_build/cinnamon-sounds makepkg -si --noconfirm

RUN rm -rf /tmp_aur_build 

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

#RUN hyprpm add https://github.com/virtcode/hypr-dynamic-cursors && \
#    hyprpm enable dynamic-cursors

RUN yes | pacman -Scc