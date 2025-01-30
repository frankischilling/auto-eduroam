> **Note:** This document is intended as a README for GitHub. The script described below is released under the [GNU General Public License v3.0 (GPLv3)](#license) and helps you connect to eduroam or other WPA2-Enterprise networks on Linux using **nmcli**.

---

## Overview

This script connects your Linux machine to your university’s Wi-Fi (eduroam) which typically uses WPA2-Enterprise with PEAP/MSCHAPv2 authentication. By leveraging **NetworkManager** and its command-line interface tool **nmcli**, the script:

1. Scans for the desired network SSID (e.g., `"eduroam"`).
2. Checks if a previous profile exists and removes it (if found).
3. Creates a new connection profile with the proper 802.1x settings.
4. Brings up (activates) the new connection.
5. Can optionally install NetworkManager if it is not already present, by detecting the distribution and using the appropriate package manager.

---

## Prerequisites

- A Linux distribution that uses (or can use) **NetworkManager**.
- **sudo** privileges to install packages and modify system network connections.
- A valid **eduroam** (or similar WPA2-Enterprise) username and password.
- Basic knowledge of your Wi-Fi interface name (e.g., `wlan0`, `wlp2s0`, etc.).

---

## Usage

1. **Clone or Download**  
   Clone this repository or download the script (`connect-eduroam.sh`) to your local machine.

2. **Make the Script Executable**  
   ```bash
   chmod +x connect-eduroam.sh
   ```

3. **Edit Script Variables**  
   Open the script in a text editor:
   - `SSID="eduroam"` — change if your network uses a different name.
   - `USERNAME="username@uni.edu"` — your eduroam/uni username.
   - `PASSWORD="password"` — your Wi-Fi password.
   - `INTERFACE="wlan0"` — update to match your Wi-Fi interface (check with `nmcli dev status` or `iw dev`).

4. **Run the Script**  
   ```bash
   ./connect-eduroam.sh
   ```

5. **Verify Connection**  
   Once the script completes, you should see a message indicating a successful connection. Verify by running:
   ```bash
   nmcli connection show --active
   ```
   or by checking your system’s network status.

> **Security Note**: Storing passwords in plain text can be insecure. Consider using environment variables if you are concerned about storing credentials in the script.
---

## Troubleshooting & Tips

1. **Interface Names**  
   If the script fails to connect, make sure you have the correct interface name in the `INTERFACE` variable.  
   ```bash
   nmcli dev status
   ```
   This command will show the active interfaces (e.g. `wlan0`, `wlp3s0`, etc.).

2. **CA Certificate / Anonymous Identity**  
   Some universities require a CA certificate or domain validation settings:
   - `802-1x.domain-suffix-match`
   - `802-1x.altsubject-matches`
   - `802-1x.anonymous-identity`

   Uncomment and adjust these lines in the script if your institution requires them.

3. **Manual Credentials Entry**  
   Instead of hardcoding your password, you can prompt for the password:
   ```bash
   read -sp "Enter your eduroam password: " PASSWORD
   ```
   This avoids leaving the password in plain text.

4. **Unsupported Distro**  
   - If the script cannot detect your distribution or fails to install **NetworkManager**, you must manually install or enable **NetworkManager** before running the script.
   - Please make an issue with your distribution and I can add support

---

## License

**connect-eduroam.sh** is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and distribute it under the terms of this license.
