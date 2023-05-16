::
:: Parameters:
::
:: [nextlinux path]     run backend with custom nextlinux executables path
::

IF "%1"=="" (
    SET NEXTLINUX_PATH="..\..\..\nextlinux\build\Release"
) ELSE (
    :: or use custom path
    SET NEXTLINUX_PATH=$1
)

:run
	cd ember-electron\backend

	npm start --- -p=%NEXTLINUX_PATH%

	cd ..\..

	EXIT /B 0


CALL :run
