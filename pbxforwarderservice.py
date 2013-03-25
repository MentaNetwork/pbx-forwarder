#!/usr/bin/python
# encoding:utf-8
import os
import re
import logging
from time import sleep
import signal
from urllib import urlencode
from urllib2 import Request, urlopen


PREF_PANE_APP_ID = 'mx.menta.pbx-forwarder-prefpane'
PBX_BASE_URL = 'http://pbx.menta/'
PBX_LOGIN_URL = PBX_BASE_URL + 'x.php'
PBX_FORWARDING_URL = PBX_BASE_URL + 'x.php'

LOG_FILE = '/tmp/pbx-forwarder-app.log'

logging.basicConfig(filename=LOG_FILE, level=logging.DEBUG)
log = logging.getLogger('PBXFwdr')


def get_request(url, data=None, headers=None):
    is_dict = lambda d: type(d) is dict
    url += '?' + (urlencode(data) if is_dict(data) else data) if data else ''
    return urlopen(Request(url=url, headers=headers or {})).read()

def post_request(url, data=None, headers=None):
    data = (urlencode(data) if type(data) is dict else data) if data else ''
    return urlopen(Request(url=url, data=data, headers=headers or {})).read()

def get_preferences():
    plist_file = '~/Library/Preferences/%s.plist' % PREF_PANE_APP_ID
    log.debug('Retrieving preferences from file %s' % plist_file)
    raw_prefs = os.popen('defaults read %s' % plist_file).read()
    return dict(re.findall(r'"([^"]+)" = (.+);', raw_prefs))

def remove_forwarder():
    log.info('Removing forwarder')
    log.info('OK')

def add_forwarder():
    log.info('Adding forwarder')
    log.info('OK')

def signal_handler(signum, frame):
    if signum != signal.SIGTERM:
        log.debug('Signal %s - aint nobody got time fo dat')
        return

    try:
        add_forwarder()
        exit()
    except Exception, e:
        error = 'Could not add the forwarder due to: %s' % e
        log.critical(error)
        display_error_alert(error)
    
def display_error_alert(error):
    os.popen("""osascript <<-EOF
        tell application "System Events"
            activate
            display dialog "PBXForwarderError:\n\n%s" buttons {"OK"} with icon 0
        end tell
    EOF""" % error)

def main():
    
    log.info('Starting application with: %s' % get_preferences())

    remove_forwarder()

    log.debug('Going to sleep waiting for SIGTERM')
    for i in [x for x in dir(signal) if x.startswith('SIG')]:
        try:
            signum = getattr(signal, i)
            signal.signal(signum, signal_handler)
        except (RuntimeError, ValueError), m:
            log.debug('Skipping signal %s' % i)
    signal.signal(signal.SIG_IGN, signal_handler)

    while True:
        sleep(1)


if __name__ == '__main__':
    try:
        main()
    except Exception, e:
        log.critical(e)
        exit()
