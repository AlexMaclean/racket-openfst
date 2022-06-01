Remove-Item -Recurse -Force .\temp

mkdir .\temp
Set-Location .\temp

git clone https://github.com/kkm000/openfst.git

Set-Location .\openfst

MsBuild .\openfst.sln -t:libfst -p:Configuration=Release

Copy-Item .\build_output\x64\Release\lib\libfst.lib ..\..\
Set-Location ..\..\

.\make_win32.ps1