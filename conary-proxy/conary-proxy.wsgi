import logging
from conary.lib import log
from conary.server import wsgi_hooks

def application(environ, start_response):
        log.setupLogging(consoleLevel=logging.INFO, consoleFormat='apache_short')
        return wsgi_hooks.makeApp(dict(
			# (2012-12-18 21:23:20) gxti: that same .wsgi file also works for
			# repositories but mount_point should be omitted (default is /conary)
			# (2012-12-18 21:23:37) gxti: proxies need to be at / because the URL
			# path of the destination is used, and it's not always /conary
			#
			# mount_point='',
            ))(environ, start_response)
