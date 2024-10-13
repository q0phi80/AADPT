#!/usr/bin/env bash

apt update -y
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install docker.io mitm6 netexec python3-pip pipx gowitness cargo rdate kali-root-login gcc clang libclang-dev libgssapi-krb5-2 libkrb5-dev libsasl2-modules-gssapi-mit musl-tools gcc-mingw-w64-x86-64 krb5-user -y -y
# DEBIAN_FRONTEND=noninteractive sudo apt install mitm6 crackmapexec bloodhound.py pipx docker-compose kali-root-login --yes --force-yes
# apt install mitm6 crackmapexec bloodhound.py pipx docker-compose kali-root-login -y

Impacket:
cd ~
# pip3 uninstall impacket -y -q #Uninstall the old version to avoid conflicts
cd /opt/
git clone https://github.com/fortra/impacket.git
# cd impacket
# python3 -m pipx install .

# Docker-compose
cd ~
curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Responder:
cd ~
cd /opt/
git clone https://github.com/lgandx/Responder.git

# PetitPotam
cd ~
cd /opt
git clone https://github.com/topotam/PetitPotam.git

# kerbrute:
cd ~
pip3 install kerbrute
cd /opt/
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64
chmod +x kerbrute_linux_amd64

# BloodHound
cd ~
cd /opt/
mkdir bh
cd bh
wget https://raw.githubusercontent.com/SpecterOps/bloodhound/main/examples/docker-compose/docker-compose.yml
# # Edit the docker-compose.yml file to make BH accessible remotely
# # change ${BLOODHOUND_HOST:-127.0.0.1}:${BLOODHOUND_PORT:-8080}:8080 to ${BLOODHOUND_HOST:-0.0.0.0}:${BLOODHOUND_PORT:-8080}:8080
# # Run BH with docker-compose up (use the randomly-generated passwor to log into BH)
# # Destory BH with docker-compose down -v
# # Access BH via https://ip:8080/

# OneRuleToRuleThemAll Rule
cd ~
cd /opt
wget https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule

# Default service accounts
cd ~
cd /opt
wget https://raw.githubusercontent.com/q0phi80/CybersecurityTools/master/service-accts.txt

# Unzip Rockyou
cd ~
gunzip -d /usr/share/wordlists/rockyou.txt.gz

# # smbclient-ng:
cd ~
python3 -m pip install smbclientng

# Certipy
cd ~
cd /opt/
git clone https://github.com/ly4k/Certipy.git
cd Certipy
python3 setup.py install

# # DonPAPI
cd ~
pipx install donpapi

# # Coercer
# cd ~
# python3 -m pip install coercer

# AD-Miner:
# cd ~
# pipx install 'git+https://github.com/Mazars-Tech/AD_Miner.git'

# Rusthound
# Need to first manually install cargo
# Step 1 install rustup: curl https://sh.rustup.rs -sSf | sh
# Step 2 source it: . "$HOME/.cargo/env"
cd ~
cd /opt/
git clone https://github.com/OPENCYBER-FR/RustHound
cd RustHound
make install

# GhostPack
cd ~
cd /opt/
git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git

#targetedKerberoast
cd ~
cd /opt/
git clone https://github.com/ShutdownRepo/targetedKerberoast.git

#noPac
cd ~
cd /opt
git clone https://github.com/Ridter/noPac.git

#PowerSharpPack
cd ~
cd /opt
git clone https://github.com/S3cur3Th1sSh1t/PowerSharpPack.git

# LDEEP
cd ~
python -m pip install git+https://github.com/franc-pentest/ldeep

# dacledit
git clone https://github.com/ThePorgs/impacket.git
cd impacket 
python3 setup.py install
pipx ensurepath

# Set Global path
# pipx ensurepath

# Disable the Network Time Protocol from auto-updating
timedatectl set-ntp off

# Make the resolv.conf file immmutable
chattr +i /etc/resolv.conf

# Create a password for the Kali root account so that we can log in with the root account
echo root:Fluffy123! | sudo chpasswd

