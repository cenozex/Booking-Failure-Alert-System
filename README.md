<div align="center">

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ██████╗  ██████╗  ██████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗   ║
║    ██╔══██╗██╔═══██╗██╔═══██╗██║ ██╔╝██║████╗  ██║██╔════╝   ║
║    ██████╔╝██║   ██║██║   ██║█████╔╝ ██║██╔██╗ ██║██║  ███╗  ║
║    ██╔══██╗██║   ██║██║   ██║██╔═██╗ ██║██║╚██╗██║██║   ██║  ║
║    ██████╔╝╚██████╔╝╚██████╔╝██║  ██╗██║██║ ╚████║╚██████╔╝  ║
║    ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝   ║
║                                                              ║
║        ┌─────────────────────────────────────────┐           ║
║        │              F A I L U R E   A L E R T  │           ║
║        │                     S Y S T E M         │           ║
║        └─────────────────────────────────────────┘           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

<br/>

<!-- CORE BADGES -->
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Discord](https://img.shields.io/badge/Alerts-Discord%20Webhooks-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen?style=for-the-badge&logo=github&logoColor=white)](#)

<br/>

<!-- STATUS BADGES -->
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square&logo=statuspage&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![Scripts](https://img.shields.io/badge/Scripts-2-blue?style=flat-square&logo=gnubash)
![Made By](https://img.shields.io/badge/Made%20By-CENOZEX-red?style=flat-square)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [System Architecture](#-system-architecture)
- [Scripts](#-scripts)
  - [Health Monitor](#-health_monitorsh)
  - [Booking Alert Watcher](#-booking_alert_watchersh)
- [Setup & Configuration](#️-setup--configuration)
- [Environment Variables](#-environment-variables)
- [Usage](#-usage)
- [Alert Examples](#-alert-examples)
- [Contributing](#-contributing)

---

## 🔍 Overview

> A lightweight, production-ready **dual-monitoring system** that watches your booking application in real-time and fires instant Discord alerts when things go wrong — before your users notice.

This system combines **active health polling** and **passive log watching** to give complete visibility into your booking infrastructure. No dependencies beyond `curl` and `jq`.

```
┌─────────────────────────────────────────────────────────┐
│              BOOKING FAILURE ALERT SYSTEM               │
│                                                         │
│   [health_monitor.sh]        [booking_alert_watcher.sh] │
│   Polls HTTP endpoints   +   Tails application logs     │
│         ↓                            ↓                  │
│              Discord Webhook Alerts 🚨                  │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ Features

<table>
<tr>
<td>

**🔁 Continuous Health Polling**
Checks server & DB endpoints on a configurable interval (default: 30s)

</td>
<td>

**📜 Real-Time Log Watching**
Tails your booking log file live — catches errors the moment they appear

</td>
</tr>
<tr>
<td>

**🔔 Discord Webhook Alerts**
Instant, richly formatted notifications sent directly to your Discord channel

</td>
<td>

**⏱️ Cooldown / Anti-Spam**
Built-in cooldown logic (5 min health monitor / 15s log watcher) prevents alert floods

</td>
</tr>
<tr>
<td>

**🔒 `.env` Based Config**
All secrets and URLs live in a `.env` file — never hardcoded, always gitignored

</td>
<td>

**🧱 Zero Dependencies**
Only requires `bash`, `curl`, and `jq` — available on any Linux server

</td>
</tr>
</table>

---

## 🏗 System Architecture

```
booking-failure-alert-system/
│
├── 📄 health_monitor.sh          # Active: HTTP health endpoint poller
├── 📄 booking_alert_watcher.sh   # Passive: Real-time log file watcher
├── 📄 .env                       # 🔒 Your config & secrets (gitignored)
├── 📄 .gitignore                 # Keeps .env out of version control
└── 📄 README.md                  # You are here
```

---

## 📜 Scripts

### 🖥 `health_monitor.sh`

[![Type](https://img.shields.io/badge/Type-Active%20Poller-orange?style=flat-square)](#)
[![Interval](https://img.shields.io/badge/Default%20Interval-30s-blue?style=flat-square)](#)
[![Cooldown](https://img.shields.io/badge/Alert%20Cooldown-5%20min-purple?style=flat-square)](#)

Continuously polls two HTTP health endpoints — one for the application server and one for the database — and sends a Discord alert if either goes down.

**How it works:**

1. Every `POLL_INTERVAL` seconds, sends `GET` requests to `SERVER_HEALTH_URL` and `DB_HEALTH_URL`
2. Parses JSON responses using `jq` — expects `{ "online": "up" }` from the server and `{ "database": "connected" }` from the database
3. If either check fails (connection error, bad response, or unexpected value), sets `SEND_ALERT=true`
4. If the cooldown window has elapsed since the last alert, fires the Discord webhook
5. Resets the cooldown timer automatically when the system recovers

```bash
# Expected server health response
{ "online": "up" }

# Expected database health response
{ "database": "connected" }
```

---

### 📂 `booking_alert_watcher.sh`

[![Type](https://img.shields.io/badge/Type-Log%20Watcher-teal?style=flat-square)](#)
[![Method](https://img.shields.io/badge/Method-tail%20-F-blue?style=flat-square)](#)
[![Cooldown](https://img.shields.io/badge/Anti--Spam%20Sleep-15s-purple?style=flat-square)](#)

Follows your application's log file in real-time using `tail -F` and fires a Discord alert whenever a critical error pattern is detected.

**Watched patterns:**

| Pattern | Meaning |
|---|---|
| `Payment Failed` | A payment transaction has failed in the booking flow |
| `DB Connection Lost` | The application has lost its database connection |

**Default log path:** `~/booking_app/booking.log`
> The script auto-creates the log directory and file if they don't exist.

---

## ⚙️ Setup & Configuration

### Prerequisites

![bash](https://img.shields.io/badge/bash-v4%2B-4EAA25?style=flat-square&logo=gnubash)
![curl](https://img.shields.io/badge/curl-required-073551?style=flat-square)
![jq](https://img.shields.io/badge/jq-required-blue?style=flat-square)

```bash
# Check prerequisites
bash --version
curl --version
jq --version

# Install jq if missing (Ubuntu/Debian)
sudo apt-get install jq -y
```

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/cenozex/Booking-Failure-Alert-System
cd Booking-Failure-Alert-System

# 2. Create your .env file
cp .env.example .env
nano .env

# 3. Make scripts executable
chmod +x health_monitor.sh booking_alert_watcher.sh

# 4. Run the scripts
./health_monitor.sh &
./booking_alert_watcher.sh &
```

---

## 🔐 Environment Variables

Create a `.env` file in the project root. It is already listed in `.gitignore` — **never commit this file.**

```env
# ─────────────────────────────────────────
# REQUIRED
# ─────────────────────────────────────────

# Your Discord channel webhook URL
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN

# URL to your server's health endpoint
SERVER_HEALTH_URL=https://yourapp.com/health

# URL to your database health endpoint
DB_HEALTH_URL=https://yourapp.com/db-health


# How often to poll, in seconds (default: 30)
POLL_INTERVAL=30
```

> 💡 **Tip:** To get a Discord webhook URL, go to your server → Channel Settings → Integrations → Webhooks → New Webhook.

---

## 🚀 Usage

### Run Manually

```bash
# Start the health monitor in the background
./health_monitor.sh &

# Start the log watcher in the background
./booking_alert_watcher.sh &
```

### Run as System Services (Recommended for Production)

```bash
# Create a systemd service for the health monitor
sudo nano /etc/systemd/system/health-monitor.service
```

```ini
[Unit]
Description=Booking System Health Monitor
After=network.target

[Service]
ExecStart=/bin/bash /path/to/health_monitor.sh
WorkingDirectory=/path/to/booking-failure-alert-system
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable health-monitor
sudo systemctl start health-monitor
```

### View Logs

```bash
# Console output from health monitor
journalctl -u health-monitor -f

# Booking application log being watched
tail -f ~/booking_app/booking.log
```

---

## 🔔 Alert Examples

When an issue is detected, you'll receive a Discord message like:

```
🚨 ALERT: Booking System Error - [2024-01-15 14:32:08]

Server Status: DOWN (Connection Failed)
DB Status: UP

Check logs immediately!
```

```
🚨 ALERT: Booking System Error - 2024-01-15 14:35:22 - Check Logs Immediately
```

> ⏳ Alerts are suppressed during cooldown periods to prevent spam.

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge&logo=github)](https://github.com/cenozex/Booking-Failure-Alert-System/pulls)
[![Issues](https://img.shields.io/badge/Report-Issues-red?style=for-the-badge&logo=github)](https://github.com/cenozex/Booking-Failure-Alert-System/issues)

---

<div align="center">

**Built with ❤️ by CENOZEX**

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:6b0f1a,50:c1121f,100:e63946&height=100&section=footer"/>

</div>
