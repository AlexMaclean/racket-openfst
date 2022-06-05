# Creating the FFI Library files for each platform

## Make and Install

See the `build-*` scripts for each platform. These will install OpenFST from
the internet and build the FFI library files. To rerun just the build (no reinstall of OpenFST),
run `make linux|macos` or `make_win32.ps1`.

## Inspection and Debugging Commands

### Linux

```BASH
patchelf --print-rpath openfst_wrapper.so
patchelf --print-needed openfst_wrapper.so
objdump -T openfst_wrapper.so | grep GLIBCXX_
```

### Windows

```PowerShell
dumpbin /exports .\openfst_wrapper.dll
```

### Mac OS X

```BASH
otool -L openfst_wrapper.dylib
```
