#!/usr/bin/env bash

# Notify the user that Wi-Fi networks are being fetched
notify-send "Getting list of available Wi-Fi networks..."

# Specify the directory and theme for Rofi
dir="$HOME/.config/rofi/wifimenu"
theme='style-1'

# Get a list of available Wi-Fi connections and format it
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

# Determine Wi-Fi status for toggling
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
	toggle="睊  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
	toggle="直  Enable Wi-Fi"
fi

# Use Rofi with specified theme to select a Wi-Fi network
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " -theme "${dir}/${theme}.rasi")
chosen_id=$(echo "${chosen_network:3}" | xargs)

# Exit if no network is chosen
if [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = "直  Enable Wi-Fi" ]; then
	nmcli radio wifi on
elif [ "$chosen_network" = "睊  Disable Wi-Fi" ]; then
	nmcli radio wifi off
else
	# Message to display on successful connection
	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
	# Check if the chosen network is already saved
	saved_connections=$(nmcli -g NAME connection)
	if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
		nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
	else
		# Prompt for Wi-Fi password if the network is secured
		if [[ "$chosen_network" =~ "" ]]; then
			wifi_password=$(rofi -dmenu -p "Password: " -theme "${dir}/${theme}.rasi")
		fi
		nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
	fi
fi
