--- server/fsync.c.orig
+++ server/fsync.c
@@ -325,7 +325,11 @@
 
 static inline int futex_wake( int *addr, int val )
 {
+#ifdef __linux__
     return syscall( __NR_futex, addr, 1, val, NULL, 0, 0 );
+#else
+    assert(0);
+#endif
 }
 
 /* shm layout for events or event-like objects. */
