import logging
from conary.lib import log
from conary.server import wsgi_hooks

def application(environ, start_response):
        log.setupLogging(consoleLevel=logging.INFO, consoleFormat='apache_short')
        return wsgi_hooks.makeApp(dict(
			# comment if _not_ a proxy
			# mount_point='',
            ))(environ, start_response)

