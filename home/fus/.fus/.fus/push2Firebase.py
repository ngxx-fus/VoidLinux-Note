#!/usr/bin/env python3
"""
push_public_ip_to_firebase.py (auto version)

- Đọc IP public
- Đăng nhập Firebase (email/password có sẵn)
- Ghi dữ liệu lên Firebase Realtime Database
"""

import requests
import socket
from datetime import datetime

# =====================================================
# ⚙️ THÔNG TIN CẤU HÌNH — SỬA PHẦN NÀY CHO PHÙ HỢP
# =====================================================
FIREBASE_URL   = "https://my-nas-ip-default-rtdb.asia-southeast1.firebasedatabase.app/"
FIREBASE_PATH  = "devices/my-nas"     # path trên Realtime DB
FIREBASE_API_KEY = "AIzaSyANRc0UBr3t9rAz6LRjuatZKlGGk7dTG4Y"

EMAIL    = "fus-3568@my-nas-ip.iam.gserviceaccount.com"
PASSWORD = "nGXXFUS@3204"

# Nếu bạn không muốn dùng auth, đặt USE_AUTH = False
USE_AUTH = True

# Các port (tùy chọn)
PORTS = {
    "FileBrowsePort": "9372",
    "OMVPort": "37312",
    "SSHPort": "37963"
}
# =====================================================


def get_public_ip(timeout=5):
    """Lấy IP public qua api.ipify.org"""
    try:
        r = requests.get("https://api.ipify.org?format=json", timeout=timeout)
        r.raise_for_status()
        return r.json().get("ip")
    except Exception as e:
        print("❌ Lỗi khi lấy public IP:", e)
        return None


def firebase_signin_email_password(email, password, api_key, timeout=8):
    """Đăng nhập Firebase Auth bằng email/password"""
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
        print("❌ Lỗi đăng nhập Firebase:", e)
        return None


def push_to_firebase(db_url, path, data, id_token=None, timeout=8):
    """Ghi data (dict) lên Realtime Database (PATCH = update)"""
    if db_url.endswith('/'):
        db_url = db_url[:-1]
    url = f"{db_url}/{path}.json"
    params = {}
    if id_token:
        params['auth'] = id_token
    try:
        r = requests.patch(url, params=params, json=data, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        print("❌ Lỗi khi push lên Firebase:", e)
        try:
            print("Response:", r.status_code, r.text)
        except Exception:
            pass
        return None


def gather_payload(custom_ports=None):
    """Tạo payload để gửi lên Firebase"""
    ip = get_public_ip()
    hostname = socket.gethostname()
    ts = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    payload = {
        "GlobalIp": ip or "",
        "Hostname": hostname,
        "LastUpdate": ts,
        "RefreshNow": False,
    }
    if custom_ports:
        payload.update(custom_ports)
    return payload


def main():
    print("=== Push public IP -> Firebase Realtime DB ===")
    id_token = None
    if USE_AUTH:
        print("Đăng nhập Firebase...")
        id_token = firebase_signin_email_password(EMAIL, PASSWORD, FIREBASE_API_KEY)
        if not id_token:
            print("⚠️  Đăng nhập thất bại, ghi public (nếu rule cho phép).")

    payload = gather_payload(PORTS)
    print("Dữ liệu sẽ gửi:", payload)

    res = push_to_firebase(FIREBASE_URL, FIREBASE_PATH, payload, id_token=id_token)
    if res is not None:
        print("✅ Ghi thành công:", res)
    else:
        print("❌ Ghi thất bại.")

import time

if __name__ == "__main__":
    while(1):
        main()
        time.sleep(600)

