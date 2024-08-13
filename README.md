sudo -i  

apt update & apt upgrade -y

git clone https://github.com/jbjoseph387/user_management.git /usr/scripts /usr/

cd /usr/user_management

pip install -r requirements.txt

python3 user_management.py
