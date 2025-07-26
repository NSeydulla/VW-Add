@echo off
setlocal EnableDelayedExpansion

set "output=inkgame.luau"
> "%output%" echo -- Generated automatically

:: === Adding Utils.luau ===
if exist "Utils.luau" (
    echo [INFO] Adding Utils.luau...
    >> "%output%" echo local Functions = function^(...^)
    type "Utils.luau" >> "%output%"
    >> "%output%" echo end
    >> "%output%" echo.
) else (
    echo [WARN] Utils.luau not found!
)

:: === Adding GroupFunctions ===
echo [INFO] Adding Groups\*.luau...

>> "%output%" echo local GroupFunctions = {
for %%f in (Groups\*.luau) do (
    call :process "%%f"
)
>> "%output%" echo }

:: === Adding main.luau ===
echo [INFO] Adding main.luau...
if exist "main.luau" (
    >> "%output%" echo.
    type main.luau >> "%output%"
) else (
    echo [ERROR] main.luau not found!
)

echo.
echo [OK] File created: %output%
exit /b

:process
set "filepath=%~1"
for %%a in ("%~1") do set "funcname=%%~na"

echo [INFO] Operating: !filepath! (module name: !funcname!)

>> "%output%" echo.
>> "%output%" echo !funcname! = function(...)
type "!filepath!" >> "%output%"
>> "%output%" echo end,
exit /b