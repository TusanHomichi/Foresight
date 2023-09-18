#
# Copyright (c) 2007 rPath, Inc.
# All rights reserved
#

import sys
import os.path

from rhpl.translate import _

from conary.lib import util
from conary.lib.sha1helper import sha1ToString

import logging
from constants import *
from flags import flags
from tarextract import *
from tarcallbacks import ProgressCallback
from installmethod import FileCopyException
from rpathbackendbase import rPathBackendBase
from product import productPackagePath, productPath

log = logging.getLogger('anaconda')

class TarBackend(rPathBackendBase):
    def __init__(self, method, instPath):
        rPathBackendBase.__init__(self, method, instPath)

        self.supportsUpgrades = False
        self.supportsPackageSelection = False
        self.manifests = [('tblist', False)]

    def addManifest(self, name, optional=False):
        self.manifests.append((name, optional))

    def doInitialSetup(self, anaconda):
        rPathBackendBase.doInitialSetup(self, anaconda)
        self.comps = TarComps(self.method, anaconda.intf, self.manifests)

    def doRepoSetup(self, anaconda):
        if anaconda.dir == DISPATCH_BACK:
            return

        # Don't reprocess package data.
        if self.comps.chunks:
            return

        self.comps.processPackageData()

    def doInstall(self, anaconda):
        if flags.test:
            return

        totalSize = 0
        for chunk in self.comps.chunks:
            totalSize += chunk.size

        instProgress = ProgressCallback(anaconda, len(self.comps), totalSize)

        util.settempdir(self.instPath + '/var/tmp')
        te = TarExtractor(self.instPath, progress=instProgress)

        for chunk in self.comps.chunks:
            # Try to retreive tarball chunk.
            while True:
                try:
                    # Make sure to use the correct disc.
                    self.method.switchMedia(chunk.disc)
                    fn = self.method.getFilename('%s/%s' %
                            (productPackagePath, chunk.fn))
                    break
                except FileCopyException:
                    self.method.unmountCD()
                    anaconda.intf.messageWindow(_("Error"),
                        _("The file %s cannot be opened. This is due "
                          "to a missing or corrupt file.  "
                          "If you are installing from CD media this usually "
                          "means the CD media is corrupt, or the CD drive is "
                          "unable to read the media.\n\n"
                          "Press <return> to try again.") % chunk.fn)

            log.info('installing %s' % chunk.fn)

            # Extract chunk
            sha1sum = te.extractFile(fn)

            # Verify tar chunk
            if chunk.sha1sum and chunk.sha1sum != sha1ToString(sha1sum):
                log.critical('file failed to verify: %s' % chunk.fn)
                log.critical('expected %s, but got %s'
                    % (chunk.sha1sum, sha1ToString(sha1sum)))
                self.method.unmountCD()
                rc = anaconda.intf.messageWindow(_('Error'),
                        _("The file %s cannot be verified. This is due "
                          "to a missing or corrupt file.  "
                          "If you are installing from CD media this usually "
                          "means the CD media is corrupt, or the CD drive is "
                          "unable to read the media.") % chunk.fn,
                        type='custom',
                        custom_icon='error',
                        custom_buttons=[_('_Exit'), ])
                if not rc:
                    if flags.rootpath:
                        msg =  _("The installer will now exit...")
                        buttons = [_("_Exit installer")]
                    else:
                        msg =  _("Your system will now be rebooted...")
                        buttons = [_("_Reboot")]

                    anaconda.intf.messageWindow(_("Exiting"),
                        msg,
                        type="custom",
                        custom_icon="warning",
                        custom_buttons=buttons)
                    sys.exit(1)
            elif chunk.sha1sum:
                log.info('verified %s' % chunk.fn)


        self._unlinkFilename(fn)

        te.done()
        anaconda.id.instProgress = None
        self.method.filesDone()

    def doPostInstall(self, anaconda):
        rPathBackendBase.doPostInstall(self, anaconda)

        # start in run level 5 if xdm is installed
        if os.path.exists(self.instPath + '/usr/bin/xdm'):
            anaconda.id.desktop.setDefaultRunLevel(5)

        if os.path.exists(self.instPath + '/boot/grub/device.map'):
            os.unlink(self.instPath + '/boot/grub/device.map')

        if os.path.exists(self.instPath + '/etc/bootloader.d/root.conf'):
            os.unlink(self.instPath + '/etc/bootloader.d/root.conf')

        # Sanity check the bootloader selection
        hasGrub = os.access(self.instPath + '/sbin/grub', os.X_OK)
        if os.access(self.instPath + '/sbin/bootman', os.X_OK):
            hasExtLinux = os.access(self.instPath + '/sbin/extlinux', os.X_OK)
            curBL = anaconda.id.bootloader.getBootLoader()

            if hasExtLinux and (curBL == BL_EXTLINUX or not hasGrub):
                anaconda.id.bootloader.setBootLoader(BL_EXTLINUX)
            elif hasGrub:
                anaconda.id.bootloader.setBootLoader(BL_GRUB)
        else:
            assert hasGrub
            anaconda.id.bootloader.setBootLoader(BL_GRUB_OLD)

        # Write a system model if one does not exist
        if not os.path.exists(self.instPath + '/etc/conary/system-model'):
            from conary.deps import deps
            from conary import conarycfg, conaryclient, trovetup

            sysmodel = open(self.instPath + '/etc/conary/system-model', 'w')
            cfg = conarycfg.ConaryConfiguration()
            cfg.initializeFlavors()
            cfg.root = self.instPath
            client = conaryclient.ConaryClient(cfg)
            n, v, f = client.getUpdateItemList()[0]
            biarch = deps.parseFlavor('is: x86(i486,i586,i686,sse,sse2) x86_64')
            groupWorld = 'group-world=%s/%s' % (v.trailingLabel(), v.trailingRevision())
            sysmodel.write("search '%s[is: x86]'\n" % groupWorld)
            if f.satisfies(biarch):
                sysmodel.write("search '%s[%s]'\n" % (groupWorld, f.intersection(biarch)))
            sysmodel.write("install %s\n" % n)
            sysmodel.close()

    def getRequiredMedia(self):
        return self.comps.getRequiredMedia()


class TarComps(object):
    def __init__(self, method, intf, manifests):
        self.method = method
        self.intf = intf
        self.manifests = list(manifests)
        self.chunks = []

    def __len__(self):
        return len(self.chunks)

    def _getFiles(self):
        log.info('copying needed files')
        # If using a cd imstall make sure we are on disc 1
        self.method.switchMedia(1)

        fullPaths = []
        for name, optional in self.manifests:
            relPath = productPath + '/base/' + name
            fullPath = None
            try:
                fullPath = self.method.getFilename(relPath)
            except FileCopyException:
                log.error("Error copying manifest file %s", relPath)

            if fullPath and not os.path.exists(fullPath):
                log.error("Manifest file %s is missing", relPath)
                fullPath = None

            if fullPath:
                fullPaths.append(fullPath)
            elif not optional:
                raise FileCopyException

        self.manifests = fullPaths

    def _parseTbList(self):
        log.info('parsing tblist')
        for path in self.manifests:
            for i, line in enumerate(open(path).readlines()):
                line = line.strip()
                parts = line.split()
                # Allow for lines with more elements, ignore extra elements.
                if len(parts) >= 4:
                    chunkfile, size, disc, sha1sum = parts[:4]
                elif len(parts) == 3:
                    chunkfile, size, disc = parts
                    sha1sum = None
                else:
                    log.warn('invalid line in tblist: %s: %s' % (i, line))
                    continue

                size = long(size)
                disc = int(disc)

                chunk = TarChunk(chunkfile, size, disc, sha1sum)
                if chunk not in self.chunks:
                    self.chunks.append(chunk)

    def processPackageData(self):
        title = _('Parsing Package Data')

        win = self.intf.waitWindow(title,
                    _('Copying needed files...'))

        self._getFiles()

        win.pop()
        win = self.intf.waitWindow(title,
                    _('Parsing File List...'))

        self._parseTbList()

        win.pop()

    def getRequiredMedia(self):
        discs = []
        for chunk in self.chunks:
            if chunk.disc not in discs:
                discs.append(chunk.disc)
        return discs

    def cleanupFiles(self):
        self.backend._unlinkFilename(self.tbListFile)


class TarChunk(object):
    __slots__ = ('fn', 'size', 'disc', 'sha1sum')

    def __init__(self, fn, size, disc, sha1sum):
        self.fn = fn
        self.size = size
        self.disc = disc
        self.sha1sum = sha1sum

    def __cmp__(self, other):
        if self.fn == other.fn:
            if not self.sha1sum and other.sha1sum:
                self.sha1sum = other.sha1sum
            elif not other.sha1sum and self.sha1sum:
                other.sha1sum = self.sha1sum
            return 0
        elif self.fn > other.fn:
            return 1
        elif self.fn < other.fn:
            return -1

    def __repr__(self):
        return ('<TarChunk(fn=%s, size=%s, disc=%s, sha1sum=%s)>' 
                % (self.fn, self.size, self.disc, self.sha1sum))
