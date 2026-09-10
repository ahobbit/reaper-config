#!/usr/bin/env python3
"""Validate the source profiles and generated handoff manifests without installing."""
from pathlib import Path
import configparser, hashlib, json, re, subprocess, zipfile
r=Path(__file__).resolve().parents[1]
lock=json.loads((r/'dependencies.lock.json').read_text())
for platform in ['windows','macos']:
    profile=r/'platforms'/platform
    cfg=configparser.ConfigParser(interpolation=None);cfg.read(profile/'reaper.ini')
    for key,value in {'autosaveint':'1','workbufmsex':'600','prebufperb':'50','renderbsnew':'1024','vuupdfreq':'30','tcpalign':'787'}.items():assert cfg['reaper'][key]==value,(platform,key)
    if platform=='macos':assert cfg['reaper']['mac_dark_mode']=='1'
    assert cfg['midiedit']['default_colormap']=='@@RESOURCE@@/Data/colormaps/Cubase.png',(platform,'default_colormap')
    assert not any(k.startswith(('coreaudio','midiins')) for k in cfg['reaper'])
    assert len(list((profile/'ColorSets/Reapertips').glob('*.SWSColor')))==13
    for p in profile.rglob('*.ini'):assert '/Users/yon/' not in p.read_text(),p
    dest=r/'dist'/f'REAPER-Reapertips-{platform}'
    if platform=='windows':
        for file in dest.rglob('*'):
            assert not re.search(r'[<>:"\\|?*]',file.name),file
            assert not file.name.endswith(('.', ' ')),file
        entries=json.loads((dest/'SHA256.json').read_text())
    else:entries=[dict(zip(['sha256','path'],line.split('  ',1))) for line in (dest/'SHA256SUMS').read_text().splitlines()]
    for entry in entries:assert hashlib.sha256((dest/entry['path']).read_bytes()).hexdigest()==entry['sha256'],entry['path']
    with zipfile.ZipFile(dest.with_suffix('.zip')) as z:assert z.testzip() is None
    assert not list((dest/'Installers').glob('REAPER-*')),'Expected lightweight packages'
    print(platform, len(entries),'manifest entries verified')
menu=configparser.ConfigParser(interpolation=None);menu.read(r/'common/reaper-menu.ini');kb=(r/'common/reaper-kb.ini').read_text()
for key,value in menu['Floating toolbar 2'].items():
    if key.startswith('icon_'):assert (r/'common/Data/toolbar_icons'/value).exists(),value
    if key.startswith('item_') and re.match(r'^_[a-f0-9]{32} ',value):assert value.split()[0][1:] in kb
win=json.loads((r/'platforms/windows/windows-colors.json').read_text())
mac=configparser.ConfigParser();mac.read(r/'platforms/macos/ColorSets/Reapertips/Mac-Reapertips.SWSColor')
for i,w in enumerate(win,1):
    v=int(mac['SWS Color'][f'custcolor{i}'],0);assert w==((v&255)<<16 | v&65280 | v>>16&255)
for p in [r/'platforms/macos/Prepare-REAPER.sh',r/'platforms/macos/Apply-configuration.command']:subprocess.run(['bash','-n',str(p)],check=True)
helper=(r/'platforms/macos/Prepare-REAPER.sh').read_text()
macdep=next(x for x in lock['files'] if x['name'].startswith('REAPER-') and x['platform']=='macos')
assert f"required='{lock['versions']['reaper']}'" in helper
assert macdep['url'] in helper and macdep['name'] in helper
assert (r/'platforms/macos/REAPER-macos.sha256').read_text().strip()==macdep['sha256']
# Execute the actual shell comparator, including the macOS version suffix shape.
func=helper.split('version_at_least() {',1)[1].split('\n}',1)[0]
for version,expected in [('7.78',1),('7.79',0),('7.79.0',0),('7.80',0),('8.0',0),('6.99',1)]:
    result=subprocess.run(['bash','-c','version_at_least() {'+func+'\n}\nversion_at_least "$1" "$2"','test',version,'7.79'])
    assert result.returncode==expected,(version,result.returncode)
for p in (r/'common').rglob('*.ini'):assert '/Users/yon/' not in p.read_text(),p
for p in (r/'common').rglob('*.RPP'):assert '/Users/' not in p.read_text(),p
assert (r/'common/Data/Metronome Sounds/DAWs/Pro Tools/Marimba/Metronome.wav').exists()
assert (r/'common/Data/Metronome Sounds/DAWs/Pro Tools/Marimba/MetronomeUp.wav').exists()
assert len(list((r/'common/Data/colormaps').glob('*.png')))==11
assert (r/'common/Data/colormaps/Cubase.png').exists()
assert (r/'common/Data/toolbar_icons/RT_Blue_toolbar_add.png').exists()
assert (r/'common/Data/toolbar_icons/150/RT_Blue_toolbar_add.png').exists()
assert (r/'common/Data/toolbar_icons/200/RT_Blue_toolbar_add.png').exists()
assert len(list((r/'common/Data/toolbar_icons').glob('RT_*_toolbar_*.png'))) >= 6000
assert (r/'common/Data/Borders/!Preview_Borders.png').exists()
dark_dep=next(x for x in lock['files'] if x['name']=='reaper_DarkMode_x64.dll' and x['platform']=='windows')
assert dark_dep['sha256']=='d21a9a8a4b1ed5f138afb2d6881a25db128f835d3fffeb9e2ec2564d8863a636'
assert (r/'common/Scripts/ReaperDarkMode/DarkModeConfig.lua').exists()
assert 'reaper_DarkMode_x64.dll' in (r/'platforms/windows/Apply-configuration.ps1').read_text()
reapack_cfg=configparser.ConfigParser(interpolation=None);reapack_cfg.read(r/'common/reapack.ini')
assert any('FeedTheCat Tools' in v for v in reapack_cfg['remotes'].values())
update_script=(r/'common/Scripts/Various/REAPER Update Utility.lua')
assert update_script.exists()
assert hashlib.sha256(update_script.read_bytes()).hexdigest()=='cee7143cf14112fad369ecf27da22227e2bdaaf87d5928c3035901f9a509258f'
assert 'Script: REAPER Update Utility.lua' in (r/'common/reaper-kb.ini').read_text()
print('PASS: profiles, palette byte order, references, shell syntax, version comparator, dependency consistency, metronome sounds, colormaps, essential icons, dark mode, update utility, manifests and archives.')
