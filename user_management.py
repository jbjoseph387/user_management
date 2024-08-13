import os
import hashlib
import datetime

CONFIG_FILE = "users.conf"


def create_user(username, password, expiry_date, total_traffic):
    """
    Creates a new user with the provided details.

    Args:
        username (str): Username for the new user.
        password (str): Password for the new user (hashed before storage).
        expiry_date (str): Expiry date in YYYY-MM-DD format.
        total_traffic (int): Total traffic quota for the user in MB.

    Returns:
        bool: True on success, False on failure.
    """
    if os.path.exists(f"/home/{username}"):
        print(f"User '{username}' already exists.")
        return False

    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    with open(CONFIG_FILE, "a") as f:
        f.write(f"{username}:{hashed_password}:{expiry_date}:{total_traffic}:0\n")

    os.system(f"useradd -m -s /bin/bash {username}")
    os.system(f"echo {password} | passwd --stdin {username}")

    print(f"User '{username}' added successfully with expiry date {expiry_date} and total traffic {total_traffic} MB")
    return True


def delete_user(username):
    """
    Deletes the specified user.

    Args:
        username (str): Username of the user to delete.

    Returns:
        bool: True on success, False on failure.
    """
    if not os.path.exists(f"/home/{username}"):
        print(f"User '{username}' not found.")
        return False

    os.system(f"userdel {username}")

    with open(CONFIG_FILE, "r") as f:
        lines = f.readlines()

    with open(CONFIG_FILE, "w") as f:
        for line in lines:
            if not line.startswith(f"{username}:"):
                f.write(line)

    print(f"User '{username}' deleted successfully")
    return True


def modify_user(username, **kwargs):
    """
    Modifies user details (password, expiry date, total traffic).

    Args:
        username (str): Username of the user to modify.
        **kwargs: Keyword arguments for specific details to modify.
            - password (str): New password (hashed before storage).
            - expiry_date (str): New expiry date in YYYY-MM-DD format.
            - total_traffic (int): New total traffic quota in MB.
    """
    if not os.path.exists(f"/home/{username}"):
        print(f"User '{username}' not found.")
        return

    user_data = None
    with open(CONFIG_FILE, "r") as f:
        for line in f.readlines():
            if line.startswith(f"{username}:"):
                user_data = line.strip().split(":")
                break

    if not user_data:
        print(f"Failed to retrieve user data for '{username}'.")
        return

    updated_data = []
    for i, field in enumerate(user_data):
        if field in kwargs:
            updated_data.append(kwargs[field])
        else:
            updated_data.append(field)

    updated_line = f"{':'.join(updated_data)}\n"

    with open(CONFIG_FILE, "r") as f, open(f"{CONFIG_FILE}.tmp", "w") as tmp_f:
        for line in f.readlines():
            if line.startswith(f"{username}:"):
                tmp_f.write(updated_line)
            else:
                tmp_f.write(line)

    os.rename(f"{CONFIG_FILE}.tmp", CONFIG_FILE)

    if "password" in kwargs:
        os.system(f"echo {kwargs['password']} | passwd --stdin {username}")

    print(f"User '{username}' details modified successfully")


def main():
    """
    Main function for user interaction and script execution.
    """
    while True:
        print("\nUser Management Script")
        print("1. Add user")
        print("2. Delete user")
        print("3. Modify user details")
        print

