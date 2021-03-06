@echo off
setlocal
set vim=%~dp0

pushd %userprofile%
echo Linking files from %vim%\COPY_TO_HOME to %userprofile%...
mklink _vimrc %vim%\COPY_TO_HOME\_vimrc

pushd c:\windows
echo Linking files from %vim%\COPY_TO_PATH to c:\windows...
:: Don't make hardlink here as anywhere it's less likely that we edit files
:: here
for %%i in (%vim%\COPY_TO_PATH\*) do (
	mklink %%~nxi %%i
)
popd

mkdir vundle
pushd vundle
git clone https://github.com/gmarik/Vundle.vim.git
popd

REM cloning vim-plug repo into `autoload` folder because vim-plug repo has 
REM `plug.vim` in the repo's root (this is different than Vundle)
mkdir vim-plug\vim-plug
git clone https://github.com/junegunn/vim-plug.git vim-plug\vim-plug\autoload
