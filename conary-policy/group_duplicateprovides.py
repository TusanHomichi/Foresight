#
# Copyright (c) 2012 The Foresight Linux Project
#
# This file is distributed under the terms of the MIT License.
# A copy is available at http://www.rpath.com/permanent/mit-license.html
#

from conary import trove

from conary.deps import deps

from conary.build import policy

# Limit to only the dep classes which matter and are not sufficiently
# enforced elsewhere. (Files and trove names are handled elsewhere.)
uniqueDepClasses = (
    deps.SonameDependencies,
    deps.PythonDependencies,
    deps.PerlDependencies,
    deps.CILDependencies,
)

class DuplicateProvides(policy.GroupEnforcementPolicy):
    """
    NAME
    ====

    B{C{r.DuplicateProvides()}} - Prevents multiple troves providing
    the same dependency from being cooked into a group.

    SYNOPSIS
    ========

    C{r.DuplicateProvides([I{exceptions=filterexp}])}

    DESCRIPTION
    ===========

    The C{r.DuplicateProvides} policy enforces that two troves with different
    names may not provide the same dependency.

    """
    def do(self):
        seen = {}
        found = False
        # providesMap[depClass][depName]: [trvName, trvName]
        providesMap = dict((t, {}) for t in uniqueDepClasses)
        for grp in self.recipe.troveMap.values():
            trvCache = self.recipe.groups[grp.getName()].cache
            for trv in (x[1] for x in trvCache.cache.values()):
                trvName = trv.getName()
                if trove.troveIsCollection(trvName) and self._pathAllowed(trvName):
                    # only collections will have dependencies we care about
                    if trv not in seen:
                        provides = trv.getProvides()
                        for depClass in uniqueDepClasses:
                            for dep in provides.iterDepsByClass(depClass):
                                providesMap[depClass].setdefault(
                                    dep.getName()[0], []).append(trvName)
                                found = True
                    seen[trv] = True
        if found:
            for depClass in uniqueDepClasses:
                for depName in providesMap[depClass]:
                    if len(providesMap[depClass][depName]) > 1:
                        self.error('Dependency "%s: %s" has duplicate provides: %s',
                                   depClass.tagName, depName,
                                   ' '.join(providesMap[depClass][depName]))
