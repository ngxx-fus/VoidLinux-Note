#!/usr/bin/env python3
### @file push_public_ip_to_firebase.py
### @brief Script to fetch public IP and push device info to Firebase Realtime Database.
### @details This script manually parses a shell config file to avoid syntax errors, retrieves the public IP, and updates a Firebase RTDB node.
### @author Nguyen Thanh Phu
### @version 1.4.0

import requests
import socket
import time
import os
from datetime import datetime

# =====================================================
# ⚙️ CONFIGURATION LOADING
# =====================================================

### @brief Path to the configuration file containing secrets.
CONFIG_PATH = "/home/fus/.fus/.private/FirebaseRTDBSecret.sh"
# CONFIG_PATH = ".private/FirebaseRTDBSecret.sh" # Uncomment for local testing

### @brief Parses a shell-like config file manually to handle non-standard syntax.
### @details Reads the file line by line, ignores comments, and splits by '=' to extract key-value pairs. 
###          It handles spaces around '=' and removes quotes from values. Includes error handling.
### @param file_path The absolute or relative path to the configuration file.
### @return A dictionary containing the loaded configuration variables.
def load_config(file_path):
    config = {}
    if not os.path.exists(file_path):
        print(f"[WARN] Config file not found: {file_path}")
        return config
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                # Ignore comments and empty lines
                if not line or line.startswith('#'):
                    continue
                
                if '=' in line:
                    key, value = line.split('=', 1)
                    # Remove spaces and quotes
                    clean_key = key.strip()
                    clean_value = value.strip().strip('"').strip("'")
                    config[clean_key] = clean_value
    except PermissionError:
        print(f"[ERR] Permission denied when reading: {file_path}")
    except Exception as e:
        print(f"[ERR] Failed to read config file: {e}")
        
    return config

# Load config immediately upon script start
cfg = load_config(CONFIG_PATH)

### @var FIREBASE_URL
### @brief Base URL for Firebase Realtime Database loaded from config.
FIREBASE_URL = cfg.get("FIREBASE_URL", "")

### @var FIREBASE_PATH
### @brief Database path node for the device loaded from config.
FIREBASE_PATH = cfg.get("FIREBASE_PATH", "")

### @var FIREBASE_API_KEY
### @brief Web API Key for Firebase Authentication loaded from config.
FIREBASE_API_KEY = cfg.get("FIREBASE_API_KEY", "")

### @var EMAIL
### @brief Service account email for authentication loaded from config.
EMAIL = cfg.get("EMAIL", "")

### @var PASSWORD
### @brief Password for the service account loaded from config.
PASSWORD = cfg.get("PASSWORD", "")

### @var USE_AUTH
### @brief Flag to enable or disable authentication.
### @note Set to True to enforce security rules.
USE_AUTH = True

### @var PORTS
### @brief Dictionary of specific service ports to report to the database.
PORTS = {
    "SSHPort": "3165x"
}

# =====================================================
# ⚙️ CORE FUNCTIONS
# =====================================================

### @brief Retrieves the public IP address via an external API.
### @details Uses api.ipify.org to fetch the current public IP.
### @param timeout Request timeout in seconds (default: 5).
### @return The public IP address as a string, or None if the request fails.
def get_public_ip(timeout=5):
    try:
        r = requests.get("https://api.ipify.org?format=json", timeout=timeout)
        r.raise_for_status()
        return r.json().get("ip")
    except Exception as e:
        print("[ERR] Error fetching public IP:", e)
        return None


### @brief Authenticates with Firebase via Email/Password to obtain an ID Token.
### @details Sends a POST request to Google Identity Toolkit.
### @param email The user email for authentication.
### @param password The user password.
### @param api_key The Firebase Web API Key.
### @param timeout Request timeout in seconds (default: 10).
### @return The 'idToken' string if successful, or None on failure.
def firebase_signin_email_password(email, password, api_key, timeout=10):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }
    try:
        r = requests.post(url, json=payload, timeout=timeout)
        r.raise_for_status()
        data = r.json()
        return data.get("idToken")
    except Exception as e:
        print(f"[ERR] Error signing in to Firebase with {email}:", e)
        try:
            print("[DEBUG] Server response:", r.text)
        except:
            pass
        return None


### @brief Updates (PATCH) data to Firebase Realtime Database.
### @details Constructs the URL based on DB URL and Path, then sends a PATCH request.
### @param db_url The base URL of the Firebase Database.
### @param path The specific node path (can be empty for root).
### @param data A dictionary of data to be uploaded.
### @param id_token The authentication token (optional).
### @param timeout Request timeout in seconds (default: 10).
### @return The JSON response from Firebase, or None on failure.
def push_to_firebase(db_url, path, data, id_token=None, timeout=10):
    if db_url.endswith('/'):
        db_url = db_url[:-1]
    
    # Handle optional path
    if path:
        url = f"{db_url}/{path}.json"
    else:
        url = f"{db_url}.json" # Write to root if path is empty

    params = {}
    if id_token:
        params['auth'] = id_token
    try:
        r = requests.patch(url, params=params, json=data, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        print("[ERR] Error pushing to Firebase:", e)
        try:
            print("[LOG] Response:", r.status_code, r.text)
        except Exception:
            pass
        return None


### @brief Collects the system payload to be sent.
### @details Gathers Public IP, Hostname, Current Timestamp, and custom ports.
### @param custom_ports A dictionary of extra ports to include in the payload.
### @return A dictionary containing the complete payload.
def gather_payload(custom_ports=None):
    ip = get_public_ip()
    hostname = socket.gethostname()
    ts = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
    payload = {
        "GlobalIp": ip or "",
        "Hostname": hostname,
        "LastUpdate": ts,
        "RefreshNow": False,
    }
    if custom_ports:
        payload.update(custom_ports)
    return payload


### @brief Helper function to mask half of a sensitive string.
### @param s The string to mask.
### @return A string with the second half replaced by asterisks.
def reveal_half(s):
    if not s: return "MISSING"
    length = len(s)
    if length <= 4: return s # Show full if too short
    visible = length // 2
    return s[:visible] + "*" * (length - visible)

### @brief Main execution function.
### @details Orchestrates the flow: Checks config -> Authenticates -> Gathers Data -> Pushes to Firebase.
def main():
    print("==========================================")
    print(f"[LOG] Starting Update at {datetime.now()}")
    
    # --- DEBUG PRINT CONFIGS ---
    print("[DEBUG] --- Current Configuration ---")
    print(f"[DEBUG] URL:      {FIREBASE_URL}")
    print(f"[DEBUG] PATH:     {FIREBASE_PATH}")
    print(f"[DEBUG] API KEY:  {reveal_half(FIREBASE_API_KEY)}")
    print(f"[DEBUG] EMAIL:    {EMAIL}")
    print(f"[DEBUG] PASSWORD: {reveal_half(PASSWORD)}")
    print("[DEBUG] -----------------------------")
    # ---------------------------

    # Check if configs are loaded
    if not FIREBASE_URL or not FIREBASE_API_KEY:
        print("[ERR] Missing Configuration (URL or API KEY). Check .sh file.")
        return

    id_token = None
    if USE_AUTH:
        print("[LOG] Logging in to Firebase...")
        id_token = firebase_signin_email_password(EMAIL, PASSWORD, FIREBASE_API_KEY)
        if not id_token:
            print("[ERR] Login failed. Aborting push to secure DB.")
            return # Stop here if auth fails to avoid spamming errors

    payload = gather_payload(PORTS)
    print("[LOG] Pushing Payload:", payload)

    res = push_to_firebase(FIREBASE_URL, FIREBASE_PATH, payload, id_token=id_token)
    if res is not None:
        print("[LOG] Successful Push.")
    else:
        print("[ERR] Push failed.")


if __name__ == "__main__":
    ### @brief Entry point of the script.
    ### @details Runs main() immediately, then enters an infinite loop running every 600 seconds.
    try:
        main() # Run once immediately
        while True:
            time.sleep(600)
            main()
    except KeyboardInterrupt:
        print("\n[LOG] Stopped by user.")
