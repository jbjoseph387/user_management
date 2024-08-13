#!/bin/bash

CONFIG_FILE="users.conf"

function get_consumed_traffic() {
  username="$1"
  # Replace this with actual logic to retrieve consumed traffic
  consumed_traffic=$(traffic_tool -u "$username")
  echo "$consumed_traffic" || echo "Error: Failed to get consumed traffic for $username"
}

function update_consumed_traffic() {
  username="$1"
  consumed_traffic=$(get_consumed_traffic "$username")

  if [ $? -eq 0 ]; then
    sed -i "s/\($username:[^:]*\):\([0-9]*\)/\1:$consumed_traffic/" "$CONFIG_FILE" || echo "Error: Failed to update consumed traffic for $username"
  fi
}

function add_user() {
  read -p "Enter username: " username
  read -p "Enter password: " password
  read -p "Enter expiry date (YYYY-MM-DD): " expiry_date
  read -p "Enter total traffic (MB): " total_traffic

  if id "$username" &> /dev/null; then
    echo "User $username already exists."
    return 1
  fi

  useradd -m -s /bin/bash "$username" || echo "Error: Failed to create user $username"
  echo "$password" | passwd --stdin "$username" || echo "Error: Failed to set password for $username"
  echo "$username:$password:$expiry_date:$total_traffic:0" >> "$CONFIG_FILE" || echo "Error: Failed to add user to config file"
  echo "User $username added successfully with expiry date $expiry_date and total traffic $total_traffic MB"
}

function delete_user() {
  read -p "Enter username to delete: " username
  userdel "$username" || echo "Error: Failed to delete user $username"
  sed -i "/^$username:/d" "$CONFIG_FILE" || echo "Error: Failed to remove user from config file"
  echo "User $username deleted successfully"
}

function modify_user() {
  read -p "Enter username to modify: " username
  # Implement logic for modifying user details (e.g., password, expiry date, traffic)
  echo "Modifying user details is not implemented yet."
}

function check_traffic() {
  read -p "Enter username to check traffic: " username
  consumed_traffic=$(get_consumed_traffic "$username")
  total_traffic=$(grep "^$username:" "$CONFIG_FILE" | cut -d: -f4)

  echo "Username: $username"
  echo "Consumed traffic: $consumed_traffic MB"
  echo "Total traffic: $total_traffic MB"

  if [ "$consumed_traffic" -ge "$total_traffic" ]; then
    echo "User has reached traffic limit."
  fi
  update_consumed_traffic "$username"
}

function main_menu() {
  clear
  echo "User Management Script"
  echo "1. Add user"
  echo "2. Delete user"
  echo "3. Modify user details"
  echo "4. Check traffic"
  echo "5. Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1) add_user ;;
    2) delete_user ;;
    3) modify_user ;;
    4) check_traffic ;;
    5) exit 0 ;;
    *) echo "Invalid choice" ;;
  esac
}

while true; do
  main_menu
done
