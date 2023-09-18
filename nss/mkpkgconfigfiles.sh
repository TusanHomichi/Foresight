mkdir ./mozilla/dist/pkgconfig
cat nss.pc.in | sed -e "s,%%libdir%%,%(libdir)s,g" \
                          -e "s,%%prefix%%,%(prefix)s,g" \
                          -e "s,%%exec_prefix%%,%(prefix)s,g" \
                          -e "s,%%includedir%%,%(includedir)s/nss3,g" \
                          -e "s,%%NSS_VERSION%%,%(version)s,g" \
                          -e "s,%%NSPR_VERSION%%,%(nspr_version)s,g" \
                          -e "s,%%NSSUTIL_VERSION%%,%(version)s,g" \
                          -e "s,%%SOFTOKEN_VERSION%%,%(version)s,g" > \
                          ./mozilla/dist/pkgconfig/nss.pc

cat nss-util.pc.in | sed -e "s,%%libdir%%,%(libdir)s,g" \
                          -e "s,%%prefix%%,%(prefix)s,g" \
                          -e "s,%%exec_prefix%%,%(prefix)s,g" \
                          -e "s,%%includedir%%,%(includedir)s/nss3,g" \
                          -e "s,%%NSS_VERSION%%,%(version)s,g" \
                          -e "s,%%NSPR_VERSION%%,%(nspr_version)s,g" \
                          -e "s,%%NSSUTIL_VERSION%%,%(version)s,g" \
                          -e "s,%%SOFTOKEN_VERSION%%,%(version)s,g" > \
                          ./mozilla/dist/pkgconfig/nss-util.pc

cat nss-softotk.pc.in | sed -e "s,%%libdir%%,%(libdir)s,g" \
                          -e "s,%%prefix%%,%(prefix)s,g" \
                          -e "s,%%exec_prefix%%,%(prefix)s,g" \
                          -e "s,%%includedir%%,%(includedir)s/nss3,g" \
                          -e "s,%%NSS_VERSION%%,%(version)s,g" \
                          -e "s,%%NSPR_VERSION%%,%(nspr_version)s,g" \
                          -e "s,%%NSSUTIL_VERSION%%,%(version)s,g" \
                          -e "s,%%SOFTOKEN_VERSION%%,%(version)s,g" > \
                          ./mozilla/dist/pkgconfig/nss-softokn.pc



NSS_VMAJOR=`cat mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VMAJOR" | awk '{print $3}'`
NSS_VMINOR=`cat mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VMINOR" | awk '{print $3}'`
NSS_VPATCH=`cat mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VPATCH" | awk '{print $3}'`

export NSS_VMAJOR 
export NSS_VMINOR 
export NSS_VPATCH

cat nss-config.in | sed -e "s,@libdir@,%(libdir)s,g" \
                          -e "s,@prefix@,%(prefix)s,g" \
                          -e "s,@exec_prefix@,%(prefix)s,g" \
                          -e "s,@includedir@,%(includedir)s/nss3,g" \
                          -e "s,@MOD_MAJOR_VERSION@,$NSS_VMAJOR,g" \
                          -e "s,@MOD_MINOR_VERSION@,$NSS_VMINOR,g" \
                          -e "s,@MOD_PATCH_VERSION@,$NSS_VPATCH,g" \
                          > ./mozilla/dist/pkgconfig/nss-config

cat nss-util-config.in | sed -e "s,@libdir@,%(libdir)s,g" \
                          -e "s,@prefix@,%(prefix)s,g" \
                          -e "s,@exec_prefix@,%(prefix)s,g" \
                          -e "s,@includedir@,%(includedir)s/nss3,g" \
                          -e "s,@MOD_MAJOR_VERSION@,$NSS_VMAJOR,g" \
                          -e "s,@MOD_MINOR_VERSION@,$NSS_VMINOR,g" \
                          -e "s,@MOD_PATCH_VERSION@,$NSS_VPATCH,g" \
                          > ./mozilla/dist/pkgconfig/nss-util-config

cat nss-softokn-config.in | sed -e "s,@libdir@,%(libdir)s,g" \
                          -e "s,@prefix@,%(prefix)s,g" \
                          -e "s,@exec_prefix@,%(prefix)s,g" \
                          -e "s,@includedir@,%(includedir)s/nss3,g" \
                          -e "s,@MOD_MAJOR_VERSION@,$NSS_VMAJOR,g" \
                          -e "s,@MOD_MINOR_VERSION@,$NSS_VMINOR,g" \
                          -e "s,@MOD_PATCH_VERSION@,$NSS_VPATCH,g" \
                          > ./mozilla/dist/pkgconfig/nss-softokn-config


chmod 755 ./mozilla/dist/pkgconfig/nss-config
chmod 755 ./mozilla/dist/pkgconfig/nss-util-config
chmod 755 ./mozilla/dist/pkgconfig/nss-softokn-config


