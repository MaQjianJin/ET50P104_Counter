cas -tRV9E -l main.asm
pause
@if %ERRORLEVEL% NEQ 0 goto end
cln  main.o -o  main.bin -m main.map
pause
copy main.lst ..\sim
copy main.bin ..\sim
pause
:end