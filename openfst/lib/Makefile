
all: openfst_wrapper.so

openfst_wrapper.so: openfst_wrapper.cc libfst.so
	LD_RUN_PATH='$$ORIGIN' g++ -fpic -shared -I/usr/local/include -L. -std=c++17 openfst_wrapper.cc -ldl -lfst -o openfst_wrapper.so

libfst.so:
	cp /usr/local/lib/libfst.so ./

clean:
	rm -fv *.o *.so *.la *.so.*
