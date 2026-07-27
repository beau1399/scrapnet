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
; HLOE 8-bit Comparisons
;

#include "hloe.inc"
 
 GLOBAL geu,gti

hllcmppic CODE


#define mkarg1 hloekernel00

geu:
 POP
 banksel mkarg1
 movwf mkarg1	 
 POP
 subwf mkarg1,w
 btfsc STATUS,Z
 goto hllbmkAAA
 btfsc STATUS,C
 goto hllbmkBAA
hllbmkAAA:
 movlw .1
 PUSH
 ;
 return
hllbmkBAA:
 movlw .0
 PUSH
 ;
 return

#undefine mkarg1

#define mkarg2 hloekernel00
#define mkarg1 hloekernel01

gti:
 ;if argr > 0
 ;  if argl<0 return false
 ;  else stdlogic
 ;else 
 ;  if argl>=0 return true
 ;  else stdlogic
 POP 
 banksel mkarg1
 movwf mkarg1		;mkarg1 is right arg (argr)
 btfsc mkarg1,7
 goto $+15
 POP
 movwf mkarg2 
 btfss mkarg2,7
 goto hllbmkCAA
 movlw .0
 PUSH
 return
hllbmkCAA: subwf mkarg1,w ;mkarg1-mkarg2  right - left
 btfsc STATUS,C    ;C==0 means borrow occured, ie. mkarg2>mkarg1, i.e. left > rt
 goto $+5
 movlw .1
 PUSH
 return
 movlw .0
 PUSH
 return
 POP
 movwf mkarg2
 btfsc mkarg2,7
 goto $-0F
 movlw .1
 PUSH
 return

#undefine mkarg2
#undefine mkarg1
 end