#!/usr/bin/env python3
"""Build isolated Windows/macOS handoff folders from the tracked configuration."""
from pathlib import Path
import argparse, hashlib, json, shutil, urllib.request, zipfile
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('platform',choices=['windows','macos','all'])
parser.add_argument('--offline',action='store_true',help='Include the REAPER installer too')
parser.add_argument('--download',action='store_true',help='Fetch missing pinned official installers')
args=parser.parse_args()
lock=json.loads((ROOT/'dependencies.lock.json').read_text())
for platform in (['windows','macos'] if args.platform=='all' else [args.platform]):
    dependencies=[x for x in lock['files'] if x['platform']==platform and (args.offline or not x['name'].startswith('REAPER-'))]
    for dep in dependencies:
        local=ROOT/'downloads'/dep['name']
        if not local.exists() and args.download:
            local.parent.mkdir(exist_ok=True)
            with urllib.request.urlopen(dep['url']) as response:local.write_bytes(response.read())
        if not local.exists():raise SystemExit(f'Missing {local}; rerun with --download')
        if hashlib.sha256(local.read_bytes()).hexdigest()!=dep['sha256']:raise SystemExit(f'Hash mismatch: {local}')
    dest=ROOT/'dist'/f'REAPER-Reapertips-{platform}'
    if dest.exists():raise SystemExit(f'{dest} already exists. Move it aside before rebuilding.')
    dest.mkdir(parents=True)
    shutil.copytree(ROOT/'common',dest/'Configuracion')
    for item in (ROOT/'platforms'/platform).iterdir():
        if item.is_dir():shutil.copytree(item,dest/'Configuracion'/item.name,dirs_exist_ok=True)
        elif item.suffix=='.ini':shutil.copy2(item,dest/'Configuracion'/item.name)
        else:shutil.copy2(item,dest/item.name)
    shutil.copytree(ROOT/'fonts',dest/'Fuentes')
    (dest/'Instaladores').mkdir()
    for dep in dependencies:shutil.copy2(ROOT/'downloads'/dep['name'],dest/'Instaladores'/dep['name'])
    shutil.copy2(ROOT/'dependencies.lock.json',dest/'dependencies.lock.json')
    shutil.copy2(ROOT/'docs/COMPATIBILITY.md',dest/'COMPATIBILITY.md')
    files=sorted(p for p in dest.rglob('*') if p.is_file())
    manifest=[{'path':p.relative_to(dest).as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
    if platform=='windows':(dest/'SHA256.json').write_text(json.dumps(manifest,indent=2))
    else:(dest/'SHA256SUMS').write_text(''.join(f"{p['sha256']}  {p['path']}\n" for p in manifest))
    archive=dest.with_suffix('.zip')
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(dest.rglob('*')):
            if p.is_file():z.write(p,p.relative_to(dest.parent))
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:raise SystemExit('Corrupt archive')
    print(f'Built and verified {archive} ({archive.stat().st_size/1024/1024:.1f} MiB)')
