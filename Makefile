
all: openfst_wrapper.so

openfst_wrapper.so: openfst_wrapper.cc
	g++ -fpic -shared -I/usr/local/include -L/usr/local/lib -std=c++17 openfst_wrapper.cc -ldl -lfst -o openfst_wrapper.so

clean:
	rm -fv *.o *.so
