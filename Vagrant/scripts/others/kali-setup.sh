#!/usr/bin/env bash

apt update -y
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install nbtscan net-tools wireshark gowitness impacket-scripts hashcat proxychains4 sprayhound freerdp2-x11 powershell-lts docker.io mitm6 netexec python3-pip pipx gowitness cargo rdate kali-root-login gcc clang libclang-dev libgssapi-krb5-2 libkrb5-dev libsasl2-modules-gssapi-mit musl-tools gcc-mingw-w64-x86-64 krb5-user python3-certipy coercer -y
apt update -y
DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Impacket:
cd ~
cd /opt/
git clone https://github.com/fortra/impacket.git

# Docker-compose
cd ~
curl -SL https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Responder:
cd ~
cd /opt/
git clone https://github.com/lgandx/Responder.git

# PetitPotam
cd ~
cd /opt/
git clone https://github.com/topotam/PetitPotam.git

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
cd /opt/
wget https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule

# Default service accounts
cd ~
cd /opt/
wget https://raw.githubusercontent.com/q0phi80/CybersecurityTools/master/service-accts.txt

# Download Rockyou
cd ~
cd /opt/
wget https://github.com/praetorian-inc/Hob0Rules/raw/refs/heads/master/wordlists/rockyou.txt.gz
gunzip -d rockyou.txt.gz

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
cd /opt/
git clone https://github.com/Ridter/noPac.git

#PowerSharpPack
cd ~
cd /opt/
git clone https://github.com/S3cur3Th1sSh1t/PowerSharpPack.git

# dacledit
cd ~
cd /opt/
git clone https://github.com/ThePorgs/impacket.git
cd impacket 
python3 setup.py install

# pipx installs
cd ~
pipx install kerbrute bloodhound-ce ldeep smbclientng donpapi

# Disable the Network Time Protocol from auto-updating
timedatectl set-ntp off
