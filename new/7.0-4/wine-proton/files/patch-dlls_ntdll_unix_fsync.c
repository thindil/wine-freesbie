--- dlls/ntdll/unix/fsync.c.orig
+++ dlls/ntdll/unix/fsync.c
@@ -151,15 +151,23 @@ static void simulate_sched_quantum(void)
 static inline int futex_wait_multiple( const struct futex_waitv *futexes,
         int count, const struct timespec64 *end, clockid_t clock_id )
 {
+#ifdef __linux__
    if (end)
         return syscall( __NR_futex_waitv, futexes, count, 0, end, clock_id );
    else
         return syscall( __NR_futex_waitv, futexes, count, 0, NULL, 0 );
+#else
+    return 0;
+#endif
 }
 
 static inline int futex_wake( int *addr, int val )
 {
+#ifdef __linux__
     return syscall( __NR_futex, addr, 1, val, NULL, 0, 0 );
+#else
+    return 0;
+#endif
 }
 
 int do_fsync(void)
