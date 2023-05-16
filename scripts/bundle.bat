::
:: Parameters:
::
:: [nextlinux path]     run backend with custom nextlinux executables path
::

IF "%1"=="" (
    SET NEXTLINUX_PATH=..\nextlinux\build\Release
) ELSE (
    :: or use custom path
    SET NEXTLINUX_PATH=%1
)

:copy_nextlinux
cd ember-electron\resources

xcopy /E /Y /I ..\..\%NEXTLINUX_PATH% nextlinux

md nextlinux\capture-samples
copy ..\..\capture-samples\502Error.scap nextlinux\capture-samples\
copy ..\..\capture-samples\404Error.scap nextlinux\capture-samples\

cd ..\..
EXIT /B 0

CALL :copy_nextlinux
