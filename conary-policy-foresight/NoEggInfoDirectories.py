#
# Copyright (c) 2012 The Foresight Linux Project
#
# This program is distributed under the terms of the Common Public License,
# version 1.0. A copy of this license should have been distributed with this
# source file in a file called LICENSE. If it is not present, the license
# is always available at http://www.rpath.com/permanent/licenses/CPL-1.0.
#
# This program is distributed in the hope that it will be useful, but
# without any warranty; without even the implied warranty of merchantability
# or fitness for a particular purpose. See the Common Public License for
# full details.
#

import stat

from conary.build import policy

class NoEggInfoDirectories(policy.DestdirPolicy):
    """
    NAME
    ====

    B{C{r.NoEggInfoDirectories()}} - Prevent inadvertent packaging of .egg-info
    files as directories.

    DESCRIPTION
    ===========

    The C{r.NoEggInfoDirectories()} policy prevents the occasional error
    (due to changes in setuputils) of .egg-info directories being
    packaged, instead of creating .egg-info files.  This error causes
    updates to fail, since Conary does not intrinsically allow directories
    to be replaced with files on an update.

    No exceptions to this policy should be allowed.
    """
    processUnmodified = False
    invariantinclusions = [ (r'%(libdir)s/python.*\.egg-info$', stat.S_IFDIR),
                            ]

    def doFile(self, filename):
        self.error("egg-info %s improperly packaged as directory rather than file" % filename)
