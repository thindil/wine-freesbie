--- dlls/gdi32/gdi32.spec.orig
+++ dlls/gdi32/gdi32.spec
@@ -79,7 +79,7 @@
 @ stdcall D3DKMTCreateDevice(ptr) win32u.NtGdiDdDDICreateDevice
 @ stdcall D3DKMTDestroyDCFromMemory(ptr) win32u.NtGdiDdDDIDestroyDCFromMemory
 @ stdcall D3DKMTDestroyDevice(ptr) win32u.NtGdiDdDDIDestroyDevice
-@ stdcall D3DKMTEnumAdapters2(ptr)
+# @ stdcall D3DKMTEnumAdapters2(ptr)
 @ stdcall D3DKMTEscape(ptr) win32u.NtGdiDdDDIEscape
 @ stdcall D3DKMTOpenAdapterFromDeviceName(ptr) win32u.NtGdiDdDDIOpenAdapterFromDeviceName
 @ stdcall D3DKMTOpenAdapterFromGdiDisplayName(ptr)
