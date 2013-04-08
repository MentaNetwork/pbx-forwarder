import re
from fabric.api import local, output
from fabric.utils import abort
from fabric.context_managers import shell_env

output['debug'] = False

config = {
    'PREF_PANE':   'PBXForwarderPrefPane.prefPane',
    'SERVICE_APP': 'PBXForwarderService.app',
    'SERVICE_PY':  'pbxforwarderservice.py',
    'DIST_DIR':    'dist/PBXForwarder',
    'PANES_DIR':   '~/Library/PreferencePanes',
    'DMG_VOLUME':  'PBXForwarder',
    'DMG_SIZE':    3500,
}

def sh(commands, **kwargs):
    kwargs.update(config)
    # environment vars
    env = {}
    # format the commands string with the given kwargs
    try:
        commands = commands.format(**kwargs)
    # if something fails, there's a {var} in commands missing in kwargs
    # or some unescaped braces as in awk's '{print $1}' which must be '{{print $1}}'
    except KeyError, e:
        abort('%s. Missing config var or unescaped literal braces.' % repr(e))
    # remove unnecessary space
    commands = [re.sub(r'\s+', ' ', c.strip()) for c in commands.split('\n')]
    # ignore comments
    commands = [c for c in commands if c and not c.startswith('#')]

    # exec each command using the env vars 
    for command in commands:
        # env var assignment from command substitution with backticks only
        env_variable_assignment = re.match(r'(\w+)=`(.+)`', command)
        if env_variable_assignment:
            env_var, command = env_variable_assignment.groups()
            with shell_env(**env):
                result = local(command, capture=True)
                # save the result in the env var
                env.update(**{env_var: result})
        else:
            with shell_env(**env):
                local(command)

def clean():
    sh("""
    rm -rf {DIST_DIR}
    rm -rf build
    """)

def build():
    clean()
    sh("""
    mkdir -p {DIST_DIR}
    xcodebuild
    python setup.py py2app --dist-dir={DIST_DIR}
    cp -r build/Release/{PREF_PANE} {DIST_DIR}
    cp -r build/Release/{PREF_PANE} {PANES_DIR}
    if [[ -L {DIST_DIR}/Preferencias ]]; \
        then unlink {DIST_DIR}/Preferencias; \
    fi
    if [[ -L {DIST_DIR}/Aplicaciones ]]; \
        then unlink {DIST_DIR}/Aplicaciones; \
    fi
    ln -s /Library/PreferencePanes {DIST_DIR}/Preferencias
    ln -s /Applications {DIST_DIR}/Aplicaciones
    """)

def dist():
    build()
    sh("""
    rm -f pack.temp.dmg
    hdiutil create -srcfolder "{DIST_DIR}" -volname "{DMG_VOLUME}" -fs HFS+ \
        -fsargs "-c c=64,a=16,e=16" -format UDRW -size {DMG_SIZE}k pack.temp.dmg
    DEVICE=`hdiutil attach -readwrite -noverify -noautoopen "pack.temp.dmg" | \
        egrep '^/dev/' | sed 1q | awk '{{print $1}}'`
    echo Device $DEVICE
    mkdir -p /Volumes/{DMG_VOLUME}/.background
    cp dmg.png /Volumes/{DMG_VOLUME}/.background/
    osascript dmg.scpt {DMG_VOLUME} {PREF_PANE} {SERVICE_APP}
    #sudo chmod -Rf go-w /Volumes/{DMG_VOLUME}
    sync
    sync
    hdiutil detach $DEVICE
    hdiutil convert "pack.temp.dmg" -format UDZO -imagekey zlib-level=9 -o "{DMG_VOLUME}.dmg"
    rm -f pack.temp.dmg
    mv {DMG_VOLUME}.dmg dist
    """)

def uninstall():
    sh("""
    rm -rf /Applications/{SERVICE_APP}
    rm -rf {PANES_DIR}/{PREF_PANE}
    """)

def install():
    # the pref pane is installed locally to ~
    uninstall()
    build()
    sh("""
    cp -r {DIST_DIR}/{SERVICE_APP} /Applications
    cp -r {DIST_DIR}/{PREF_PANE} {PANES_DIR}
    """)

