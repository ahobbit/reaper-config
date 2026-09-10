# My REAPER / Reapertips Configuration

Reproducible personal setup for **Windows x64** and **macOS Intel/Apple Silicon**. Created from fine-tuned settings applied on September 9–10, 2026.

Repository: [https://github.com/ahobbit/reaper-config](https://github.com/ahobbit/reaper-config)

## What Git Tracks

- `common/`: toolbars, actions, mouse modifiers, ReaPack repositories, scripts/effects, and shared assets.
- `platforms/windows/`: adaptable preferences, Windows palettes, and PowerShell installer.
- `platforms/macos/`: Mac preferences, Mac palettes, and `.command` restore script.
- `fonts/`: theme typography.
- `dependencies.lock.json`: pinned versions, official download URLs, and SHA-256 hashes for each installer/extension.
- `docs/`: compatibility notes and decision history.
- `scripts/build.py`: packages standalone handoff folders/ZIPs for transfer to another machine.

All six Reapertips theme variants and their icons are tracked in Git to ensure an exact visual restore. Stock themes are sourced directly from the REAPER installer. Installers, generated ZIP archives, project recordings, peak caches, and license keys are excluded via `.gitignore`. Third-party assets retain their original authorship; this is a personal configuration repository.

## Installation (Quick & Easy)

You do **not** need to install Python or run any build commands. Ready-to-use packages are built and released automatically by GitHub Actions on every update:

1. Go to the [Releases page](https://github.com/ahobbit/reaper-config/releases).
2. Download `REAPER-Reapertips-windows.zip` (for Windows) or `REAPER-Reapertips-macos.zip` (for Mac).
3. Extract the ZIP and follow the instructions in `README-FIRST.txt`:
   - **Windows:** Double-click `02-APPLY-CONFIGURATION.cmd`.
   - **macOS:** Double-click `Apply-configuration.command`.

The installer scripts automatically back up your existing setup, adapt paths to your user account, verify file hashes, and apply the configuration.

[See compatibility details and verification boundaries](docs/COMPATIBILITY.md).

## Building Locally (Optional)

If you prefer to package bundles manually from source instead of using GitHub Releases, Python 3.9+ is required on the packaging machine:

```sh
python3 scripts/build.py all --download
# To bundle the official REAPER installer (no internet required on target machine):
python3 scripts/build.py all --download --offline
```

If `dist/REAPER-Reapertips-windows` or `dist/REAPER-Reapertips-macos` already exist, move them aside before rebuilding (the script prevents accidental overwrites).
- `--offline` bundles the official REAPER installer inside the package. Without this flag, the target install script downloads it only if missing or outdated.
- `--download` downloads missing pinned installers and validates their SHA-256 hashes without installing or executing anything.

## Maintaining Configuration History

After modifying settings inside REAPER, close the application so it writes its preferences to disk. Compare the relevant setting against versioned files and commit only intended changes. Do not blindly copy the entire resource directory, as it contains machine-specific paths, active audio devices, peak caches, and window states.

```sh
git diff
git add common platforms docs dependencies.lock.json
git commit -m "Describe the setting change and reason"
```

Update [docs/CHANGELOG.md](docs/CHANGELOG.md) with details and verification steps. For binary assets, replace the file and document the version. For installers, update the URL and SHA-256 in `dependencies.lock.json`. Future changes in REAPER are **not automatically synchronized** with Git.

To inspect a previous version without affecting your local REAPER install:
```sh
git show v1.0.0:platforms/windows/reaper.ini
```
Checking out a Git commit does not alter your live REAPER installation; generate and run the appropriate platform script with REAPER closed to apply changes.

## Automatic REAPER Verification & Bootstrap

The installer scripts verify the system's standard installation:
- They download **the exact version pinned in the lockfile**, preserving environment reproducibility.
- They check SHA-256 hashes before executing any installer.
- They preserve any installed version that is equal to or newer than the required version.
- On Windows, the interactive official installer is launched.
- On macOS, the official DMG is mounted and the app bundle is copied (with automatic backup of any existing version). System security prompts are respected.

To bump REAPER to a newer version, update the URL, SHA-256 hash, and version in `dependencies.lock.json`. On macOS, update the helper script and hash in tandem (the test suite verifies consistency). Portable and non-standard installation directories require manual setup.
