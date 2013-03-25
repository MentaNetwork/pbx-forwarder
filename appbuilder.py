from sys import argv
from os import mkdir, path, chmod, stat
from stat import S_IXUSR, S_IXGRP, S_IXOTH

if len(argv) != 3:
    print 'Usage: $ python appbuilder.py sourceapp.py TargetApp.app'
    exit()

script_name = argv[1]
app_name = argv[2]
contents_path = path.join(app_name, 'Contents')
resources_path = path.join(contents_path, 'Resources')
macos_path = path.join(contents_path, 'MacOS')
version = '1.0.0'
bundle_name = app_name.split('.')[0]
bundle_identifier = app_name
icon_name = bundle_name + '.icns'

info_plist_tpl = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>%s</string>
    <key>CFBundleGetInfoString</key>
    <string>%s</string>
    <key>CFBundleIconFile</key>
    <string>%s</string>
    <key>CFBundleIdentifier</key>
    <string>%s</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>%s</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>%s</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>%s</string>
    <key>NSAppleScriptEnabled</key>
    <string>YES</string>
    <key>NSMainNibFile</key>
    <string>MainMenu</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>"""


def make_dir(dir_name):
    try:
        mkdir(dir_name)
    except Exception, e:
        print e

def write_file(base_path, file, contents):
    f = open(path.join(base_path, file), 'w')
    f.write(contents)
    f.close()

def main():
    make_dir(app_name)
    make_dir(contents_path)
    make_dir(resources_path)
    make_dir(macos_path)
    info_plist_vars = (script_name,
                       bundle_name + ' ' + version,
                       icon_name,
                       bundle_identifier,
                       bundle_name,
                       bundle_name + ' ' + version,
                       version)
    info_plist_contents = info_plist_tpl % info_plist_vars
    write_file(contents_path, 'Info.plist', info_plist_contents)
    write_file(contents_path, 'PkgInfo', 'APPL' + bundle_name.upper())
    write_file(macos_path, script_name, open(script_name).read())
    #write_file(app_name, icon_name, open(icon_name).read())
    #write_file(contents_path, icon_name, open(icon_name).read())
    write_file(resources_path, icon_name, open(icon_name).read())
    old_mode = stat(path.join(macos_path, script_name)).st_mode
    new_mode = old_mode | S_IXUSR | S_IXGRP | S_IXOTH
    chmod(path.join(macos_path, script_name), new_mode)
    print 'App built in %s' % app_name

if __name__ == '__main__':
    main()
    