#!/bin/bash

# Written by Hamza Zaari
# https://zaari.me/




# Foreground colors

BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

RESET="\033[0m"

# Files

WALLPAPERS=~/.\$wallpapers
RANDOW=~/.randow.sh
ENTRY=~/.config/autostart/randow.desktop
SHRC_S=~/.*shrc

# Main

get_wallpapers_folder_location () {
    while [[ ! -e "${WALLPAPER_S[0]}" ]] ; do
        echo -e "${BLUE}Enter your wallpapers folder location (e.g. /usr/share/backgrounds):${RESET}"
        read -p "  " WALLPAPERS_FOLDER_LOCATION
        WALLPAPER_S=("$WALLPAPERS_FOLDER_LOCATION"/*.jp*g)
    done
    echo
    echo $WALLPAPERS_FOLDER_LOCATION > $WALLPAPERS
    echo "Your wallpapers folder path has been saved, you can change it by typing \"randow update\""
}

set_a_random_wallpaper () {
    WALLPAPER_S=$(cat $WALLPAPERS)
    gsettings set org.gnome.desktop.background picture-options "zoom"
    if [[ ! $(ls "$WALLPAPER_S"/*.jp*g | wc -l) -eq 1 ]] ; then
        while [[ $(gsettings get org.gnome.desktop.background picture-uri) =~ $RANDOM_WALLPAPER ]] ; do
            RANDOM_WALLPAPER=$(ls "$WALLPAPER_S"/*.jp*g | shuf -n 1)
        done
        gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_WALLPAPER"
    else
        gsettings set org.gnome.desktop.background picture-uri "file://$(ls "$WALLPAPER_S"/*.jp*g)"
        echo -e "${YELLOW}Add more wallpapers to the \"$WALLPAPER_S\" folder to randomly change the desktop wallpaper${RESET}"
    fi
}

run_the_randow_script_when_moving_the_pointer_into_a_corner_of_the_screen () {
    gsettings set org.pantheon.desktop.gala.behavior hotcorner-custom-command "hotcorner-topleft:$RANDOW;;hotcorner-topright:$RANDOW;;hotcorner-bottomleft:$RANDOW;;hotcorner-bottomright:$RANDOW;;"
    echo -e "${BLUE}Available options:${RESET}"
    echo "  1) Top left corner"
    echo "  2) Top right corner"
    echo "  3) Bottom left corner"
    echo "  4) Bottom right corner"
    echo
    while [[ -z $CORNER_S ]] ; do
        echo -e "${BLUE}Change the desktop wallpaper randomly when I move the cursor into:${RESET}"
        read -p "  " SELECTED_CORNER_S
        CORNER_S=$(echo $SELECTED_CORNER_S | tr " " "\n")
    done
    echo
    for CORNER in $CORNER_S ; do
        case $CORNER in
            1)
                gsettings set org.pantheon.desktop.gala.behavior hotcorner-topleft "custom-command"
                echo "You can change the desktop wallpaper randomly by moving the pointer into the top left corner"
                ;;
            2)
                gsettings set org.pantheon.desktop.gala.behavior hotcorner-topright "custom-command"
                echo "You can change the desktop wallpaper randomly by moving the pointer into the top right corner"
                ;;
            3)
                gsettings set org.pantheon.desktop.gala.behavior hotcorner-bottomleft "custom-command"
                echo "You can change the desktop wallpaper randomly by moving the pointer into the bottom left corner"
                ;;
            4)
                gsettings set org.pantheon.desktop.gala.behavior hotcorner-bottomright "custom-command"
                echo "You can change the desktop wallpaper randomly by moving the pointer into the bottom right corner"
                ;;
            *)
                echo -e "${YELLOW}You can only enter the available option(s)${RESET}"
                echo -e "${YELLOW}You can enter multiple options, but they must be separated by a space${RESET}"
                exit 7
                ;;
        esac
    done
}

run_the_randow_script_on_startup () {
    if [[ ! -e $RANDOW ]] ; then
        cp -f $0 $RANDOW
    fi
    if [[ ! -e $ENTRY ]] ; then
        echo "[Desktop Entry]" > $ENTRY
        echo "Name[en]=Random desktop wallpaper on startup" >> $ENTRY
        echo "Comment=$RANDOW" >> $ENTRY
        echo "Exec=$RANDOW" >> $ENTRY
        echo "Icon=application-default-icon" >> $ENTRY
        echo "Type=Application" >> $ENTRY
        echo "X-GNOME-Autostart-enabled=true" >> $ENTRY
    fi
}

add_the_randow_alias_to_the_shrc_s () {
    for SHRC in $SHRC_S ; do
        if [[ ! $(grep "alias randow" $SHRC) ]] ; then
            echo "# The randow alias" >> $SHRC && echo "alias randow=$RANDOW" >> $SHRC
        fi
    done
}

print_the_help_message () {
    echo -e "${BLUE}Usage:${RESET}"
    echo -e "  ${GREEN}randow${RESET} [command]"
    echo
    echo -e "${BLUE}Available commands:${RESET}"
    echo "  update        Update wallpapers folder location"
    echo "  hotcorners    Change the desktop wallpaper randomly when moving the pointer into a corner of the screen"
    echo "  help          Print this help message"
    echo -e "  ${RED}bye           Remove the randow script${RESET}"
}

remove_the_randow_script () {
    rm -f $WALLPAPERS $RANDOW $ENTRY
    sed -i "/randow/d" $SHRC_S
    gsettings set org.pantheon.desktop.gala.behavior hotcorner-topleft "none"
    gsettings set org.pantheon.desktop.gala.behavior hotcorner-topright "none"
    gsettings set org.pantheon.desktop.gala.behavior hotcorner-bottomleft "none"
    gsettings set org.pantheon.desktop.gala.behavior hotcorner-bottomright "none"
    echo -e "${RED}Bye bye${RESET}"
}

if [[ -z $1 ]] ; then
    if [[ ! -e $WALLPAPERS ]] ; then
        get_wallpapers_folder_location
        run_the_randow_script_on_startup
        add_the_randow_alias_to_the_shrc_s
        set_a_random_wallpaper
    else
        set_a_random_wallpaper
    fi
else
    case $1 in
        update)
            get_wallpapers_folder_location
            if [[ ! -e $WALLPAPERS ]] ; then
                run_the_randow_script_on_startup
                add_the_randow_alias_to_the_shrc_s
            fi
            set_a_random_wallpaper
            ;;
        hotcorners)
            run_the_randow_script_when_moving_the_pointer_into_a_corner_of_the_screen
            ;;
        help)
            print_the_help_message
            ;;
        bye)
            remove_the_randow_script
            ;;
        *)
            print_the_help_message
            exit 7
            ;;
    esac
fi