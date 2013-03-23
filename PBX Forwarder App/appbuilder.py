from os import mkdir, path, chmod, stat
from stat import S_IXUSR, S_IXGRP, S_IXOTH

app_path = 'PBXForwarder.app'
contents_path = path.join(app_path, 'Contents')
macos_path = path.join(contents_path, 'MacOS')
script_name = 'main.py'
version = '1.0.0'
bundle_name = 'PBXForwarder'
bundle_identifier = 'mx.menta.pbx-forwarder-app'

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
    make_dir(app_path)
    make_dir(contents_path)
    make_dir(macos_path)
    info_plist_vars = (bundle_name + ' ' + version,
                       bundle_identifier,
                       bundle_name,
                       bundle_name + ' ' + version, version)
    info_plist_contents = open('Info.plist.tpl').read() % info_plist_vars
    write_file(contents_path, 'Info.plist', info_plist_contents)
    write_file(contents_path, 'PkgInfo', 'APPL????')
    write_file(macos_path, script_name, open(script_name).read())
    old_mode = stat(path.join(macos_path, script_name)).st_mode
    new_mode = old_mode | S_IXUSR | S_IXGRP | S_IXOTH
    chmod(path.join(macos_path, script_name), new_mode)
    print 'App built in %s' % app_path

if __name__ == '__main__':
    main()
    