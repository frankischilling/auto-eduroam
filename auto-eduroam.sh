#!/bin/bash
#
# connect-eduroam.sh
#
# A script to connect to eduroam (WPA2-Enterprise) networks using nmcli.
# This script is licensed under the GNU General Public License v3.
#
# 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#

# Variables
SSID="eduroam"
USERNAME="username@uni.edu"  # Typically 'username@domain'
PASSWORD="password"
INTERFACE="wlan0"            # Your Wi-Fi device (check with 'iw dev' or 'nmcli dev status')

# Check if nmcli is installed; if not, detect distro and install
if ! command -v nmcli &>/dev/null; then
  echo "[!] nmcli not found. Attempting to install NetworkManager..."
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian)
        echo "[+] Installing NetworkManager on $ID..."
        sudo apt-get update
        sudo apt-get install -y network-manager
        ;;
      fedora|centos|rhel)
        echo "[+] Installing NetworkManager on $ID..."
        sudo dnf install -y NetworkManager
        ;;
      arch)
        echo "[+] Installing NetworkManager on $ID..."
        sudo pacman -Sy --noconfirm networkmanager
        ;;
      opensuse*|sles)
        echo "[+] Installing NetworkManager on $ID..."
        sudo zypper install -y NetworkManager
        ;;
      *)
        echo "[-] Unable to detect or unsupported distro. Please install NetworkManager manually."
        exit 1
        ;;
    esac
  else
    echo "[-] /etc/os-release not found. Please install NetworkManager manually."
    exit 1
  fi
fi

echo "[+] Scanning for Wi-Fi networks..."
nmcli dev wifi rescan
sleep 2  # Wait for scan results

# Verify that eduroam is in range
if ! nmcli dev wifi list | grep -w "$SSID" >/dev/null 2>&1; then
  echo "[-] SSID '$SSID' not found in scan results."
  exit 1
fi
echo "[+] '$SSID' is in range!"

# If an old profile named "eduroam" exists, remove it first
if nmcli -f name,type connection show | grep -q "^$SSID\s.*wifi"; then
  echo "[+] Removing old '$SSID' connection profile."
  nmcli connection delete "$SSID"
fi

# Create a new eduroam connection profile with WPA-EAP (PEAP + MSCHAPv2)
echo "[+] Creating a new '$SSID' connection profile..."
nmcli connection add \
  type wifi \
  con-name "$SSID" \
  ifname "$INTERFACE" \
  ssid "$SSID" \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap peap \
  802-1x.identity "$USERNAME" \
  802-1x.password "$PASSWORD" \
  802-1x.phase2-auth mschapv2 
  # 802-1x.anonymous-identity "anonymous@university.edu"
  # 802-1x.altsubject-matches "DNS:radius.youruniversity.edu"
  # 802-1x.domain-suffix-match "youruniversity.edu"
  # If needed, skip CA validation (less secure):
  # 802-1x.system-ca-certs no

# Optional: ensure password is stored (not prompted), by disabling 'secret flags'
nmcli connection modify "$SSID" 802-1x.password-flags 0

# Bring up the new connection
echo "[+] Bringing up connection '$SSID'..."
nmcli connection up "$SSID"
if [[ $? -eq 0 ]]; then
  echo "[+] Successfully connected to '$SSID'!"
else
  echo "[-] Failed to connect to '$SSID'."
  exit 1
fi
