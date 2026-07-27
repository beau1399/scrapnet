;
; "SCRAPNET" 
;
; A Deterministic, Integrated Field Bus
;
; This is the PIC 8-bit demo code for both stations (see compile-time constants just 
;  below...)
;
; Licensed Under the GNU Public License ("Greater GPL")
;
; Copyright (c) 2011 James Beau Wilkinson
;
#include "hloe.inc"
 EXTERN stack,mul,printchxy,printu,modu,getch,cls,divu,graphxy,geu,night,day,sample,eq
 EXTERN andb,parm,add,setbit,clearbit,andu,printch,clearbit,setbit

;These compile-time constants describe how time-division multiplexing is used;
;
; Every 2^21 cycles of CLOCK equate to a frame. Every 1,000,000 cycles of CLOCK equate
;  to one second. Each frame is divided into STAIONS equal time segments, allocated to
;  the station having STATNO=0, then STATNO=1, etc. up to STATNO-1.
;
#define STATNO .0
#define STATIONS .2
 
 __config(_EXTRC_OSC_NOCLKOUT&_WDT_OFF&_MCLRE_OFF&_IESO_OFF&_FCMEN_OFF&_PWRTE_ON&_BOR_OFF)

hllv2isday UDATA
isday RES .1
Resetv code 0 ;0 is the reset vector for most 8-bit PICs
 pagesel hloego
 goto hloego
 
vectr code 4 ;Interrupt vector for most 8-bit PICs
ISR:
 PREEMPT
 banksel PIR1
 btfss PIR1,TMR1IF
 goto hllnotisr49 
 bcf PIR1,TMR1IF
 movlw STATNO
 PUSH
 POP
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J2 
 goto hlllb51J3
hlllb51J2:
 banksel PORTA
 movfw PORTA
 PUSH
 movlw .16 ;Check Bit 4 (16=2^4)
 PUSH
 FAR_CALL ISR,andu
 POP
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J4  
 movlw .32 ;Print ASCII Space
 PUSH
 FAR_CALL ISR,printch
 goto hlllb51J5
hlllb51J4:
 movlw .42 ;Print ASCII Star
 PUSH
 FAR_CALL ISR,printch
hlllb51J5:
 movlw .0 ;Sample 1st AI Channel
 PUSH
 FAR_CALL ISR,sample
 movlw .128 ;Compare to 128, the midpoint of the "Type U" (i.e. 0-255) scale
 PUSH
 FAR_CALL ISR,geu
 POP
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J6 
 banksel isday
 movfw isday
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J8 
 goto hlllb51J9
hlllb51J8:
 movlw .1 ;isday=1
 banksel isday
 movwf isday
 FAR_CALL ISR,day
 FAR_CALL ISR,mcls
hlllb51J9:
 goto hlllb51J3
hlllb51J6:
 banksel isday
 movfw isday
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J3
 movlw .0 ;isday=0
 banksel isday
 movwf isday
 FAR_CALL ISR,night
 FAR_CALL ISR,mcls
hlllb51J3:
 movlw .5 ;GUI starts at column 5 for station 0
 PUSH
 movlw .55 ;GUI starts at column (55+5) for station 1
 PUSH
 movlw STATNO
 PUSH
 FAR_CALL ISR,mul
 FAR_CALL ISR,add
 movlw .0
 PUSH
 FAR_CALL ISR,sample
 movlw .16 ;Reduce sample from 0-255 to 0-15 by dividing by 16
 PUSH
 FAR_CALL ISR,divu
 FAR_CALL ISR,bigbar
hllnotisr49:
ExitISR: 
 RESUME 
 retfie
mainvars udata_shr 
pbase res .1 ;Used for parameterization facility
pbaseisr res .1 ;Used by interrupt facility
PC_Save res .1
main code
hloego:
 ;Enable _some_ pull-ups
 banksel OPTION_REG 
 bcf OPTION_REG,NOT_RABPU ;¬RABPU bit off -> PU enable
 banksel WPUA
 bcf WPUA,WPUA5 
 bsf WPUA,WPUA4 ;Only BUTTON for now
 bcf WPUA,WPUA2 
 bcf WPUA,WPUA1 
 bcf WPUA,WPUA0 
;UART SETUP
 banksel TXSTA
 bcf TXSTA,SYNC ;async, i.e. timed by bits in the xmit stream
 banksel RCSTA
 banksel RCSTA ;CREN equals one to receive serial data
 bcf RCSTA,CREN ;serves only to clear buffer overrun error
 bsf RCSTA,CREN
 bsf RCSTA,SPEN 
 banksel TXSTA
 bsf TXSTA,TXEN ;enable TX 
 bcf TXSTA,TX9 ;we want 8 bit
 bsf TXSTA,BRGH ;enable *64 baud generator 
 banksel BAUDCTL
 bsf BAUDCTL, BRG16
 bsf BAUDCTL, SCKP ;reverse polarity
 banksel ANSELH 
 clrf ANSELH
 banksel ANSEL
 clrf ANSEL 
 banksel PIE1 
 bcf PIE1,RCIE 
 bcf PIE1,TXIE 
;ADC Setup
 banksel ANSEL
 bsf ANSEL,0 ;AN0 (pin A0) is analog
 bsf ANSEL,1 ;AN1 (pin A1) is analog
 bcf ANSEL,4 ;AN4 (pin A2) is digital
 banksel TRISA
 bsf TRISA,0 ;a0 is an input
 bsf TRISA,1 ;a1 is an input
 bsf TRISA,2 ;a2 is an input
 banksel TRISC
 bsf TRISC,0 ;C0 is an input
 banksel CM1CON0 ;comparator output off
 bcf CM1CON0,C1OE
 ;setup ADCON1 (clk divider for sampling)
 ;adc occurs at 1/32nd of 12mhz clock speed, or 2.666uS per sample (limit is 1.6uS)
 banksel ADCON1
 bcf ADCON1,ADCS2
 bsf ADCON1,ADCS1
 bcf ADCON1,ADCS0
;DAC setup
; (approx. ratio of CCPR1Lx4 ( or more specifically 10-bit numerator) to 
; 4*(PR2+1)) * Vdd is put out on RC5
; This determines denominator... 0 only allows 4 settings 
; (1 would allow 8, 2 allow 16, etc... 255 allows 1024 settings)
 banksel PR2 
 movlw .255 
 movwf PR2
;HLOE SETUP
 bcf INTCON,INTE ;no external interrupt
 clrf INTCON ;disable IOC, all the other interrupts but timers by default
 banksel IOCA
 clrf IOCA
 banksel IOCB
 clrf IOCB
 banksel PIE1
 clrf PIE1
 banksel PIE2
 clrf PIE2
 clrf in_isr
 movlw stack-1 ;Set up stack starting positions detrtmined by incremental linker
 movwf FSR 
 movlw alt_stack-1
 movwf alt_fsr 
 clrf softstack0 
 bankisel stack
 pagesel hlluserprog
 goto hlluserprog
hllupuser CODE
hlluserprog: 
 banksel isday
 clrf isday
 movlw NOT_RABPU
 PUSH
 banksel OPTION_REG
 movfw OPTION_REG
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel OPTION_REG
 movwf OPTION_REG
 movlw BRGH
 PUSH
 banksel TXSTA
 movfw TXSTA
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel TXSTA
 movwf TXSTA
 movlw BRG16
 PUSH
 banksel BAUDCTL
 movfw BAUDCTL
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel BAUDCTL
 movwf BAUDCTL
 movlw .25 ;115,200 BPS
 PUSH
 POP
 banksel SPBRG
 movwf SPBRG
 movlw .0
 PUSH
 POP
 banksel SPBRGH
 movwf SPBRGH
;
; Long, stack-based setup call follows... can be expressed as:
;
;T1CON=clearbit(TMR1CS clearbit(TMR1GE setbit(T1CKPS1 setbit(T1CKPS0 T1CON))));

 ;Set up T1CON
 movlw TMR1CS  ; Use CPU clock
 PUSH
 movlw TMR1GE  ; No gating of timer
 PUSH
 movlw T1CKPS1 ; 8:1 prescaler
 PUSH
 movlw T1CKPS0 ; 8:1 prescaler
 PUSH
 banksel T1CON ; Start with current T1CON
 movfw T1CON
 PUSH
 FAR_CALL hlluserprog,setbit
 FAR_CALL hlluserprog,setbit
 FAR_CALL hlluserprog,clearbit
 FAR_CALL hlluserprog,clearbit
 POP
 banksel T1CON ; Save new T1CON
 movwf T1CON
 ;
 movlw TMR1IE
 PUSH
 banksel PIE1
 movfw PIE1
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel PIE1
 movwf PIE1
 movlw PEIE
 PUSH
 banksel INTCON
 movfw INTCON
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel INTCON
 movwf INTCON
 movlw .0 ;First AI Channel
 PUSH
 FAR_CALL hlluserprog,sample
 movlw STATNO
 PUSH
 movlw .255 ;255/STATIONS is approx. correct value for initial timer countdown hi byte
 PUSH
 movlw STATIONS
 PUSH
 FAR_CALL hlluserprog,divu
 FAR_CALL hlluserprog,mul
 movlw STATNO
 PUSH
 POP
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J12 
 goto hlllb51J13
hlllb51J12:
 FAR_CALL hlluserprog,night
 FAR_CALL hlluserprog,mcls
hlllb51J13:
 FAR_CALL hlluserprog,waitbutton
 movlw TMR1ON
 PUSH
 banksel T1CON
 movfw T1CON
 PUSH
 FAR_CALL hlluserprog,clearbit
 POP
 banksel T1CON
 movwf T1CON
 movlw .0
 PUSH
 POP
 banksel TMR1H
 movwf TMR1H
 movlw .0
 PUSH
 POP
 banksel TMR1L
 movwf TMR1L
 movlw GIE
 PUSH
 banksel INTCON
 movfw INTCON
 PUSH
 FAR_CALL hlluserprog,setbit
 POP
 banksel INTCON
 movwf INTCON
 POP
 banksel TMR1H
 movwf TMR1H
 movlw .127 ;This is ~50% of the possible values... we approx. by "splitting the diff."
 PUSH
 POP
 banksel TMR1L
 movwf TMR1L
 movlw STATNO
 PUSH
 movlw .176 ;Color "01" in the ANSI terminal's 2-bit 80x25 scheme is decimal 176
 PUSH
 FAR_CALL hlluserprog,add
 movlw TMR1ON
 PUSH
 banksel T1CON
 movfw T1CON
 PUSH 
 FAR_CALL hlluserprog,setbit
 POP
 banksel T1CON
 movwf T1CON
hllprogend:
 goto hllprogend
hllt4512 CODE
waitbutton:
 banksel PORTA
 movfw PORTA
 PUSH 
 movlw .16 ;Look for DI "A4" (16=2^4)
 PUSH
 FAR_CALL waitbutton,andu
 POP
 xorlw .0
 btfsc STATUS,Z
 return 
 goto waitbutton 
hllt4515 CODE
bigbar:
 movf FSR,w 
 FAR_CALL bigbar, kpush   ;Push base ptr for calls to parm
;
; Function "bigbar" consists of a series of calls to graphxy
;  (HLOE bargraph function), each taking a form which might
;  be expressed like this:
;
;  graphxy(15,parm(0),parm(1),7); //7 is "Row Number"
;  //...
; 
 movlw .15 ;Bar graph ranges from 0-15 
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1 ;Get second parm from stack top
 PUSH
 FAR_CALL bigbar,parm
 movlw .7 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0 ;Top (first) parm
 PUSH
 FAR_CALL bigbar,parm
 movlw .1 ;Second parm (top+1)
 PUSH
 FAR_CALL bigbar,parm
 movlw .8 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 ;...
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .9 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .11 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .12 ;Row #... etc.
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .13 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph Max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .15 ;Row#
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1  
 PUSH
 FAR_CALL bigbar,parm
 movlw .16 ;Row#
 PUSH
 FAR_CALL bigbar,graphxy
 movlw .15 ;Graph max
 PUSH
 movlw .0
 PUSH
 FAR_CALL bigbar,parm
 movlw .1
 PUSH
 FAR_CALL bigbar,parm
 movlw .17 ;Row #
 PUSH
 FAR_CALL bigbar,graphxy
 FAR_CALL bigbar, kpop  
 movwf FSR ;Load pointer
 DISCARD 
 DISCARD 
 return
hllt4516 CODE
mcls:
 FAR_CALL mcls,cls
 movlw .0
 PUSH
 FAR_CALL mcls,mseed
 return
hllt4517 CODE
mseed:
 movf FSR,w
 FAR_CALL mseed, kpush  ;Push base ptr for calls to parm
 ;printchxy(add( modu(parm(0) 3 )176),modu(parm(0),81),modu(parm(0) 26));
 movlw .0
 PUSH
 FAR_CALL mseed,parm
 movlw .3 ; 3 possibilities, use (X MOD 3)
 PUSH
 FAR_CALL mseed,modu
 movlw .176 ;ANSI box, 2-bit color 01
 PUSH
 FAR_CALL mseed,add
 movlw .0
 PUSH
 FAR_CALL mseed,parm
 movlw .81 ;80 cols + 1
 PUSH
 FAR_CALL mseed,modu
 movlw .0
 PUSH
 FAR_CALL mseed,parm
 movlw .26 ;25 rows + 1
 PUSH
 FAR_CALL mseed,modu
 FAR_CALL mseed,printchxy
 ;
 movlw -.8 ;Stagger "desktop" graphic by this much
 PUSH
 FAR_CALL mseed,add
 movlw .0
 PUSH
 FAR_CALL mseed,parm
 POP
 xorlw .0
 btfsc STATUS,Z
 goto hlllb51J20 
 FAR_CALL mseed, kpop  
 goto mseed 
 goto hlllb51J21
hlllb51J20:
hlllb51J21:
 FAR_CALL mseed, kpop  
 return
hllprgen2:
 goto hllprgen2
 end
