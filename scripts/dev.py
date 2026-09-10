#!/usr/bin/env python3
"""Developer Experience CLI for managing REAPER configurations."""
import argparse
import configparser
import os
import platform
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# ANSI colors for friendly CLI output
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
BLUE = "\033[94m"
CYAN = "\033[96m"
BOLD = "\033[1m"
RESET = "\033[0m"

def get_current_platform():
    system = platform.system().lower()
    return "macos" if system == "darwin" else "windows" if system == "windows" else None

def get_live_resource_dir(plat=None):
    plat = plat or get_current_platform()
    if plat == "macos":
        return Path(os.path.expanduser("~/Library/Application Support/REAPER"))
    elif plat == "windows":
        appdata = os.environ.get("APPDATA")
        return Path(appdata) / "REAPER" if appdata else None
    return None

def get_live_documents_dir():
    return Path(os.path.expanduser("~/Documents"))

def cmd_test(_args):
    """Run test and verification suite."""
    print(f"{CYAN}Running verification suite...{RESET}")
    result = subprocess.run([sys.executable, str(ROOT / "scripts/verify.py")])
    if result.returncode == 0:
        print(f"{GREEN}✓ All checks passed!{RESET}")
    return result.returncode

def cmd_build(args):
    """Build distribution zip packages."""
    plat = args.platform
    print(f"{CYAN}Building distribution packages for {plat}...{RESET}")
    cmd = [sys.executable, str(ROOT / "scripts/build.py"), plat, "--download"]
    if args.offline:
        cmd.append("--offline")
    dist = ROOT / "dist"
    if dist.exists():
        print(f"{YELLOW}Cleaning existing dist/ directory...{RESET}")
        shutil.rmtree(dist)
    result = subprocess.run(cmd)
    if result.returncode == 0:
        print(f"{GREEN}✓ Build succeeded! Packages are in dist/{RESET}")
    return result.returncode

def cmd_clean(_args):
    """Clean temporary build files and caches."""
    dist = ROOT / "dist"
    if dist.exists():
        shutil.rmtree(dist)
        print(f"{GREEN}Removed dist/{RESET}")
    for p in ROOT.rglob("__pycache__"):
        shutil.rmtree(p)
        print(f"{GREEN}Removed {p}{RESET}")
    print(f"{GREEN}✓ Clean completed.{RESET}")
    return 0

def cmd_diff(_args):
    """Compare tracked profile settings with live local REAPER install."""
    plat = get_current_platform()
    if not plat:
        print(f"{RED}Unsupported OS for live diff.{RESET}")
        return 1
    live_dir = get_live_resource_dir(plat)
    if not live_dir or not live_dir.exists():
        print(f"{RED}Local REAPER directory not found at: {live_dir}{RESET}")
        return 1

    repo_ini_file = ROOT / "platforms" / plat / "reaper.ini"
    live_ini_file = live_dir / "reaper.ini"

    if not repo_ini_file.exists() or not live_ini_file.exists():
        print(f"{RED}Missing reaper.ini in repo or live directory.{RESET}")
        return 1

    print(f"{BOLD}Comparing Live REAPER ➔ Tracked Profile ({plat}){RESET}")
    print(f"Live: {live_ini_file}")
    print(f"Repo: {repo_ini_file}\n")

    repo_cfg = configparser.ConfigParser(interpolation=None)
    repo_cfg.read(repo_ini_file)

    live_cfg = configparser.ConfigParser(interpolation=None)
    live_cfg.read(live_ini_file)

    doc_dir = str(get_live_documents_dir())
    res_dir = str(live_dir)

    changes_found = False
    for section in repo_cfg.sections():
        if not live_cfg.has_section(section):
            print(f"{RED}[Section missing in live REAPER]{RESET} [{section}]")
            changes_found = True
            continue

        for key, repo_val in repo_cfg.items(section):
            if not live_cfg.has_option(section, key):
                print(f"{YELLOW}[Missing in live]{RESET} [{section}] {key} = {repo_val}")
                changes_found = True
                continue

            live_val = live_cfg.get(section, key)
            # Expand placeholders in repo value for comparison
            expanded_repo_val = repo_val.replace("@@RESOURCE@@", res_dir).replace("@@DOCUMENTS@@", doc_dir)

            if live_val != expanded_repo_val:
                print(f"{CYAN}[Difference]{RESET} [{section}] {key}:")
                print(f"  {RED}- Tracked: {repo_val}{RESET}")
                print(f"  {GREEN}+ Live:    {live_val}{RESET}")
                changes_found = True

    if not changes_found:
        print(f"{GREEN}✓ Tracked settings match your live REAPER installation!{RESET}")
    else:
        print(f"\n{YELLOW}Tip: Run './dev pull' to update repo settings from your live REAPER.{RESET}")
    return 0

def cmd_pull(_args):
    """Import and sanitize updated settings from live REAPER into the repo."""
    plat = get_current_platform()
    if not plat:
        print(f"{RED}Unsupported OS for live pull.{RESET}")
        return 1
    live_dir = get_live_resource_dir(plat)
    if not live_dir or not live_dir.exists():
        print(f"{RED}Live REAPER directory not found: {live_dir}{RESET}")
        return 1

    repo_ini_file = ROOT / "platforms" / plat / "reaper.ini"
    live_ini_file = live_dir / "reaper.ini"

    repo_cfg = configparser.ConfigParser(interpolation=None)
    repo_cfg.read(repo_ini_file)

    live_cfg = configparser.ConfigParser(interpolation=None)
    live_cfg.read(live_ini_file)

    doc_dir = str(get_live_documents_dir())
    res_dir = str(live_dir)

    updated_count = 0
    for section in repo_cfg.sections():
        if not live_cfg.has_section(section):
            continue
        for key in repo_cfg.options(section):
            if live_cfg.has_option(section, key):
                live_val = live_cfg.get(section, key)
                # Sanitize live paths with placeholders
                sanitized_val = live_val.replace(res_dir, "@@RESOURCE@@").replace(doc_dir, "@@DOCUMENTS@@")
                if repo_cfg.get(section, key) != sanitized_val:
                    repo_cfg.set(section, key, sanitized_val)
                    updated_count += 1

    with open(repo_ini_file, "w") as f:
        repo_cfg.write(f)

    # Sync shared common files if present
    common_dir = ROOT / "common"
    for name in ["reaper-menu.ini", "reaper-kb.ini", "reaper-mouse.ini", "sws-autocoloricon.ini"]:
        live_file = live_dir / name
        repo_file = common_dir / name
        if live_file.exists() and repo_file.exists():
            content = live_file.read_text(encoding="utf-8", errors="ignore")
            # Ensure no personal username leaks
            sanitized = content.replace(res_dir, "@@RESOURCE@@").replace(doc_dir, "@@DOCUMENTS@@")
            if os.environ.get("USER"):
                sanitized = sanitized.replace(f"/Users/{os.environ['USER']}", "@@DOCUMENTS@@")
            if repo_file.read_text() != sanitized:
                repo_file.write_text(sanitized)
                print(f"{GREEN}Updated {name} from live installation.{RESET}")
                updated_count += 1

    print(f"{GREEN}✓ Pulled {updated_count} updated settings into repository profile ({plat}).{RESET}")
    return 0

def cmd_apply(_args):
    """Safely apply repo configuration into live local REAPER."""
    plat = get_current_platform()
    if not plat:
        print(f"{RED}Unsupported OS for live apply.{RESET}")
        return 1

    if plat == "macos":
        script = ROOT / "platforms/macos/Apply-configuration.command"
        print(f"{CYAN}Executing {script}...{RESET}")
        result = subprocess.run(["bash", str(script)], cwd=script.parent)
        return result.returncode
    elif plat == "windows":
        script = ROOT / "platforms/windows/02-APPLY-CONFIGURATION.cmd"
        result = subprocess.run([str(script)], shell=True)
        return result.returncode
    return 1

def cmd_install_hook(_args):
    """Install git pre-commit hook to safeguard configuration integrity."""
    hook_dir = ROOT / ".githooks"
    hook_dir.mkdir(exist_ok=True)
    hook_file = hook_dir / "pre-commit"

    hook_content = """#!/bin/bash
set -e
echo "Running pre-commit verification..."
# 1. Check for personal user path leaks
if git diff --cached --name-only | grep -E '\\.(ini|json|txt|md)$' | xargs grep -E '/Users/[a-zA-Z0-9_-]+' 2>/dev/null; then
  echo "ERROR: Personal path leak (/Users/username) detected in staged files!"
  exit 1
fi
# 2. Check for license files
if git diff --cached --name-only | grep -E 'reaper-(license|reginfo)' 2>/dev/null; then
  echo "ERROR: Attempting to commit REAPER license/registration file!"
  exit 1
fi
# 3. Run verification suite
python3 scripts/verify.py
echo "✓ Pre-commit checks passed."
"""
    hook_file.write_text(hook_content)
    hook_file.chmod(0o755)

    subprocess.run(["git", "config", "core.hooksPath", ".githooks"], check=True)
    print(f"{GREEN}✓ Git pre-commit hook installed and configured (.githooks/pre-commit).{RESET}")
    return 0

def main():
    parser = argparse.ArgumentParser(
        description="REAPER Config Developer Tool (DX CLI)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # test
    sub.add_parser("test", help="Run test and integrity verification suite")

    # diff
    sub.add_parser("diff", help="Diff tracked settings against local live REAPER")

    # pull
    sub.add_parser("pull", help="Import & sanitize settings from live REAPER into repo")

    # apply
    sub.add_parser("apply", help="Apply repo settings to local live REAPER with backup")

    # build
    p_build = sub.add_parser("build", help="Build distribution zip packages locally")
    p_build.add_argument("platform", choices=["windows", "macos", "all"], default="all", nargs="?")
    p_build.add_argument("--offline", action="store_true", help="Include REAPER installer")

    # clean
    sub.add_parser("clean", help="Clean dist/ and cached artifacts")

    # install-hook
    sub.add_parser("install-hook", help="Install git pre-commit hook")

    args = parser.parse_args()
    dispatch = {
        "test": cmd_test,
        "diff": cmd_diff,
        "pull": cmd_pull,
        "apply": cmd_apply,
        "build": cmd_build,
        "clean": cmd_clean,
        "install-hook": cmd_install_hook,
    }
    sys.exit(dispatch[args.command](args))

if __name__ == "__main__":
    main()
