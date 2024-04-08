--- dlls/winevulkan/vulkan.c.orig
+++ dlls/winevulkan/vulkan.c
@@ -4332,11 +4332,7 @@ signal_op_complete:
 
 void *signaller_worker(void *arg)
 {
-#ifdef HAVE_SYS_SYSCALL_H
-    int unix_tid = syscall( __NR_gettid );
-#else
     int unix_tid = -1;
-#endif
     struct wine_device *device = arg;
     struct wine_semaphore *sem;
     VkSemaphoreWaitInfo wait_info = { 0 };
