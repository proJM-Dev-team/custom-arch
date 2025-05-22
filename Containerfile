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

# Install Hyprland desktop and Wezterm terminal
RUN install-packages-build hyprland wezterm

# Install podman and the compose script for winapps and other tasks 
RUN install-packages-build podman podman-compose

# Installing dependencies for winapps
RUN install-packages-build curl dialog freerdp git iproute2 libnotify gnu-netcat

RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
    rm -rf /tmp_aur_build && \
    runuser -u aur -- paru -S --noconfirm libadapta downgrade freetube-bin; \
    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

COPY overlays/common overlay[s]/${DESKTOP} /
RUN rm -f /.gitkeep
RUN yes | pacman -Scc
