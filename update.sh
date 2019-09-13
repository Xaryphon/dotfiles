#!/bin/bash
###############
## update.sh ##
###############

# host
# theme
# user

base_dir=~/.uconfig
theme_dir=$base_dir/themes
default_theme_dir=$theme_dir/default
current_theme_dir=$theme_dir/current
user_dir=$base_dir/user
host_dir=$base_dir/host/$(hostname)

function update_config {
    # $1 to
    # $... from
    config="$1"
    cfgprtnm="$2"

    # themes/current/ (doesn't have to exist)
    # > themes/default/ (doesn't have to exist)
    # user/.../ (has to exist, writes a warning if it doesn't)
    # host/.../ (doesn't have to exist)

    host_file_exists=n
    host_file=
    if [[ -f "$host_dir/$cfgprtnm" ]]; then
        host_file_exists=y
        host_file="$host_dir/$cfgprtnm"
    fi

    user_file_exists=n
    user_file=
    if [[ -f "$user_dir/$cfgprtnm" ]]; then
        user_file_exists=y
        user_file="$user_dir/$cfgprtnm"
    fi

    theme_file_exists=n
    theme_file=
    if [[ -f "$current_theme_dir/$cfgprtnm" ]]; then
        theme_file_exists=y
        theme_file="$current_theme_dir/$cfgprtnm"
    elif [[ -f "$default_theme_dir/$cfgprtnm" ]]; then
        theme_file_exists=y
        theme_file="$default_theme_dir/$cfgprtnm"
    fi

    anyfile_exists=n
    if [[ $host_file_exists == y ]]; then
        anyfile_exists=y
    elif [[ $user_file_exists == y ]]; then
        anyfile_exists=y
    elif [[ $theme_file_exists == y ]]; then
        anyfile_exists=y
    fi

    if [[ $anyfile_exists == n ]]; then
        if [[ -f "$config" ]]; then
            echo -n > "$config"
        fi
    else
        echo -n > "$config"
        if [[ $theme_file_exists == y ]]; then
            cat "$theme_file" >> "$config"
            printf "\n" >> "$config"
        fi
        if [[ $user_file_exists == y ]]; then
            cat "$user_file" >> "$config"
            printf "\n" >> "$config"
        fi
        if [[ $host_file_exists == y ]]; then
            cat "$host_file" >> "$config"
            printf "\n" >> "$config"
        fi
    fi
}

function update_configs {
    echo Updating configs...
    update_config ~/.config/i3/config i3config
    install -m755 $base_dir/scripts/autoclicker.sh ~/.config/i3/autoclicker.sh
    update_config ~/.config/i3blocks/config i3blocks.conf
    update_config ~/.config/i3blocks/config2 i3blocks2.conf
    install -m755 $base_dir/scripts/i3blocks_systemctl_status.sh ~/.config/i3blocks/systemctl_status.sh
    install -m755 $base_dir/scripts/i3blocks_public_ip.sh ~/.config/i3blocks/public_ip.sh
    install -m755 $base_dir/scripts/i3blocks_mediaplayer.sh ~/.config/i3blocks/mediaplayer.sh
    install -m755 $base_dir/scripts/i3blocks_mediaplayer_volume.sh ~/.config/i3blocks/mediaplayer_volume.sh
    install -m755 $base_dir/scripts/i3blocks_pulseaudio_sink_volume.sh ~/.config/i3blocks/pulseaudio_sink_volume.sh
    install -m755 $base_dir/scripts/i3blocks_pulseaudio_remap_sink_volume.sh ~/.config/i3blocks/pulseaudio_remap_sink_volume.sh
    update_config ~/.gtkrc-2.0 gtk2
    update_config ~/.config/gtk-3.0/settings.ini gtk3.ini
    update_config ~/.zshrc zsh
    update_config ~/.config/neofetch/config.conf neofetch
    update_config ~/.lock lock.sh
    update_config ~/.config/lxterminal/lxterminal.conf lxterminal.conf
    update_config ~/.config/dunst/dunstrc dunst
    update_config ~/.vimrc vim
    update_config ~/.config/konsolerc konsolerc
    update_config ~/.local/share/konsole/Linux.colorscheme konsole/Linux.colorscheme
    update_config "$HOME/.local/share/konsole/Profile 1.profile" "konsole/Profile 1.profile"
    update_config ~/.tmux.conf tmux.conf
    update_config ~/.config/compton.conf compton.conf

    echo Making scripts executable...
    chmod +x ~/.config/i3blocks/systemctl_status.sh
    chmod +x ~/.config/i3blocks/public_ip.sh
    chmod +x ~/.lock

    echo Restarting i3...
    i3-msg restart

    echo Restarting compton...
    pkill -SIGUSR1 compton

    echo Restarting dunst...
    pkill dunst

    #echo Setting wallpaper...
    #$base_dir/set_wallpaper.sh
}

update_configs
