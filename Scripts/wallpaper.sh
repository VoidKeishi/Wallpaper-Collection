#!/usr/bin/env bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

# Set some variables
script_dir=$(dirname "$(realpath "$0")")
rasi_file="$script_dir/wallpaper.rasi"
wall_dir="$HOME/Pictures/Wallpapers"
cacheDir="$HOME/.cache/$USER/cache"
config_file="$HOME/.config/hypr/wallpaper.conf"
# Create cache dir if not exists
mkdir -p "${cacheDir}"

monitor_res=$(($(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f1) * 14 / $(xdpyinfo | awk '/resolution/{print $2}' | cut -d 'x' -f1)))

# Check if monitor_res is empty or zero
if [ -z "$monitor_res" ] || [ "$monitor_res" -eq 0 ]; then
    echo "Failed to calculate monitor resolution. Using default value."
    monitor_res=14
fi

rofi_override="element-icon{size:${monitor_res}px;}"
rofi_command="rofi -dmenu -theme $rasi_file -theme-str $rofi_override"

# Convert images in directory and save to cache dir
for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
    [ -f "$imagen" ] || continue
    nombre_archivo=$(basename "$imagen")
    cache_file="${cacheDir}/${nombre_archivo}"
    md5_file="${cacheDir}/.${nombre_archivo}.md5"

    current_md5=$(md5sum "$imagen" | cut -d' ' -f1)

    if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file")" ]; then
        magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
        echo "$current_md5" > "$md5_file"
    fi
done

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do  echo -en "$A\x00icon\x1f""${cacheDir}"/"$A\n" ; done | $rofi_command)

# Set wallpaper
[[ -n "$wall_selection" ]] && swaybg -i $wall_dir/$wall_selection -m fill &
echo "wallpaper=$wall_dir/$wall_selection" > "$config_file"
