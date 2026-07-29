<div align="center">

```
 .d8888b.           888                   d8b 8888888b.  d8b          d8b 888             888 888b    888          888    
d88P  Y88b          888                   Y8P 888  "Y88b Y8P          Y8P 888             888 8888b   888          888    
Y88b.               888                       888    888                  888             888 88888b  888          888    
 "Y888b.    .d88b.  888 888  888 .d8888b  888 888    888 888  .d88b.  888 888888  8888b.  888 888Y88b 888  .d88b.  888888 
    "Y88b. d88""88b 888 888  888 88K      888 888    888 888 d88P"88b 888 888        "88b 888 888 Y88b888 d8P  Y8b 888    
      "888 888  888 888 888  888 "Y8888b. 888 888    888 888 888  888 888 888    .d888888 888 888  Y88888 88888888 888    
Y88b  d88P Y88..88P 888 Y88b 888      X88 888 888  .d88P 888 Y88b 888 888 Y88b.  888  888 888 888   Y8888 Y8b.     Y88b.  
 "Y8888P"   "Y88P"  888  "Y88888  88888P' 888 8888888P"  888  "Y88888 888  "Y888 "Y888888 888 888    Y888  "Y8888   "Y888 
                                                                  888                                                     
                                                             Y8b d88P                                                     
                                                              "Y88P"                                                      
                               8888888                   888             888 888                                          
                                 888                     888             888 888                                          
                                 888                     888             888 888                                          
                                 888   88888b.  .d8888b  888888  8888b.  888 888  .d88b.  888d888                         
                                 888   888 "88b 88K      888        "88b 888 888 d8P  Y8b 888P"                           
                                 888   888  888 "Y8888b. 888    .d888888 888 888 88888888 888                             
                                 888   888  888      X88 Y88b.  888  888 888 888 Y8b.     888                             
                               8888888 888  888  88888P'  "Y888 "Y888888 888 888  "Y8888  888                             
                                                                                                                          
                                                                                                                          
                                                                                                                                                                                                                    
```

**toolkit deploy ACS stack — cepat, bersih, no drama** ☕

<br>

![version](https://img.shields.io/badge/v5.6-brightgreen?style=flat-square&logo=github)
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
<td>

**ACS Portal** — `:1998`
```
access code :
```

</td>
</tr>
</table>

> ⚠️ Ganti password setelah login pertama, jangan sampe lupa.

---

<div align="center">
<sub>· solusidigitalnet · 2026</sub>
</div>