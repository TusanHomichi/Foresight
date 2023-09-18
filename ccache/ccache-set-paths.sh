# Use ccache by default.  Users who don't want that can set the CCACHE_DISABLE
# environment variable in their personal profile.

case ":${PATH:-}:" in
    *:%(libdir)s/ccache:*) ;;
    *) PATH="%(libdir)s/ccache${PATH:+:$PATH}" ;;
esac

# If %(localstatedir)s/cache/%(name)s is writable, use a shared cache there.  Users who don't
# want that even if they have that write permission can set the CCACHE_DIR
# and unset the CCACHE_UMASK environment variables in their personal profile.

if [ -z "${CCACHE_DIR:-}" ] && [ -w %(localstatedir)s/cache/%(name)s ] && [ -d %(localstatedir)s/cache/%(name)s ] ; then
    export CCACHE_DIR=%(localstatedir)s/cache/%(name)s
    export CCACHE_UMASK=002
    unset CCACHE_HARDLINK
fi
