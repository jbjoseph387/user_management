sudo -i  

apt update && apt upgrade -y

git clone https://github.com/jbjoseph387/user_management.git /usr/scripts

cd /usr/scripts/

apt install python3-pip -y

pip install -r requirements.txt

python3 user_management.py
