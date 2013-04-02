"""
Usage: python setup.py py2app
"""

from setuptools import setup

APP = ['pbxforwarderservice.py']
DATA_FILES = []
OPTIONS = {
    'argv_emulation': True,
    'iconfile': 'PBXForwarderService.icns',
    'plist': {
        'CFBundleName': 'PBXForwarderService',
        'CFBundleShortVersionString': '1.0.0',
        'CFBundleGetInfoString': 'PBXForwarderService 1.0.0',
        'CFBundleExecutable': 'PBXForwarderService',
        'CFBundleIdentifier': 'mx.menta.pbx-forwarder-service',
        'CFBundleIconFile': 'PBXForwarderService.icns'
    }
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app',],
)
