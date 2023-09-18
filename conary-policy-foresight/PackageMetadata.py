#
# Copyright (c) 2008-2012 The Foresight Linux Project
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
from metadata import _BaseMetadata

class SetPackageMetadataFromRecipe(policy.DestdirPolicy):
    # Cannot be a PackagePolicy because that is a subsequent
    # bucket that runs after Requires
    requires = (
        ('Requires', policy.REQUIRED_SUBSEQUENT),
    )
    processUnmodified = False

    def do(self):
        if  hasattr(self.recipe, 'packageSummary'):
            if not hasattr(self.recipe, 'packageDescription'):
                self.recipe.packageDescription =  ''
            self.recipe.Description(shortDesc =  self.recipe.packageSummary, longDesc =  self.recipe.packageDescription, macros = True)


class SetupRecipeMetadata(_BaseMetadata):
    """
    NAME
    ====

    B{C{r.SetupRecipeMetadata()}} - Setup metadata for the package

    SYNOPSIS
    ========

    C{r.SetupRecipeMetadata()}

    DESCRIPTION
    ===========

    The C{r.SetupRecipeMetadata()} class adds recipe metadata to trove.

    Metadata should be included as a set of variables in the recipe,
    such as C{r.description}, C{r.long_description}, C{r.url} and
    C{r.categories[]}.
    """
    
    def __init__(self, recipe, *args, **keywords):
        _BaseMetadata.__init__(self, recipe, *args, **keywords)

    def do(self):
        if not hasattr(self.recipe, '_addMetadataItem'):
            # Old Conary
            return
        troveNames = self._getTroveNames()
        
        # Check if macros should be applied (defaults to True)
        if hasattr(self.recipe, 'applyMacrosToMetadata') \
                and not self.recipe.applyMacrosToMetadata:
            applyMacros = False
        else:
            applyMacros = True

        # Check for short description
        if hasattr(self.recipe, 'shortDesc'):
            if applyMacros:
                shortDesc = self.recipe.shortDesc % self.recipe.macros
            else:
                shortDesc = self.recipe.shortDesc
            itemDict = dict(shortDesc = shortDesc)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for long description
        if hasattr(self.recipe, 'longDesc'):
            if applyMacros:
                longDesc = self.recipe.longDesc % self.recipe.macros
            else:
                longDesc = self.recipe.longDesc
            itemDict = dict(longDesc = longDesc)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for url
        if hasattr(self.recipe, 'url'):
            if applyMacros:
                url = self.recipe.url % self.recipe.macros
            else:
                url = self.recipe.url
            itemDict = dict(url = url)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for single category
        if hasattr(self.recipe, 'category'):
            if applyMacros:
                categories = [ self.recipe.category % self.recipe.macros ]
            else:
                categories = [ self.recipe.category ]
            itemDict = dict(categories = categories)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for categories
        if hasattr(self.recipe, 'categories') and \
                type(self.recipe.categories) == type([]) and \
                len(self.recipe.categories) > 0:
            if applyMacros:
                categories = [x % self.recipe.macros for x in self.recipe.categories]
            else:
                categories = self.recipe.categories
            itemDict = dict(categories = categories)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for single license
        if hasattr(self.recipe, 'license'):
            if applyMacros:
                licenses = [ self.recipe.license % self.recipe.macros ]
            else:
                licenses = [ self.recipe.license ]
            itemDict = dict(licenses = licenses)
            self.recipe._addMetadataItem(troveNames, itemDict)

        # Check for licenses
        if hasattr(self.recipe, 'licenses') and \
                type(self.recipe.licenses) == type([]) and \
                len(self.recipe.licenses) > 0:
            if applyMacros:
                licenses = [x % self.recipe.macros for x in self.recipe.licenses]
            else:
                licenses = self.recipe.licenses
            itemDict = dict(licenses = licenses)
            self.recipe._addMetadataItem(troveNames, itemDict)
