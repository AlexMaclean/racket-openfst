# Creating the FFI Library files for each platform

## Linux

```BASH
patchelf --print-rpath openfst_wrapper.so
patchelf --print-needed openfst_wrapper.so
objdump -T openfst_wrapper.so | grep GLIBCXX_
```

## Windows

```PowerShell
dumpbin /exports .\openfst_wrapper.dll
```

## Mac OS X

```BASH

```