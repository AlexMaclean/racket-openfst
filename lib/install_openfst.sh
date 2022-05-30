#!/bin/bash

OPENFST=openfst-1.8.2

wget https://www.openfst.org/twiki/pub/FST/FstDownload/$(OPENFST).tar.gz
tar -zxvf $(OPENFST).tar.gz

cd $(OPENFST)
./configure --enable-far
make
make install