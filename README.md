# DidotsServ — GenieACS Installer

<p align="center">
  <img src="https://img.shields.io/badge/version-5.5-blue" />
  <img src="https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-informational" />
  <img src="https://img.shields.io/badge/arch-amd64%20%7C%20arm64%20%7C%20armhf-success" />
  <img src="https://img.shields.io/badge/language-Bash-orange" />
</p>

Script installer interaktif untuk **GenieACS**, **GenieACS Panel**, dan **Customer Portal** berbasis Docker.

---

## 🚀 Cara Install (Satu Perintah)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zlabkeeb/DidotsServ/main/install.sh)
```

> Jalankan sebagai **root** atau dengan `sudo`.

---

## 📋 Fitur

| Menu | Keterangan |
|------|-----------|
| 🐳 Docker | Install / Uninstall Docker & Docker Compose |
| 🚀 GenieACS | Install / Konfigurasi DB / Uninstall GenieACS |
| 🖥️ GenieACS Panel | Install / Uninstall GenieACS Panel |
| 🌐 Customer Portal | Install / Uninstall Customer Portal |
| 📊 Status | Lihat status semua layanan yang berjalan |

---

## 🔌 Port yang Digunakan

| Layanan | Port |
|---------|------|
| GenieACS UI | 3000 |
| GenieACS CWMP | 7547 |
| GenieACS NBI | 7557 |
| GenieACS FS | 7567 |
| GenieACS Panel | 1997 |
| Customer Portal | 1998 |

---

## 🖥️ Sistem yang Didukung

- **OS**: Ubuntu (20.04, 22.04, 24.04), Debian (10, 11, 12), Armbian, Raspberry Pi OS
- **Arsitektur**: `amd64`, `arm64`, `armhf`
- **Environment**: Native Linux, WSL2

---

## 📁 Struktur Repository

```
DidotsServ/
├── install.sh          # Script installer utama
├── db/                 # File database GenieACS (BSON + metadata)
│   ├── cache.bson
│   ├── config.bson
│   ├── permissions.bson
│   ├── presets.bson
│   ├── provisions.bson
│   ├── users.bson
│   ├── virtualParameters.bson
│   └── *.metadata.json
└── README.md
```

---

## 📝 Catatan Konfigurasi

Setelah install GenieACS, akses UI di:
```
http://<IP-SERVER>:3000
Username: admin
Password: admin
```

Setelah install GenieACS Panel:
```
http://<IP-SERVER>:1997
Username: admin
Password: solusidigitalnet
```

---

## 🔄 Update Script

Untuk update ke versi terbaru, cukup jalankan ulang perintah install:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zlabkeeb/DidotsServ/main/install.sh)
```

---

## ⚠️ Persyaratan

- RAM minimum: **1 GB** (2 GB disarankan)
- Storage minimum: **10 GB**
- Koneksi internet aktif saat instalasi