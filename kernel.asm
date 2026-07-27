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
; Stack-based integer math and I/O Library
;
; Doesn't make outside calls or gotos, so PAGESEL is not used.
;
; Does not lock out interrupts at any point.
;
; Also, this must be kept <=1page (typically 1024 bytes).
;
; This needs to be checked (look at HLOE.MAP) is modifications are made. MPLAB / MPASM / 
;  MPLINK don't seem to reliably enforce it, even in the presence of a suitably 
;  fragmented LKR file. It seems that code written to exceed the boundary will override
;  the 1024 byte page boundary.
;

#define HLOE_KERNEL_INC 1 ;File level macro allows selective preprocessing in HLOE.INC &c

#include "hloe.inc"
 ;FUNCTIONS
 GLOBAL printch,getch ;I/O
 GLOBAL modu,divu,add,mul,eq,negti ;Math
 GLOBAL parm,kpush,kpop,autovar ;Function Call
 ;FIELDS
 GLOBAL stack,alt_stack ;absolute beginning of each stack
 GLOBAL alt_fsr,softstack0,softstack1 ;Second Stack TODO document purpose of each var
 GLOBAL W_Save, STATUS_Save, FSR_Save, ALT_Save, in_isr ;preemption buffers and flag 
 GLOBAL hloekernel00,hloekernel01,hloekernel02 ;BLSS
 
;Storage Allocation

;Stacks 
ukrnl2 UDATA
stack res HLOE_STACK_SIZE
 
ukrnl3 UDATA 
alt_stack res HLOE_STACK2_SIZE
 
;Statics 
; Like the stacks, many of these can be used by other HLOE libraries... 
ukernl udata 

;"BLSS" interrupt-safe variables... these can be used
; by ANY functions that do not call other BLSS consumer
; functions. These must be used in ISR-safe ways, though,
; e.g. using MLSUBWF and HLMOVF instead of subwf and movf.
hloekernel00 res 1 	  
hloekernel01 res 1    
hloekernel02 res 1    
  
ukrshr udata_shr

;Three "software stack"  statics in the shared (fast)  page
softstack0 res 1		
#ifdef HLMULTITASK
softstack0isr res 1
#endif

softstack1 res 1		
#ifdef HLMULTITASK
softstack1isr res 1
#endif

softstack2 res 1		
#ifdef HLMULTITASK
softstack2isr res 1
#endif

alt_fsr res 1
W_Save res 1 ; Used to save context for interrupts
STATUS_Save res 1
FSR_Save res 1
ALT_Save res 1
in_isr res 1
kernel CODE

 

#define mterm hloekernel00

mul:
 POP
 banksel mterm 
 movwf mterm
 clrw 
 addwf HLINDF,w 
 decf mterm,f 
 btfss STATUS,Z 
 goto $-3
 movwf HLINDF
 return


#undefine mterm
add: 
 POP
 addwf HLINDF,w
 decf HLFSR,f 
 PUSH
 return

negti:  ;Two's Comp. Negation
 comf HLINDF,f
 incf HLINDF,f
 return
 
printch:
 POP
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
 return  
 


#define mterm hloekernel00

#define mdiv hloekernel01

#define mquot hloekernel02

modu:
 banksel mquot 
 clrf mquot
 POP
 movwf mdiv
 POP
 movwf mterm
 movfw mdiv
 subwf mterm,f
 btfss STATUS,C 
 goto $+3
 incf mquot,f 
 goto $-4
 addwf mterm,w
 PUSH
 return 


#undefine mterm

#undefine mdiv

#undefine mquot

#define mterm hloekernel00

#define mdiv hloekernel01

#define mquot hloekernel02

divu:
 banksel mquot 
 clrf mquot
 POP
 movwf mdiv
 POP
 movwf mterm
 movfw mdiv
 subwf mterm,f
 btfss STATUS,C 
 goto $+3
 incf mquot,f 
 goto $-4
 movfw mquot
 PUSH
 return 


#undefine mterm

#undefine mdiv

#undefine mquot
; ISR-safe but blocking... this combination allows
 ; the ISR to do something else while input
 ; is awaited in an interruptable main loop.
getch:
 banksel PIR1
geth2: 
 btfss PIR1,RCIF
 goto geth2
 banksel RCREG
 movf RCREG,w
 PUSH 
 return
 
eq: 
 POP 
 xorwf HLINDF,w
 movlw .1 
 btfss STATUS,Z
 movlw .0 
 decf HLFSR,f 
 PUSH 
 return

#define sstack0 softstack0 
#define sstack1 softstack1 
#define sstack2 softstack2 

hllparmcore macro 
 movwf sstack2
 movfw HLFSR ;save user stack ptr; it's ok to share these with the "kernel stack" 
           ; functions, because of the way that the kernel stack calls bracket the
		   ; body of parm (vs. being mingled within it).
 movwf sstack0
 movfw HLINDF
 ;Incorporate offset into working pointer 
 subwf sstack2,w
 movwf HLFSR 
 movfw HLINDF ;After this, retval is in W
 ;Save Retval in mkarg1
 movwf sstack1
 ;Fix HLFSR then push ret. val
 movfw sstack0
 movwf HLFSR ;restore user stack ptr...
 clrf sstack0
 movfw sstack1 ; Push parm's return value...
 movwf HLINDF
 ;Put base ptr back
 movfw sstack2
 goto kpush ;Allow it to return as in tail recursion... no need for a macro or func call 
 endm

parm:
 HLKRNPOP ;base ptr in softstack2.. using macro so as not to add an extra level of call depth
 hllparmcore
#undefine sstack0 
#undefine sstack1
#undefine sstack2 
 
autovar:
 call negti
 goto parm		;Coroutines

kpop: ;Pops from second stack to W; more complex than POP; must swap HLFSR ptr.
 HLKRNPOP
 return 
 
kpush: ;Push to second stack from W
 HLKRNPSH
 return
 
 END
	