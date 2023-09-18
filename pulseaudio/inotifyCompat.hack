--- pulseaudio-0.9.21/src/modules/module-udev-detect.c.orig	2010-01-18 12:26:38.866440593 +0000
+++ pulseaudio-0.9.21/src/modules/module-udev-detect.c	2010-01-18 12:25:30.054440907 +0000
@@ -24,6 +24,7 @@
 #endif
 
 #include <errno.h>
+#include <fcntl.h>
 #include <limits.h>
 #include <dirent.h>
 #include <sys/inotify.h>
@@ -616,12 +617,31 @@
 
     if (u->inotify_fd >= 0)
         return 0;
-
+#ifdef HAVE_INOTIFY_INIT1
     if ((u->inotify_fd = inotify_init1(IN_CLOEXEC|IN_NONBLOCK)) < 0) {
         pa_log("inotify_init1() failed: %s", pa_cstrerror(errno));
         return -1;
     }
+#else
+    u->inotify_fd = inotify_init ();
+    if (u->inotify_fd == -1) {
+      pa_log("inotify_init1() failed: %s", pa_cstrerror(errno));
+      return -1;
+    }
+    if (fcntl (u->inotify_fd, F_SETFL, O_NONBLOCK) == -1) {
+      pa_log("inotify_init1() failed: %s", pa_cstrerror(errno));
+      close (u->inotify_fd);
+      u->inotify_fd = -1;
+      return -1;
+    }
+    if (fcntl (u->inotify_fd, F_SETFD, FD_CLOEXEC) == -1) {
+      pa_log("inotify_init1() failed: %s", pa_cstrerror(errno));
+      close (u->inotify_fd);
+      u->inotify_fd = -1;
+      return -1;
+    }
 
+#endif
     dev_snd = pa_sprintf_malloc("%s/snd", udev_get_dev_path(u->udev));
     r = inotify_add_watch(u->inotify_fd, dev_snd, IN_ATTRIB|IN_CLOSE_WRITE|IN_DELETE_SELF|IN_MOVE_SELF);
     pa_xfree(dev_snd);
