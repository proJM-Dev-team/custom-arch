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

# Install zsh with some packages that extend the functionality 
RUN install-packages-build zsh zsh-autocomplete zsh-completions zsh-autosuggestions zsh-syntax-highlighting

# Install hyprland desktop, wezterm terminal and ly login
RUN install-packages-build hyprland wezterm kitty ly; systemctl enable ly.service

# Install nemo file manager and its extensions
RUN install-packages-build nemo nemo-terminal nemo-preview nemo-image-converter nemo-emblems nemo-audio-tab ffmpegthumbnailer

# Install related theme packages
RUN install-packages-build ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-extra kvantum nwg-look

# If icons fail we can use the gruvbox-plus-icon-theme-git AUR package

# Packages which are hyprland utilities
RUN install-packages-build hyprpicker swww hyprpolkitagent

# Some other utilities that hyprland will use
RUN install-packages-build playerctl brightnessctl satty

# Installing dependencies for hyprpm and others
RUN install-packages-build cmake meson cpio pkg-config

# Install podman and the compose script for winapps and other tasks, also flatpak for untrusted software
RUN install-packages-build podman podman-compose flatpak

# Install dependencies for winapps
RUN install-packages-build curl dialog freerdp git iproute2 libnotify gnu-netcat

# Install some software that we don't trust 100% (Includes proprietary parts)
# These will be installed through flatpak but some software is installed because it works better as a flatpak

# Let's install all the web browsers first
RUN flatpak install -y org.mozilla.firefox io.github.ungoogled_software.ungoogled_chromium org.torproject.torbrowser-launcher

# Now all the game related flatpaks
RUN flatpak install -y com.valvesoftware.Steam org.prismlauncher.PrismLauncher

# And now our other flatpaks
RUN flatpak install -y me.amankhanna.opendeck 
RUN flatpak install -y com.obsproject.Studio
RUN flatpak install -y io.freetubeapp.FreeTube

# Install extra GUI packages that I use
RUN install-packages-build ladybird-git

# Install extra CLI packages that I use
RUN install-packages-build rclone fastfetch zip unzip cmus btop mpd cava 

# Install optional dependencies that I use
RUN install-packages-build chafa libxnvctrl bat yt-dlp

# Install all other packages that I use
RUN install-packages-build mangohud gamescope distrobox

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
COPY pkgbuilds/ /tmp_build/pkgbuilds/
RUN chown -R aur:aur /tmp_build/pkgbuilds/
    
# Compile the libadapta package with a PKGBUILD
#RUN runuser -u aur -- env -C /tmp_build/pkgbuilds/libadapta makepkg -sir --noconfirm
    
RUN runuser -u aur -- env -C /tmp_build mkdir scripts
COPY scripts/ /tmp_build/scripts/
RUN chown -R aur:aur /tmp_build/scripts/

# While we still have the user and folder let's run some scripts that don't need root
RUN runuser -u aur -- env -C /tmp_build/scripts/colour-icons git clone 'https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git' && \
    runuser -u aur -- env -C /tmp_build/scripts/colour-icons pip install --user --break-system-packages basic_colormath && \
    chown -R aur:aur /usr/share/icons && \
    runuser -u aur -- env -C /tmp_build/scripts/colour-icons python colour-icons.py

RUN rm -rf /tmp_build 

# Paru will only install 2 packages at a time 
# For debugging they are all on their own line
# Some packages will be in the chaotic AUR but I'll keep them here
# This is to make it clear it it's part of the AUR
RUN runuser -u aur -- paru -S --noconfirm downgrade; \
    runuser -u aur -- paru -S --noconfirm popsicle; \
    runuser -u aur -- paru -S --noconfirm halloy-bin; \
    runuser -u aur -- paru -S --noconfirm cinnamon-sounds --assume-installed cinnamon; \
    runuser -u aur -- paru -S --noconfirm file-roller-linuxmint; \
    runuser -u aur -- paru -S --noconfirm celluloid-linuxmint; \
    runuser -u aur -- paru -S --noconfirm bulky; \
    runuser -u aur -- paru -S --noconfirm gruvbox-gtk-theme-git


# Installing all hyprland related packages
RUN runuser -u aur -- paru -S --noconfirm eww; \
    runuser -u aur -- paru -S --noconfirm walker-bin; \
    runuser -u aur -- paru -S --noconfirm pscircle; \
    runuser -u aur -- paru -S --noconfirm pyprland; \
    runuser -u aur -- paru -S --noconfirm hyprfreeze; \
    runuser -u aur -- paru -S --noconfirm hyprnotify; \
    runuser -u aur -- paru -S --noconfirm hyprshade; \
    runuser -u aur -- paru -S --noconfirm syshud

#RUN runuser -u aur -- export XDG_CURRENT_DESKTOP='Hyprland'
#RUN runuser -u aur -- export XDG_SESSION_TYPE='wayland'
#RUN runuser -u aur -- export XDG_SESSION_DESKTOP='Hyprland'

#RUN runuser -u aur -- hyprpm add https://github.com/virtcode/hypr-dynamic-cursors && \
#    runuser -u aur -- hyprpm enable dynamic-cursors && \
#    runuser -u aur -- hyprpm add https://github.com/KZDKM/Hyprspace && \
#    runuser -u aur -- hyprpm enable Hyprspace && \
#    runuser -u aur -- hyprpm add https://github.com/ItsDrike/hyprland-dwindle-autogroup && \
#    runuser -u aur -- hyprpm enable dwindle-autogroup && \ 
#    runuser -u aur -- hyprpm add https://github.com/Duckonaut/split-monitor-workspaces && \
#    runuser -u aur -- hyprpm enable split-monitor-workspaces && \
#    runuser -u aur -- hyprpm add https://gitlab.com/magus/hyprslidr && \
#    runuser -u aur -- hyprpm enable hyprslidr

# Unsure about these plugins being used, I will need to test them 
    #runuser -u aur -- hyprpm add https://github.com/hyprwm/hyprland-plugins && \
    #runuser -u aur -- hyprpm enable hyprscrolling

# Delete all things related to the aur user 
RUN userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

# Install some last packages like a secondary desktop
RUN install-packages-build tde-tdebase

RUN yes | pacman -Scc

# Copy the user configs to be created when a new user is made
RUN mkdir /etc/skel/.config/
COPY .config/ /etc/skel/.config/

# Copy GTK theme to /usr/share/themes
COPY .themes/Gruvbox-Dark-Custom/ /usr/share/themes/

# Copy the system configs to etc
COPY etc/ /etc/