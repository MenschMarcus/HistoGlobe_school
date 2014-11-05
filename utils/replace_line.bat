@echo off
setlocal ENABLEDELAYEDEXPANSION
set lineCount=0
set lineContent=%3
call :dequote lineContent

ren %1 tmp.txt
for /f "tokens=* delims=" %%a in (tmp.txt) do (
	set /a lineCount += 1
	if !lineCount! == %2 (
		for /f "tokens=* delims=" %%a in ("%lineContent%") do echo %%a >> %1
	) else (
		echo %%a >> %1
	)
)

del tmp.txt 

:dequote
for /f "delims=" %%A in ('echo %%%1%%') do (
	set %1=%%~A
)
goto :eof

:eof