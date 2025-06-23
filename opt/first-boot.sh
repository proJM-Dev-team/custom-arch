#! /bin/bash

# Install some software that we don't trust 100% (Includes proprietary parts)
# These will be installed through flatpak but some software is installed because it works better as a flatpak

# Let's install all the web browsers first

echo "Let's install some web browser flatpaks"

flatpak install -y org.mozilla.firefox io.github.ungoogled_software.ungoogled_chromium org.torproject.torbrowser-launcher

echo "Now we will install the game related flatpaks"

# Now all the game related flatpaks
flatpak install -y com.valvesoftware.Steam org.prismlauncher.PrismLauncher

echo "Last the few other flatpaks"

# And now our other flatpaks
flatpak install -y me.amankhanna.opendeck 
flatpak install -y com.obsproject.Studio
flatpak install -y io.freetubeapp.FreeTube

echo "Git clone winapps and go through part of the install"

git clone https://github.com/winapps-org/winapps.git

echo "Add the uri qemu:/// to the bashrc"

echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc

echo "Add the user to the kvm and libvirt group"

sudo usermod -a -G kvm $(id -un) # Add the user to the 'kvm' group.
sudo usermod -a -G libvirt $(id -un) # Add the user to the 'libvirt' group.

# Hyprland plugins that we can use

echo "Update hyprland before we install plugins"

hyprpm update

echo "Add all the repos with the plugins and enable the plugins"

hyprpm add https://github.com/virtcode/hypr-dynamic-cursors 
hyprpm enable dynamic-cursors 
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces 
hyprpm enable split-monitor-workspaces 
hyprpm add https://gitlab.com/magus/hyprslidr 
hyprpm enable hyprslidr

echo "Reload hyprpm then exit the script"

hyprpm reload