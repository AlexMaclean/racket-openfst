#!/bin/bash

OPENFST=openfst-1.8.2

rm -rfv ./tmp
make clean

mkdir tmp
cd tmp

wget https://www.openfst.org/twiki/pub/FST/FstDownload/$OPENFST.tar.gz
tar -zxvf $OPENFST.tar.gz

cd $OPENFST
./configure --enable-far --enable-bin=no
make
make install

cd ../..
make linux