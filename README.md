# 🎛️ REAPER + Reapertips Configuration

[![Build & Release Packages](https://github.com/ahobbit/reaper-config/actions/workflows/build-release.yml/badge.svg)](https://github.com/ahobbit/reaper-config/actions/workflows/build-release.yml)
[![Latest Release](https://img.shields.io/github/v/release/ahobbit/reaper-config?label=Latest%20Release&color=success)](https://github.com/ahobbit/reaper-config/releases/latest)
![Platform](https://img.shields.io/badge/Platform-Windows%20x64%20%7C%20macOS-blue)

A fine-tuned, reproducible REAPER setup designed for a clean and efficient production workflow. It combines the **Reapertips theme** with optimized project defaults, custom color palettes, responsive meters, automatic project backups, and 1-click installation for both **Windows x64** and **macOS** (Apple Silicon & Intel).

---

## ✨ Features & Highlights

* **🎨 Complete Reapertips Suite:** Theme version 1.93b plus all 5 official variants (Dark, Light, Hybrid, Green, Purple) with matched typography (Fira Sans & Roboto Bold).
* **🌈 Custom Color Management:** Floating color toolbar with 12 pre-configured color palettes for fast track and item organization.
* **⚡ Smooth Performance & Editing:**
  * Mouse-centered horizontal and vertical zoom.
  * 30 Hz responsive meters with 40 dB/s decay rate.
  * 600 ms / 50% media buffer and 1024-sample render block for stability.
  * Unified MIDI editor with linked selection.
  * 24 px track spacers and clean folder indentation.
* **🛡️ Zero-Loss Project Backups:** Auto-saves every minute when not recording (up to 50 versions per project) into dedicated backup folders.
* **🔌 Essential Extensions Pre-bundled:** Includes **ReaPack 1.2.6** (with community repositories) and **SWS 2.14.0.7**.

---

## 🚀 Quick Install (No Technical Setup Required)

You don't need Python, Git, or terminal commands to install this configuration. Pre-packaged bundles are built automatically in the cloud.

### 1. Download
Go to the **[Latest Release](https://github.com/ahobbit/reaper-config/releases/latest)** and download the ZIP for your operating system:
* **Windows:** `REAPER-Reapertips-windows.zip`
* **macOS:** `REAPER-Reapertips-macos.zip`

### 2. Run the Installer
Extract the ZIP and close REAPER if it is open:
* **On Windows:** Double-click `02-APPLY-CONFIGURATION.cmd`
* **On macOS:** Double-click `Apply-configuration.command`

> [!NOTE]
> The installer script safely creates a backup of any existing REAPER settings before applying anything, checks that REAPER 7.79+ is present (downloading the official installer if needed), and verifies the SHA-256 integrity of all files.

### 3. Final Step in REAPER
1. Open REAPER.
2. Configure your audio interface and MIDI devices in **Preferences > Audio > Device**.
3. On the **Reapertips Colors** toolbar:
   * Click **Color management > Load color set from file**.
   * Select `Mac-Reapertips.SWSColor` (macOS) or `Win-Reapertips.SWSColor` (Windows) from the `ColorSets/Reapertips` folder.

---

## 📁 Repository Structure

```text
├── common/              # Shared assets: themes, scripts, menus, actions, ReaPack config
├── platforms/
│   ├── macos/           # macOS-specific reaper.ini, palettes, and restore script
│   └── windows/         # Windows-specific reaper.ini, palettes, and restore script
├── fonts/               # Theme fonts (Fira Sans & Roboto)
├── docs/                # Compatibility notes and changelog
├── dependencies.lock.json # Pinned official download URLs and SHA-256 hashes
└── .github/workflows/   # Automated CI/CD pipeline that builds ZIP releases
```

---

## 🛠️ Making Changes & Updating

Everything is automated through GitHub Actions:

1. **Tweak your setup:** Adjust settings in REAPER, then close it to save.
2. **Commit your changes:**
   ```sh
   git add common platforms
   git commit -m "Describe your adjustment"
   git push origin main
   ```
3. **Automatic Release:** In ~20 seconds, GitHub Actions runs integrity checks, packages the new Windows and macOS ZIPs, and updates the **[Latest Release](https://github.com/ahobbit/reaper-config/releases/latest)** automatically.

---

## 📖 Additional Documentation

* **[Compatibility Matrix](docs/COMPATIBILITY.md):** Detailed breakdown of differences between Windows and macOS settings.
* **[Changelog](docs/CHANGELOG.md):** Version history and feature log.
