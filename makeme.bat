del source\*.o
wla-gb -o source\dialog.s
wla-gb -o source\rendering.s
wlalink link rom\out.gbc
del source\*.o
pause