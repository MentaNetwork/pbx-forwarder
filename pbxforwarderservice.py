#!/usr/bin/python
# encoding:utf-8
import os
import re
import sys
import logging
import logging.handlers
from time import sleep
import signal
from urllib import urlencode
from urllib2 import Request, urlopen
import requests


class Log(object):
    """Custom log to be friendly with OSX's syslog"""

    app = 'PBXForwarderService'
    
    def __init__(self):
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)
        handler = logging.handlers.SysLogHandler(address='/var/run/syslog')
        self.log.addHandler(handler)
    
    def __getattr__(self, name):
        levels = ['info', 'debug', 'warning', 'error', 'critical', 'log', 'exception']
        if name not in levels:
            self.warning('Log level %s does not exist, using info' % name)
            name = 'info'
        return lambda msg: getattr(self.log, name)('%s: %s' % (self.app, msg))
        

class Preferences(dict):
    
    prefix = 'mx.menta.pbx.'

    def __init__(self, *args, **kwargs):
        # TODO: remove unnecessary, unprefixed keys
        super(Preferences, self).__init__(*args, **kwargs)

    def __getattr__(self, name):
        return dict.__getattr__(self, self.prefix + name)

    def __getitem__(self, name):
        return dict.__getitem__(self, self.prefix + name)


class ServiceException(Exception):
    pass


class Service(object):

    def __init__(self):
        plist_file = '~/Library/Preferences/com.apple.systempreferences.plist'
        
        self.log = Log()
        
        self.log.debug('Retrieving preferences from file %s' % plist_file)
        raw_prefs = os.popen('defaults read %s' % plist_file).read()
        
        self.preferences = Preferences(re.findall(r'"([^"]+)" = (.+);', raw_prefs),foo='bar')
        self.session = requests.Session()
    
    def main(self):
        self.log.info('Starting application with: %s' % self.preferences)
        
        self.remove_forwarder()

        self.log.debug('Going to sleep waiting for SIGTERM')
        for i in [x for x in dir(signal) if x.startswith('SIG')]:
            try:
                signum = getattr(signal, i)
                signal.signal(signum, self.handle_signal)
            except (RuntimeError, ValueError), m:
                self.log.debug('Skipping signal %s' % i)
        signal.signal(signal.SIG_IGN, self.handle_signal)

        while True:
            sleep(1)

    def handle_signal(self, signum, frame):
        if signum != signal.SIGTERM:
            self.log.debug('Signal %s - aint nobody got time fo dat')
            return
        
        try:
            self.add_forwarder()
            sys.exit()
        except ServiceException, e:
            error = 'Could not add the forwarder due to: %s' % e
            self.log.critical(error)
            self.display_error_alert(error)

    def display_error_alert(self, error):
        os.popen("""osascript <<-EOF
            tell application "System Events"
                activate
                display dialog "PBXForwarderServiceError:\n\n%s" buttons {"OK"} with icon 0
            end tell
        EOF""" % error)

    def login(self):
        login_data = {'extension': self.preferences['extension_number'],
                      'password': self.preferences['extension_password'],
                      'Submit.x': '54',
                      'Submit.y': '15',
                      'Submit': 'Log In', 
                      'url': ''}
        response = self.session.post('http://pbx.menta/index2.php', data=login_data, timeout=100)
        # TODO: check response body
        if not response.ok:
            error = 'Login failed'
            self.log.critical(error)
            raise ServiceException(error)

    def add_forwarder(self):
        self.login()

        forwarding_data = {'extension': self.preferences['extension_number'],
                        'number': self.preferences['target_forwarding_number']}
        url = 'http://pbx.menta/userforwardmodify2.php'
        response = self.session.post(url, data=forwarding_data, timeout=100)
        
        # TODO: check response body
        if not response.ok:
            error = 'Forwarding setup failed'
            self.log.critical(error)
            raise ServiceException(error)

    def remove_forwarder(self):
        self.login()

        forwarding_data = {'extension': self.preferences['extension_number'],
                           'Submit': 'Delete'}
        url = 'http://pbx.menta/userforwarddelete2.php'
        response = self.session.post(url, data=forwarding_data, timeout=100)

        # TODO: check response body
        if not response.ok:
            error = 'Forwarding removal failed'
            self.log.critical(error)
            raise ServiceException(error)


if __name__ == '__main__':
    try:
        service = Service()
        service.main()
    except Exception, e:
        log = Log()
        log.critical('Fatal error: %s' % e)
        sys.exit(2)
