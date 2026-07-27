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
;
; HLOE Logical and Bit Operations
;

#include "hloe.inc"

 GLOBAL andb,notb,orb,andu,oru,xoru,setbit,clearbit ;Logical and Bit
 EXTERN mul

 
hlog1c CODE

notb: 
 movf HLINDF,f
 btfsc STATUS,Z
 goto nbnb
 clrf HLINDF;not Z
 goto ncnc
nbnb: 
 bsf HLINDF,0 ;Z
ncnc:
 return
 

orb: 
 POP
 xorlw .0
 btfsc STATUS,Z
 goto zzorz1;Z set
 movlw .1
 movwf HLINDF
 return
zzorz1: ;Z set
 POP
 xorlw .0
 btfsc STATUS,Z
 goto zzorz2;Z set
 movlw .1
 PUSH
 return
zzorz2: ;Z set 
 movlw .0
 PUSH
 return
 
andb: 
 pagesel mul
 goto mul

xoru: 
 POP
 xorwf HLINDF,w
 decf HLFSR,f 
 PUSH
 return
;REENTRANT
oru: 
 POP
 iorwf HLINDF,w
 decf HLFSR,f 
 PUSH
 return
 
;REENTRANT
andu: 
 POP
 andwf HLINDF,w
 decf HLFSR,f 
 PUSH
 return
 


 

#define margp2 hloekernel00

setbit:
 POP
 banksel margp2
 movwf  margp2
 POP
 xorlw .0
 btfss STATUS,Z
 goto hllbmkAAA
 ;bit 0 request
 movfw  margp2
 iorlw .1
 goto hllbmkHAA
hllbmkAAA: 
 ;not necess here xorlw .0
 xorlw .1
 btfss STATUS,Z
 goto hllbmkBAA
 ;bit 1 request
 movfw  margp2
 iorlw .2
 goto hllbmkHAA
hllbmkBAA: 
 xorlw .1
 xorlw .2
 btfss STATUS,Z
 goto hllbmkCAA
 ;bit 2 request
 movfw margp2
 iorlw .4
 goto hllbmkHAA
hllbmkCAA: 
 xorlw .2
 xorlw .3
 btfss STATUS,Z
 goto hllbmkDAA
 ;bit 3 request
 movfw margp2
 iorlw .8
 goto hllbmkHAA
hllbmkDAA: 
 xorlw .3
 xorlw .4
 btfss STATUS,Z
 goto hllbmkEAA
 ;bit 4 request
 movfw margp2
 iorlw .16
 goto hllbmkHAA
hllbmkEAA: 
 xorlw .4
 xorlw .5
 btfss STATUS,Z
 goto hllbmkFAA
 ;bit 5 request
 movfw margp2
 iorlw .32
 goto hllbmkHAA
hllbmkFAA: 
 xorlw .5
 xorlw .6
 btfss STATUS,Z
 goto hllbmkGAA
 ;bit 6 request
 movfw margp2
 iorlw .64
 goto hllbmkHAA
hllbmkGAA: 
 ;bit 7 request
 movfw margp2
 iorlw .128 
hllbmkHAA:  
 PUSH 
 return



#undefine margp2

#define margp2 hloekernel00

clearbit:
 POP
 banksel margp2
 movwf margp2
 POP 
 xorlw .0
 btfss STATUS,Z
 goto hllbmkIAA
 ;bit 0 request
 movfw margp2
 andlw .255-.1
 goto hllbmkPAA
hllbmkIAA: 
 ;not necess here xorlw .0
 xorlw .1
 btfss STATUS,Z
 goto hllbmkJAA
 ;bit 1 request
 movfw margp2
 andlw .255-.2
 goto hllbmkPAA
hllbmkJAA: 
 xorlw .1
 xorlw .2
 btfss STATUS,Z
 goto hllbmkKAA
 ;bit 2 request
 movfw margp2
 andlw .255-.4
 goto hllbmkPAA
hllbmkKAA: 
 xorlw .2
 xorlw .3
 btfss STATUS,Z
 goto hllbmkLAA
 ;bit 3 request
 movfw margp2
 andlw .255-.8
 goto hllbmkPAA
hllbmkLAA: 
 xorlw .3
 xorlw .4
 btfss STATUS,Z
 goto hllbmkMAA
 ;bit 4 request
 movfw margp2
 andlw .255-.16
 goto hllbmkPAA
hllbmkMAA: 
 xorlw .4
 xorlw .5
 btfss STATUS,Z
 goto hllbmkNAA
 ;bit 5 request
 movfw margp2
 andlw .255-.32
 goto hllbmkPAA
hllbmkNAA: 
 xorlw .5
 xorlw .6
 btfss STATUS,Z
 goto hllbmkOAA
 ;bit 6 request
 movfw margp2
 andlw .255-.64
 goto hllbmkPAA
hllbmkOAA: 
 ;bit 7 request
 movfw margp2
 andlw .255-.128
hllbmkPAA:  
 PUSH
 return



#undefine margp2
 end