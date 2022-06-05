cl /c /MD /I .\tmp\openfst\src\include\ openfst_wrapper.cc
link /DLL /MD /OUT:openfst_wrapper.dll openfst_wrapper.obj libfst.lib

Copy-Item .\openfst_wrapper.dll ..\openfst-x86_64-win32\
Copy-Item .\openfst_wrapper.dll ..\openfst\