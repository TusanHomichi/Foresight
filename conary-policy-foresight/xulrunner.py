#
# Copyright (c) 2007 rPath, Inc.
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

from conary.build import policy

class SynthesizeXulRunnerRequires(policy.DestdirPolicy):
    # Cannot be a PackagePolicy because that is a subsequent
    # bucket that runs after Requires
    requires = (
        ('Requires', policy.REQUIRED_SUBSEQUENT),
    )
    processUnmodified = False

    def test(self):
        return 'xulrunner:devel' in self.recipe._getTransitiveBuildRequiresNames()

    def do(self):
        self.recipe.Requires('soname: %(libdir)s/xulrunner/libxul.so',
                             '%(bindir)s/', '%(libdir)s/')
