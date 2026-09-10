<div align="center">

<sub>
<pre>
.d88888b           dP                   oo 888888ba  oo          oo   dP            dP 888888ba             dP   
88.    "'          88                      88    `8b                  88            88 88    `8b            88   
`Y88888b. .d8888b. 88 dP    dP .d8888b. dP 88     88 dP .d8888b. dP d8888P .d8888b. 88 88     88 .d8888b. d8888P 
      `8b 88'  `88 88 88    88 Y8ooooo. 88 88     88 88 88'  `88 88   88   88'  `88 88 88     88 88ooood8   88   
d8'   .8P 88.  .88 88 88.  .88       88 88 88    .8P 88 88.  .88 88   88   88.  .88 88 88     88 88.  ...   88   
 Y88888P  `88888P' dP `88888P' `88888P' dP 8888888P  dP `8888P88 dP   dP   `88888P8 dP dP     dP `88888P'   dP   
                                                             .88                                                 
                                                         d8888P                                                  
                              dP                     dP            dP dP                                         
                              88                     88            88 88                                         
                              88 88d888b. .d8888b. d8888P .d8888b. 88 88 .d8888b. 88d888b.                       
                              88 88'  `88 Y8ooooo.   88   88'  `88 88 88 88ooood8 88'  `88                       
                              88 88    88       88   88   88.  .88 88 88 88.  ... 88                             
                              dP dP    dP `88888P'   dP   `88888P8 dP dP `88888P' dP                             
                                                                                                                 
</pre>
</sub>

**toolkit deploy ACS stack — cepat, bersih, no drama** ☕

<br>

![version](https://img.shields.io/badge/v9-brightgreen?style=flat-square&logo=github)
![platform](https://img.shields.io/badge/Ubuntu%20%7C%20Debian-4A90D9?style=flat-square&logo=linux&logoColor=white)
![arch](https://img.shields.io/badge/amd64%20%7C%20arm64%20%7C%20armhf-orange?style=flat-square)
![lang](https://img.shields.io/badge/bash-121011?style=flat-square&logo=gnu-bash&logoColor=white)
![docker](https://img.shields.io/badge/docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![proxmox](https://img.shields.io/badge/Proxmox%20LXC%20%7C%20KVM-orange?style=flat-square)

</div>

---

## ⚡ One-liner install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zlabkeeb/DidotsServ/main/install.sh)
```

> Jalankan sebagai **root** atau pakai `sudo`. Udah, segitu aja.

---

## 🖥️ Preview menu

```
  Interactive Installer v9

  [1] Docker
  [2] GenieACS
  [3] GenieACS Panel
  [4] Customer Portal
  [5] Lihat Status
  [6] Keluar

Pilih menu (1-6):
```

> Alur startup: **preflight check** (OS, arch, internet, deps, Docker) → cek Docker (auto-install jika belum ada) → **login Docker Hub otomatis** → menu utama.

### Login Docker Hub

Installer handle login Docker Hub otomatis. Saat install.sh jalan, tunggu sebentar — installer akan lanjut sendiri ke menu utama.

> Device yang sudah pernah install → install berikutnya di mesin yang sama langsung lanjut tanpa tunggu.

### Submenu

**Docker**
```
                  Docker

  [1] Uninstall Docker dan Docker Compose
  [0] Kembali

```

> Install Docker tidak ada di submenu karena sudah ditangani **otomatis** di awal (saat Docker belum terdeteksi).

**GenieACS**
```
                  GenieACS

  [1] Install GenieACS
  [2] Konfigurasi DB GenieACS
  [3] Uninstall GenieACS
  [0] Kembali

```

**GenieACS Panel**
```
                  GenieACS Panel

  [1] Install GenieACS Panel
  [2] Update GenieACS Panel
  [3] Uninstall GenieACS Panel
  [0] Kembali

```

**Customer Portal**
```
                  Customer Portal

  [1] Install Customer Portal
  [2] Uninstall Customer Portal
  [0] Kembali

```

---

## 🧩 Apa aja yang bisa di-install

| | Menu | Keterangan |
|--|------|------------|
| 🐳 | **Docker** | Auto-install di awal bila belum ada · uninstall via menu |
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
- **Proxmox** — VE host (bare-metal), KVM VM, LXC container (butuh **Nesting** enabled)
  - LXC tanpa nesting dideteksi di preflight → installer abort dengan instruksi `pct set <CTID> -features nesting=1`
  - LXC dengan nesting OK → lanjut normal

---

## 📁 Struktur repo

```
DidotsServ/
├── install.sh               ← entry point (v9)
├── db/                      ← seed data ACS (BSON, di-download otomatis saat install)
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
user : superadmin
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
