cas -tRV9E -l main.asm
@if %ERRORLEVEL% NEQ 0 goto end
cln  main.o -o  main.bin -m main.map
copy main.lst ..\sim
copy main.bin ..\sim
:end