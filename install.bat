@echo off
setlocal
set vim=%~dp0

pushd %userprofile%
echo Linking files from %vim%\COPY_TO_HOME to %userprofile%...
:: Making hardlinks for files because of the vim-WinSymLink bug
mklink /h _vimrc %vim%\COPY_TO_HOME\_vimrc
mklink /h .ctags %vim%\COPY_TO_HOME\.ctags
mklink /d vimfiles %vim%\COPY_TO_HOME\vimfiles

pushd c:\windows
echo Linking files from %vim%\COPY_TO_HOME to c:\windows...
:: Don't make hardlink here as anywhere it's less likely that we edit files
:: here
for %%i in (%vim%\COPY_TO_PATH\*) do (
	mklink %%~nxi %%i
)
popd

popd
