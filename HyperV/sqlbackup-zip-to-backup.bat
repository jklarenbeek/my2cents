::@echo off

:: get week of year and set default filenames for weekly backup
for /f %%i in ('e:\snapshot\getdate.exe +%%V') do set week=%%i
set filenamesnaplog="e:\snapshot\WEBSERVER-LOG-%week%.txt"
set filenamesqllog="c:\SQL_Backup\WEBSERVER-SQL-%week%.log"
set filename7z="Z:\WEBSERVER-SQL-%week%.7z"

@echo. >> %filenamesnaplog% 2>&1
@echo. >> %filenamesnaplog% 2>&1
@echo. >> %filenamesnaplog% 2>&1

e:\snapshot\getdate.exe >> %filenamesnaplog% 2>&1

echo NET USE Z: \\SERVER\snapshot >> %filenamesnaplog% 2>&1
NET USE Z: \\CL20NODE4\snapshot Bwv1750 /USER:JOHAM\webserver_backup >> %filenamesnaplog% 2>&1

@IF EXIST Z: (
	echo NOTE:found backup server >> %filenamesnaplog% 2>&1
) else (
	echo ERROR:cant open share to backup server >> %filenamesnaplog% 2>&1
)

E:\snapshot\7z.exe a -p:Bwv1750 -mx9 -mmt -t7z %filename7z% c:\SQL_Backup\*.log c:\SQL_Backup\*.txt c:\SQL_Backup\*.bak  >> %filenamesnaplog% 2>&1

copy /Y %filenamesnaplog% z:\ >> %filenamesnaplog% 2>&1

NET USE Z: /DELETE >> %filenamesnaplog% 2>&1
