
all: 
	echo "Must make with either macosx or linux"

## macosx ==========================

macosx: x86_64-macosx

x86_64-macosx: openfst_wrapper.dylib libfst.25.dylib
	cp -fv ./*.dylib ../openfst-x86_64-macosx

openfst_wrapper.dylib: openfst_wrapper.cc libfst.25.dylib
	g++ -arch x86_64 -fpic -shared -I/usr/local/include -L. -std=c++17 openfst_wrapper.cc -ldl -lfst -o openfst_wrapper.dylib
	install_name_tool -change /usr/local/lib/libfst.25.dylib @loader_path/libfst.25.dylib openfst_wrapper.dylib

libfst.25.dylib:
	cp /usr/local/lib/libfst.25.dylib ./

## linux ===========================

linux: x86_64-linux

x86_64-linux: openfst_wrapper.so libfst.so.25
	cp -fv ./*.so* ../openfst-x86_64-linux

openfst_wrapper.so: openfst_wrapper.cc libfst.so.25
	LD_RUN_PATH='$$ORIGIN' g++-7 -fpic -shared -I/usr/local/include -L. -std=c++17 openfst_wrapper.cc -ldl -lfst -o openfst_wrapper.so

libfst.so.25:
	cp /usr/local/lib/libfst.so.25 ./

## ===========================

clean:
	rm -fv *.o *.so *.la *.so.* *.dylib
