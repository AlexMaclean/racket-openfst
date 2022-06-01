Remove-Item -Recurse -Force .\temp

mkdir .\temp
Set-Location .\temp

git clone https://github.com/kkm000/openfst.git

Set-Location .\openfst

cmake .