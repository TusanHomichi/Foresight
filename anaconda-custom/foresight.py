#
# Copyright 2007-2008 Elliot Peele <elliot@bentlogic.net>
#

from constants import *
from rhpl.translate import *
from rpathbase import rPathBaseInstallClass

class InstallClass(rPathBaseInstallClass):
    hidden = 0

    id = "foresight"
    name = N_("foresight")
    pixmap = "rpath-color-graphic-only.png"
    description = N_("Foresight Linux install type.")

    sortPriority = 40000
    showLoginChoice = 1

    def setSteps(self, anaconda):
        rPathBaseInstallClass.setSteps(self, anaconda);
        anaconda.dispatch.skipStep("accounts")
        anaconda.dispatch.skipStep("group-selection")
        if anaconda.isKickstart:
            anaconda.dispatch.skipStep("initialuser")

        if anaconda.isKickstart:
           anaconda.dispatch.skipStep("users")
        #anaconda.dispatch.skipStep("postselection")
        #anaconda.dispatch.skipStep("confirminstall")
