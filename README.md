<div align="center">

```
██████╗ ██╗██████╗  ██████╗ ████████╗███████╗
██╔══██╗██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
██║  ██║██║██║  ██║██║   ██║   ██║   ███████╗
██║  ██║██║██║  ██║██║   ██║   ██║   ╚════██║
██████╔╝██║██████╔╝╚██████╔╝   ██║   ███████║
╚═════╝ ╚═╝╚═════╝  ╚═════╝   ╚═╝   ╚══════╝
```

**toolkit deploy ACS stack — cepat, bersih, no drama** ☕

<br>

![version](https://img.shields.io/badge/v5.5-brightgreen?style=flat-square&logo=github)
![platform](https://img.shields.io/badge/Ubuntu%20%7C%20Debian-4A90D9?style=flat-square&logo=linux&logoColor=white)
![arch](https://img.shields.io/badge/amd64%20%7C%20arm64%20%7C%20armhf-orange?style=flat-square)
![lang](https://img.shields.io/badge/bash-121011?style=flat-square&logo=gnu-bash&logoColor=white)
![docker](https://img.shields.io/badge/docker-2496ED?style=flat-square&logo=docker&logoColor=white)

</div>

---

## ⚡ One-liner install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zlabkeeb/DidotsServ/main/install.sh)
```

> Jalankan sebagai **root** atau pakai `sudo`. Udah, segitu aja.

---

## 🧩 Apa aja yang bisa di-install

| | Menu | Keterangan |
|--|------|------------|
| 🐳 | **Docker** | Install / uninstall Docker + Compose |
| 🚀 | **ACS Core** | Install, konfigurasi DB, atau uninstall |
| 🖥️ | **ACS Panel** | Panel manajemen berbasis web |
| 🌐 | **Customer Portal** | Portal pelanggan self-service |
| 📊 | **Status** | Cek semua layanan sekaligus |

---

## 🔌 Port map

```
┌─────────────────────────┬────────┐
│ Layanan                 │  Port  │
├─────────────────────────┼────────┤
│ ACS UI                  │  3000  │
│ ACS CWMP                │  7547  │
│ ACS NBI                 │  7557  │
│ ACS FS                  │  7567  │
│ ACS Panel               │  1997  │
│ Customer Portal         │  1998  │
└─────────────────────────┴────────┘
```

---

## 🖥️ Environment yang didukung

- **OS** — Ubuntu 20.04 / 22.04 / 24.04 · Debian 10 / 11 / 12 · Armbian · Raspberry Pi OS
- **Arch** — `amd64` · `arm64` · `armhf`
- **Mode** — Native Linux, WSL2

---

## 📁 Struktur repo

```
DidotsServ/
├── install.sh               ← entry point
├── db/                      ← seed data ACS (BSON)
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

## 🔐 Default credentials

<table>
<tr>
<td>

**ACS UI** — `:3000`
```
user : admin
pass : admin
```

</td>
<td>

**ACS Panel** — `:1997`
```
user : admin
pass : solusidigitalnet
```

</td>
</tr>
</table>

> ⚠️ Ganti password setelah login pertama, jangan sampe lupa.

---

## 🔄 Update

Jalanin ulang perintah yang sama, otomatis pull versi terbaru:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zlabkeeb/DidotsServ/main/install.sh)
```

---

<div align="center">
<sub>· solusidigitalnet · 2025</sub>
</div>