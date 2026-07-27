;
; "SCRAPNET" 
;
; A Deterministic, Integrated Field Bus
;
; Licensed Under the GNU Public License ("Greater GPL")
;
; See "target.asm"
;
; Copyright (c) 2011 James Beau Wilkinson
;
; HLOE ANSI Palette Library
;
;

#include "hloe.inc"

 EXTERN printch,in_isr
 GLOBAL night,day

hlpal1 CODE

night:
 
 ;color
 movlw 0x1b
 PUSH
 FAR_CALL night,printch
 movlw '['
 PUSH
 FAR_CALL night,printch

 movlw '0'
 PUSH
 FAR_CALL night,printch
 movlw ';'
 PUSH
 FAR_CALL night,printch

 movlw '3'
 PUSH
 FAR_CALL night,printch
 movlw '2'
 PUSH
 FAR_CALL night,printch
 movlw ';'
 PUSH
 FAR_CALL night,printch
 movlw '4'
 PUSH
 FAR_CALL night,printch
 movlw '0'
 PUSH
 FAR_CALL night,printch
 movlw 'm'
 PUSH
 FAR_CALL night,printch
 
 return

day:
 
 ;color
 movlw 0x1b
 PUSH
 FAR_CALL day,printch
 movlw '['
 PUSH
 FAR_CALL day,printch

 movlw '0'
 PUSH
 FAR_CALL day,printch
 movlw ';'
 PUSH
 FAR_CALL day,printch

 movlw '4'
 PUSH
 FAR_CALL day,printch
 movlw '7'
 PUSH
 FAR_CALL day,printch
 movlw ';'
 PUSH
 FAR_CALL day,printch
 movlw '3'
 PUSH
 FAR_CALL day,printch
 movlw '4'
 PUSH
 FAR_CALL day,printch
 movlw 'm'
 PUSH
 FAR_CALL day,printch
 
 return
 


 end



 