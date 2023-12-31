# Xfs font server configuration file
#
# Wed Feb  7 17:41:22 2001  Mike Fabian  <mfabian@suse.de>

# Xfs is the X Window System font server.  It supplies fonts to X Window
# System display servers.
# 
# This font server works for CID-keyed fonts and TrueType fonts as well.
# 
# For TrueType fonts it uses the same syntax in the fonts.dir files as
# the "freetype" modul, it does *not* understand the TTCap syntax
# extensions to fonts.dir used by the "xtt" module.
# 
# To use this fontserver, add
#
#     FontPath   "unix/:7100"
# 
# into the Section "Files" of /etc/X11/xorg.conf, above all other
# FontPath entries. You may also remove or comment out all other
# FontPath entries if you want to use all fonts via the Fontserver
#
# Note that using this fontserver may be a security risk. Don't
# use it on systems aiming for maximum security.
# 
# It may also cause stability problems for the X-Window system.
# If you encounter frequent crashes, stop using it. 

# if you omit "no-listen = tcp" you can use xfs over the network
# if you add entries like
#     FontPath   "tcp/hostname:7100"
# into /etc/X11/xorg.conf. Increases the security risk!

no-listen = tcp
port = 7100
client-limit = 10
clone-self = on
use-syslog = on
deferglyphs = 16

catalogue = /usr/share/fonts/misc:unscaled,
	    /usr/share/fonts/75dpi:unscaled,
	    /usr/share/fonts/100dpi:unscaled,
	    /usr/share/fonts/japanese:unscaled,
	    /usr/share/fonts/baekmuk:unscaled,
	    /usr/share/fonts/Type1,
	    /usr/share/fonts/URW,
	    /usr/share/fonts/Speedo,
	    /usr/share/fonts/CID,
	    /usr/share/fonts/PEX,
	    /usr/share/fonts/cyrillic,
	    /usr/share/fonts/latin2/misc,
	    /usr/share/fonts/latin2/75dpi,
	    /usr/share/fonts/latin2/100dpi,
	    /usr/share/fonts/latin2/Type1,
	    /usr/share/fonts/latin7/75dpi,
	    /usr/share/fonts/kwintv,
	    /usr/share/fonts/truetype,
	    /usr/share/fonts/uni,
	    /usr/share/fonts/ucs/misc,
	    /usr/share/fonts/ucs/75dpi,
	    /usr/share/fonts/ucs/100dpi,
	    /usr/share/fonts/hellas/misc,
	    /usr/share/fonts/hellas/75dpi,
	    /usr/share/fonts/hellas/100dpi,
	    /usr/share/fonts/hellas/Type1

# in decipoints
default-point-size = 120
default-resolutions = 75,75,100,100

# font cache control, specified in KB
#cache-hi-mark = 2048
#cache-low-mark = 1433
cache-balance = 70
