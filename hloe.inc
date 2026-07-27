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

#define HLMULTITASK

#define HLOE_STACK_SIZE .80
#define HLOE_STACK2_SIZE .80
#include <p16f690.inc>

#include <kernel.inc>

#ifndef HLOE_KERNEL_INC
 EXTERN  stack, alt_stack,  alt_fsr, in_isr, W_Save, STATUS_Save, FSR_Save, ALT_Save
 EXTERN kpush,kpop
 EXTERN  softstack0,softstack1 ;Auxilliary stack pointers when main thread using stack 2
 EXTERN hloekernel00,hloekernel01,hloekernel02 ;BLSS
#endif


 
 
