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
; HLOE Analog Input Sampling
;

#include "hloe.inc"

 GLOBAL sample,resample
 
analog CODE

;Sets analog channel and samples it
; e.g. _analog[2] for channel 2 analog 
sample:
 
 ;setup ADCON1 (clk divider for sampling)
 ;adc occurs at 1/16th of 8mhz clock speed, or 2uS per sample; limit is 1.6uS 
 banksel ADCON1
 bsf ADCON1,6
 bcf ADCON1,5
 bsf ADCON1,4
 banksel ADCON0 ;poll
 bcf ADCON0,GO
 POP
 xorlw .4 
 btfss STATUS,Z
 goto onnte1
 banksel ANSEL
 bsf ANSEL,4
 banksel ADCON0
 movlw B'00010001'
 movwf ADCON0
 goto outii
onnte1: 
 xorlw .4 ;undo 
 xorlw .3
 btfss STATUS,Z
 goto onnte2
 banksel ANSEL
 bsf ANSEL,3
 banksel ADCON0
 movlw B'00001101'
 movwf ADCON0
 goto outii
onnte2: 
 xorlw .3 ;undo 
 xorlw .2
 btfss STATUS,Z
 goto onnte3
 banksel ANSEL
 bsf ANSEL,2
 banksel ADCON0
 movlw B'00001001'
 movwf ADCON0
 goto outii
onnte3:
 xorlw .2 ;undo 
 xorlw .1
 btfss STATUS,Z
 goto onnte4
 banksel ANSEL
 bsf ANSEL,1
 banksel ADCON0
 movlw B'00000101'
 movwf ADCON0
 goto outii
onnte4:
 banksel ANSEL
 bsf ANSEL,0
 banksel ADCON0
 movlw B'00000001'
 movwf ADCON0 
outii:
 nop ;wait minimum capacitor charging time before initial sampling; this is
 nop ;~5/1000000 sec per datasheet at maximum impedance, 50 deg celsius; 
 nop ; ea. nop is 4cyc @8000000hz; this is 1/2000000; we need 10 nops or
 nop ; 10/2000000. For applications above 50deg celsius this may need 
 nop ; to be increased. In testing, such temperatures were not seen.
 nop
 nop
 nop 
 nop
 nop

 
 nop ; 12MHZ extra delay... trying to be conservative b/c this is a default
 nop ;   file. The delay as provided works for all 16f690-gen CPUs running
 nop ;   on the internal oscillator.
 nop 
 nop 
 nop
 nop 
 nop
 nop
 nop 
 nop
 nop

 ;Wait for AD conversion process...
 bsf ADCON0,GO
 btfsc ADCON0,GO
 goto $-1
 movf ADRESH,w
 PUSH
 return
 
;Re-samples last channel sampled
; (or default channel if none)
resample:
 ;Wait for analog sample... 
 banksel ADCON0 ;poll
 bsf ADCON0,GO 
 btfsc ADCON0,GO
 goto $-1
 movf ADRESH,w 
 PUSH
 return

 
 END 
 