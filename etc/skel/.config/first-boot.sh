#! /bin/bash

# Install some software that we don't trust 100% (Includes proprietary parts)
# These will be installed through flatpak but some software is installed because it works better as a flatpak

# Let's install all the web browsers first

echo "Let's install some web browser flatpaks"

flatpak install -y org.mozilla.firefox io.github.ungoogled_software.ungoogled_chromium org.torproject.torbrowser-launcher

echo "Now we will install the game related flatpaks"

# Now all the game related flatpaks
flatpak install -y org.prismlauncher.PrismLauncher

echo "Last the few other flatpaks"

# And now our other flatpaks
flatpak install -y org.gnome.NetworkDisplays me.amankhanna.opendeck com.obsproject.Studio io.freetubeapp.FreeTube org.squidowl.halloy im.nheko.Nheko com.github.tchx84.Flatseal

echo "We are going to install GeForceNOW"

curl -o /tmp/GeForceNOWSetup.bin "https://international.download.nvidia.com/GFNLinux/GeForceNOWSetup.bin"

echo "Please allow execution of GeForceNOWSetup.bin"

sudo chmod +x /tmp/GeForceNOWSetup.bin

echo "We will now install GeForceNOW"

/tmp/GeForceNOWSetup.bin

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

echo "Reload hyprpm then exit the script"

hyprpm reload