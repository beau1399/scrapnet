
"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "target.asm" /l"target.lst" /e"target.err" /o"target.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "compare.asm" /l"compare.lst" /e"compare.err" /o"compare.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "palette.asm" /l"palette.lst" /e"palette.err" /o"palette.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "analog.asm" /l"analog.lst" /e"analog.err" /o"analog.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "ansiart.asm" /l"ansiart.lst" /e"ansiart.err" /o"ansiart.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "kernel.asm" /l"kernel.lst" /e"kernel.err" /o"kernel.o"

"C:\Program Files\Microchip\MPASM Suite\MPAsmWin.exe" /w1 /q /p16f690 "logic.asm" /l"logic.lst" /e"logic.err" /o"logic.o"

"C:\Program Files\Microchip\MPASM Suite\MPLink.exe" "hloe16f690.lkr" "target.o"  "compare.o"  "palette.o"  "analog.o"  "ansiart.o"  "kernel.o"  "logic.o"  /o"hloe.hex" /M"hloe.map" /W
