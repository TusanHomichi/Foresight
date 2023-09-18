#!/usr/bin/python
import os
import shutil
import sys
args = dict(arg.split('=') for arg in sys.argv[1:])
def install(src, dst):
    try: os.makedirs(os.path.dirname(dst))
    except: pass
    try: shutil.copy(src, dst)
    except: print 'Cannot (over)write', dst
for root, dirs, files in os.walk('.'):
    for file in files:
        filepath = '%s/%s' % (root, file)
        fileext = file.split('.')[-1]
	if fileext in ['cpp', 'o', 'Makefile', 'head', 'tail', 'c', 'mak']: continue
        elif file.startswith('config.'): continue
        elif file in ['win32config.Borland', 'genWindowsMakefiles.cmd',
                    'genMakefiles', 'win32config', 'genWindowsMakefiles',
                    'configure', 'fix-makefile', 'DynamicRTSPServer.hh.new' ]:
            continue
        elif fileext in ['hh', 'h']:
            if '/include/' in filepath:
                install(filepath, '%(DESTDIR)s/%(includedir)s/' % args + filepath.replace('/include/', '/'))
            else: continue
        elif fileext == 'a':
            install(filepath, '%(DESTDIR)s/%(libdir)s/' % args + file)
        elif file in ['COPYING', 'README']:
            install(filepath, '%(DESTDIR)s/%(thisdocdir)s/' % args + file)
        elif fileext in ['sdp']:
            install(filepath, '%(DESTDIR)s/%(datadir)s/live555/sdp/' % args + file)
        elif os.stat(filepath).st_mode & 0755 == 0755:
            install(filepath, '%(DESTDIR)s/%(bindir)s/' % args + file)
        else: Exception(filepath)
