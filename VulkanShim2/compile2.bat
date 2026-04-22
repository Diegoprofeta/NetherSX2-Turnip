set NDK=C:\Users\Nick\AppData\Local\Android\Sdk\ndk\26.1.10909125
set TOOLCHAIN=%NDK%\toolchains\llvm\prebuilt\windows-x86_64\bin

@echo on

call %TOOLCHAIN%\aarch64-linux-android26-clang++.cmd ^
    --target=aarch64-linux-android26 ^
    --sysroot=%NDK%\toolchains\llvm\prebuilt\windows-x86_64\sysroot ^
    -fPIC ^
    -O2 ^
    -c ^
    android_linker_ns.cpp elf_soname_patcher.cpp ^
    -I. ^
    -fvisibility=default

@echo on

call %TOOLCHAIN%\llvm-ar.exe rcs liblinkernsbypass.a ^
    android_linker_ns.o elf_soname_patcher.o
	
call %TOOLCHAIN%\aarch64-linux-android26-clang++.cmd ^
    -shared ^
    -fPIC ^
    -O2 ^
	-static-libstdc++ ^
	-fvisibility=default ^
    -o libhook_impl.so ^
    hook_impl.cpp ^
	-I. ^
	-L. -llinkernsbypass ^
    -ldl ^
    -llog ^
    -I%NDK%\toolchains\llvm\prebuilt\windows-x86_64\sysroot\usr\include
	

call %TOOLCHAIN%\aarch64-linux-android26-clang.cmd ^
    -shared ^
    -fPIC ^
    -O2 ^
	-z global ^
	-fvisibility=default ^
    -o libmain_hook.so ^
    main_hook.c ^
	-I. ^
    -ldl ^
    -llog ^
	-L. -lhook_impl ^
    -I%NDK%\toolchains\llvm\prebuilt\windows-x86_64\sysroot\usr\include
	
@echo on 

call %TOOLCHAIN%\aarch64-linux-android26-clang++.cmd ^
    -shared ^
    -fPIC ^
    -O2 ^
	-static-libstdc++ ^
	-fvisibility=default ^
    -o libvulkad.so ^
    vulkan_shim.cpp ^
	-I%NDK%\toolchains\llvm\prebuilt\windows-x86_64\sysroot\usr\include ^
	-ldl ^
    -llog ^
	-I. ^
	-L. -llinkernsbypass
	