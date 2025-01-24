#!/bin/bash
# Connect to eduroam (WPA2-Enterprise) with nmcli by creating a proper connection profile.

SSID="eduroam"
USERNAME="username@uni.edu"  # Typically 'username@domain'
PASSWORD="password"
INTERFACE="wlan0"  # Your Wi-Fi device (check with 'iw dev')

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
  802-1x.phase2-auth mschapv2 \
  # 802-1x.anonymous-identity "anonymous@university.edu" \
  # 802-1x.altsubject-matches "DNS:radius.youruniversity.edu" \
  # 802-1x.domain-suffix-match "youruniversity.edu" \
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
