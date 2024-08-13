#!/bin/bash

CONFIG_FILE="users.conf"

function get_user_info() {
  username="$1"
  user_data=$(grep "^$username:" "$CONFIG_FILE")
  if [ -z "$user_data" ]; then
    echo "User not found"
    return 1
  fi
  IFS=: read -r username password start_date expiry_date total_traffic consumed_traffic <<< "$user_data"
  echo "$username:$total_traffic:$consumed_traffic:$start_date:$expiry_date"
}

function calculate_days_left() {
  expiry_date="$1"
  today=$(date +%s)
  expiry_timestamp=$(date -d "$expiry_date" +%s)
  days_left=$(( (expiry_timestamp - today) / (60 * 60 * 24) ))
  echo "$days_left"
}

function display_banner() {
  username="$1"
  total_traffic="$2"
  consumed_traffic="$3"
  start_date="$4"
  expiry_date="$5"
  days_left="$6"

  # ANSI escape codes for colors and formatting
  red='\e[31m'
  green='\e[32m'
  reset='\e[0m'
  bold='\e[1m'

  clear

  echo "${bold}${red}=========================================${reset}"
  echo "${bold}${red}| User Information |${reset}"
  echo "${bold}${red}=========================================${reset}"
  echo "Username: ${green}$username${reset}"
  echo "Total Traffic: ${green}$total_traffic MB${reset}"
  echo "Consumed Traffic: ${red}$consumed_traffic MB${reset}"
  echo "Start Date: $start_date"
  echo "Expiry Date: $expiry_date"
  echo "Days Left: $days_left"
  echo "${bold}${red}=========================================${reset}"
}

function main() {
  read -p "Enter username: " username
  user_info=$(get_user_info "$username")
  if [ $? -ne 0 ]; then
    echo "User not found"
    return 1
  fi
  IFS=: read -r username total_traffic consumed_traffic start_date expiry_date <<< "$user_info"
  days_left=$(calculate_days_left "$expiry_date")
  display_banner "$username" "$total_traffic" "$consumed_traffic" "$start_date" "$expiry_date" "$days_left"
}

main
