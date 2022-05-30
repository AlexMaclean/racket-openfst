all: lib-x86_64

lib-x86_64: openfst_wrapper.so
	cp -fv ./*.so* ../openfst-x86_64-linux

openfst_wrapper.so: openfst_wrapper.cc libfst.so.25
	LD_RUN_PATH='$$ORIGIN' g++-7 -fpic -shared -I/usr/local/include -L. -std=c++17 openfst_wrapper.cc -ldl -lfst -o openfst_wrapper.so

libfst.so.25:
	cp /usr/local/lib/libfst.so.25 ./

clean:
	rm -fv *.o *.so *.la *.so.*
