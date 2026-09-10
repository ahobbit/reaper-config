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
* **🔔 66 Curated Metronome Sounds:** Built-in clicks from popular DAWs (Pro Tools, Logic, Ableton, Cubase, FL Studio, MPC, Maschine) and mechanical clicks, pre-configured with the Reapertips favorite (Pro Tools Marimba).
* **🎨 11 Reapertips MIDI Colormaps:** High-contrast velocity and note colormaps (Cold, Cubase, Deluxe, FL Dark/Light, Forest, Rainbow, Shadow, Smooth, Vintage), pre-configured with Cubase velocity colors.
* **✨ 750+ Essential Toolbar Icons in 13 Colorways:** ~19,800 icons across 13 color themes (Blue, Green, Red, Synthwave, Pastel, etc.) with native 100%, 150%, and 200% Retina scaling, plus border presets in `Data/Borders/`.
* **🌙 Full Dark Mode (Windows & macOS):** Bundles RobKor77's **ReaperDarkMode 1.1.0** for Windows (dark title bars, menus, dialogs, and controls) and enables native Mojave+ Dark Mode for macOS.
* **🔄 1-Click REAPER Update Utility:** Pre-bundled script by FeedTheCat to upgrade, downgrade, or test pre-releases directly inside REAPER. FeedTheCat repository pre-configured in ReaPack.
* **🔌 Essential Extensions Pre-bundled:** Includes **ReaPack 1.2.6** (with community repositories), **SWS 2.14.0.7**, and **ReaperDarkMode 1.1.0** (Windows).

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
4. *(Optional)* Right-click the **Metronome** icon in the transport bar to switch between any of the 66 bundled click sounds in `Data/Metronome Sounds/`.
5. *(Optional)* In **Preferences > MIDI Editor**, customize your default colormap from `Data/colormaps/` (or switch note coloring in the MIDI editor via **View > Color notes by**).
6. *(Optional)* Customize any toolbar: right-click a toolbar, click **Customize toolbar... > Icon... > Change icon**, and filter by typing any color or action name (e.g. `blue grid`, `synthwave`, `red`).
7. *(Optional)* Update or test REAPER versions anytime: press `?` to open the **Actions** list, search for `Script: REAPER Update Utility.lua`, and run it.

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

## 🛠️ Developer Workflow (DX)

A unified CLI (`./dev`) and `Makefile` make it easy to inspect, sync, and verify settings between your live REAPER installation and this repository:

| Command | Description |
| :--- | :--- |
| `make diff` *(or `./dev diff`)* | Compare live REAPER settings against tracked repository profiles |
| `make pull` *(or `./dev pull`)* | Import & sanitize updated settings from live REAPER into the repo |
| `make test` *(or `./dev test`)* | Run test suite and manifest verification |
| `make apply` *(or `./dev apply`)* | Deploy repo settings into local REAPER with automatic backup |
| `make build` *(or `./dev build`)* | Package distribution ZIPs locally |
| `make hook` *(or `./dev install-hook`)* | Install Git pre-commit hook to prevent path/license leaks |

### Updating & Publishing
1. Adjust settings inside REAPER, then close it to save.
2. Run `make pull` to sync and sanitize changes into the repo.
3. Commit and push:
   ```sh
   git commit -am "Update toolbar layout"
   git push origin main
   ```
4. GitHub Actions verifies tests, packages the ZIPs, and updates the **[Latest Release](https://github.com/ahobbit/reaper-config/releases/latest)** automatically in ~20s.

---

## 📖 Additional Documentation

* **[Compatibility Matrix](docs/COMPATIBILITY.md):** Detailed breakdown of differences between Windows and macOS settings.
* **[Changelog](docs/CHANGELOG.md):** Version history and feature log.
