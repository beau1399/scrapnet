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
; HLOE ANSI Terminal Library
;

#include "hloe.inc"

 EXTERN printch,in_isr,divu,modu
 GLOBAL cls,graphxy,printchxy,printu,dbgstk,dbgpku

GOTOXY macro 	;Used internally
 movlw 0x1b
 PUSH
 FAR_CALL graphxy,printch
 movlw '['
 PUSH
 FAR_CALL graphxy,printch
 FAR_CALL graphxy,printu
 movlw ';'
 PUSH
 FAR_CALL graphxy,printch
 FAR_CALL graphxy,printu
 movlw 'H'
 PUSH
 FAR_CALL graphxy,printch
 endm

 
;This library calls functions that use BLSS for their static storage. So, we cannot
; use BLSS here and must allocate our own data.
ansiadt udata
aart00 RES .1
aart01 RES .1
ansiart CODE

#define charx aart00

#define ansiG aart01

graphxy:
;Print PARM0 blocks (out of PARM1 possible) 
; e.g. _graphxy[8 _divu[_sample[] 32] 10 10 ]
;Makes positioning and drawing atomic for multitasking apps
 
 GOTOXY
 POP
 banksel charx
 movwf charx
 ;Draw Bar
 xorlw .0 ;force a test
 btfsc STATUS,Z
 goto hllbmkBAA
 banksel ansiG
 movwf ansiG
hllbmkAAA:
 movlw 0xDB
 PUSH
 FAR_CALL graphxy,printch
 banksel ansiG
 decfsz ansiG,f
 goto hllbmkAAA
 ;Draw remainder as lighter "empty" squares
hllbmkBAA: 
 banksel charx
 movf charx,w
 IFNDEF __16F1827
  subwf INDF,f
 ELSE
  subwf INDF0,f
 ENDIF
 
 POP
 xorlw .0 ;force a test
 btfsc STATUS,Z
 goto hllbmkDAA
 banksel ansiG
 movwf ansiG
hllbmkCAA:
 movlw 0xB0 
 PUSH
 FAR_CALL graphxy,printch
 banksel ansiG
 decfsz ansiG,f
 goto hllbmkCAA
hllbmkDAA:
 return

#undefine charx

#undefine ansiG

#define ansiH aart00

#define ansiG aart01

cls:
 movlw 0x1b
 PUSH
 FAR_CALL graphxy,printch
 movlw '['
 PUSH
 FAR_CALL graphxy,printch
 movlw '2'
 PUSH
 FAR_CALL graphxy,printch
 movlw 'J'
 PUSH
 FAR_CALL graphxy,printch
 banksel ansiG
 movlw .25 ;25 lines
 movwf ansiG
 banksel ansiH
 movlw .1 
 movwf ansiH
 movlw .10
hllbmkEAA: 
 ;Flush buffer
 banksel PIR1 
 btfss PIR1,TXIF  
 goto $-1 
 ;Transmit 
 banksel TXREG
 movwf TXREG  
 ;Flush buffer... 2x allows cleaner preemption
 banksel PIR1
 btfss PIR1,TXIF  
 goto $-1  
 banksel ansiG
 decfsz ansiG,f
 goto hllbmkEAA
 decfsz ansiH,f
 goto hllbmkEAA
 return

#undefine ansiH

#undefine ansiG
printchxy: 
 
 GOTOXY
 FAR_CALL graphxy,printch
 return

; PRINTU - called by funcs. above, needs own storage

ansiadu udata
aartpr00 RES .1

cprntuc CODE

#define margpi aartpr00

printu:
 POP
 banksel margpi
 movwf margpi
 PUSH
 movlw .100 
 PUSH
 FAR_CALL printu,divu
 POP
 addlw '0' 
 PUSH
 FAR_CALL printu, printch
 banksel margpi 
 movfw margpi
 PUSH
 movlw .100 
 PUSH
 FAR_CALL printu, modu
 movlw .10
 PUSH
 FAR_CALL printu, divu
 POP
 addlw '0' 
 PUSH
 FAR_CALL printu, printch
 banksel margpi
 movfw margpi
 PUSH
 movlw .10 
 PUSH
 FAR_CALL printu, modu
 POP
 addlw '0' 
 PUSH
 FAR_CALL printu, printch  ;TODO - FAR GOTO
 return

#undefine margpi
hloedbg CODE

; Debugging routines
;Peek at top of stack (top byte interpreted as type U)
dbgpku:
 COPY
 movlw .13
 PUSH
 FAR_CALL dbgpku,printch
 movlw .10
 PUSH
 FAR_CALL dbgpku, printch
 movlw 'U'
 PUSH
 FAR_CALL dbgpku, printch
 FAR_CALL dbgpku, printu
 return
 
dbgstk:
 movlw '@'
 PUSH
 FAR_CALL dbgstk, printch        
 movfw HLFSR
 PUSH
 FAR_CALL dbgstk, printu 
 return
 
 end
