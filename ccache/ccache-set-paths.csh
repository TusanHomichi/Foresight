# Use ccache by default.  Users who don't want that can set the CCACHE_DISABLE
# environment variable in their personal profile.

if ( "$path" !~ *%(libdir)s/ccache* ) then
    set path = ( %(libdir)s/ccache $path )
endif

# If %(localstatedir)s/cache/%(name)s is writable, use a shared cache there.  Users who don't
# want that even if they have that write permission can set the CCACHE_DIR
# and unset the CCACHE_UMASK environment variables in their personal profile.

if ( ! $?CCACHE_DIR && -w %(localstatedir)s/cache/%(name)s && -d %(localstatedir)s/cache/%(name)s ) then
    setenv CCACHE_DIR %(localstatedir)s/cache/%(name)s
    setenv CCACHE_UMASK 002
    unsetenv CCACHE_HARDLINK
endif
