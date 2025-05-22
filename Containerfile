ARG CORE_BRANCH=main
ARG SUFFIX=
ARG DESKTOP=nogui

FROM ghcr.io/commonarch/system-base${SUFFIX}-${DESKTOP}:main

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

# Install podman and the compose script for winapps and other tasks 
RUN install-packages-build podman podman-compose

# Install dependencies for winapps
RUN install-packages-build curl dialog freerdp git iproute2 libnotify gnu-netcat

# Install extra GUI packages that I use
#RUN install-packages-build celluloid

# Install extra CLI packages that I use
RUN install-packages-build rclone fastfetch cava

# Install all other packages that I use
RUN install-packages-build mangohud gamescope

# Some AUR packages will need to be installed through paru
RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
    rm -rf /tmp_aur_build && \
    runuser -u aur -- paru -S --noconfirm downgrade; \
    runuser -u aur -- paru -S --noconfirm libadapta-git; \
    runuser -u aur -- paru -S --noconfirm freetube-bin; \
    runuser -u aur -- paru -S --noconfirm ironbar-git; \
    runuser -u aur -- paru -S --noconfirm hyprshade; \
    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

# Installing dependencies for hyprpm
RUN install-packages-build cmake meson cpio pkg-config

#RUN hyprpm add https://github.com/virtcode/hypr-dynamic-cursors && \
#    hyprpm enable dynamic-cursors

COPY overlays/common overlay[s]/${DESKTOP} /
RUN rm -f /.gitkeep
RUN yes | pacman -Scc
