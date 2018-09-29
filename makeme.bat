del source\*.o
wla-gb -o source\dialog.s
wla-gb -o source\rendering.s
wla-gb -o source\bank0.s
wla-gb -o source\fixes.s
wlalink link rom\out.gbc
del source\*.o
pause