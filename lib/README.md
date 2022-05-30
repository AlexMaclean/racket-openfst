# Creating the FFI Library files for each platform

## Linux

See `install_openfst.sh` for OpenFst Download script.

After that running make should do the trick

To inspect the binary

```BASH
patchelf --print-rpath openfst_wrapper.so
patchelf --print-needed openfst_wrapper.so
objdump -T openfst_wrapper.so | grep GLIBCXX_
```

## Windows

```BASH
git clone https://github.com/kkm000/openfst.git
```

```PowerShell
cl /c /MD /I ..\openfst\src\include\ ConsoleApplication2.cpp
link /DLL /MD /OUT:openfst_wrapper.dll ConsoleApplication2.obj ..\openfst\build_output\x64\Release\lib\libfst.lib

```

inspect with
```PowerShell
dumpbin /exports .\openfst_wrapper.dll
```
