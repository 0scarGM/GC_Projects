;Program compiled by GCBASIC (2024.08.18 (Windows 64 bit) : Build 1411) for Microchip MPASM/MPLAB-X Assembler using FreeBASIC 1.07.1/2024-08-20 CRC248
;Need help? 
;  Please donate to help support the operational costs of the project.  Donate via http://paypal.me/gcbasic
;  
;  See the GCBASIC forums at http://sourceforge.net/projects/gcbasic/forums,
;  Check the documentation and Help at http://gcbasic.sourceforge.net/help/,
;or, email us:
;   w_cholmondeley at users dot sourceforge dot net
;   evanvennn at users dot sourceforge dot net
;********************************************************************************
;   Installation Dir : C:\GCstudio\gcbasic
;   Source file      : C:\Users\osccar\Desktop\Project1\main.gcb
;   Setting file     : C:\GCstudio\gcbasic\use.ini
;   Preserve mode    : 0
;   Assembler        : GCASM
;   Programmer       : 
;   Output file      : C:\Users\osccar\Desktop\Project1\main.asm
;   Float Capability : 0
;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=18F4550, r=DEC
#include <P18F4550.inc>
 CONFIG WRTD = OFF, WRTB = OFF, CPD = OFF, XINST = OFF, LVP = OFF, MCLRE = OFF, WDT = OFF, FCMEN = ON, FOSC = INTOSCIO_EC

;********************************************************************************

;Set aside memory locations for variables
DELAYTEMP                        EQU       0          ; 0x0
DELAYTEMP2                       EQU       1          ; 0x1
HI2CACKPOLLSTATE                 EQU       7          ; 0x7
HI2CCURRENTMODE                  EQU       8          ; 0x8
HI2CWAITMSSPTIMEOUT              EQU      10          ; 0xA
I2CBYTE                          EQU      11          ; 0xB
I2C_LCD_BYTE                     EQU      12          ; 0xC
LCDBYTE                          EQU      13          ; 0xD
LCDTEMP                          EQU      14          ; 0xE
LCDVALUE                         EQU      15          ; 0xF
LCDVALUETEMP                     EQU      16          ; 0x10
LCD_BACKLIGHT                    EQU      17          ; 0x11
LCD_I2C_ADDRESS_CURRENT          EQU      18          ; 0x12
LCD_STATE                        EQU      19          ; 0x13
NUM                              EQU      20          ; 0x14
SYSBYTETEMPA                     EQU       5          ; 0x5
SYSBYTETEMPB                     EQU       9          ; 0x9
SYSBYTETEMPX                     EQU       0          ; 0x0
SYSCALCTEMPX                     EQU       0          ; 0x0
SYSDIVLOOP                       EQU       4          ; 0x4
SYSLCDTEMP                       EQU      21          ; 0x15
SYSREPEATTEMP1                   EQU      22          ; 0x16
SYSTEMP1                         EQU      23          ; 0x17
SYSTEMP2                         EQU      24          ; 0x18
SYSWAITTEMPMS                    EQU       2          ; 0x2
SYSWAITTEMPMS_H                  EQU       3          ; 0x3
SYSWAITTEMPS                     EQU       4          ; 0x4
SYSWAITTEMPUS                    EQU       5          ; 0x5
SYSWAITTEMPUS_H                  EQU       6          ; 0x6

;********************************************************************************

;Vectors
	ORG	0
	goto	BASPROGRAMSTART
	ORG	8
	retfie

;********************************************************************************

;Program_memory_page: 0
	ORG	12
BASPROGRAMSTART
;Call initialisation routines
	rcall	INITSYS
	rcall	HI2CINIT
	rcall	INITLCD
;Automatic pin direction setting
	bcf	TRISB,5,ACCESS
	bcf	TRISB,4,ACCESS

;Start_of_the_main_program
	bsf	TRISB,0,ACCESS
	bsf	TRISB,1,ACCESS
	movlw	12
	movwf	HI2CCURRENTMODE,ACCESS
	rcall	HI2CMODE
SysDoLoop_S1
	rcall	CLS
	incf	NUM,F,ACCESS
	movff	NUM,LCDVALUE
	rcall	PRINT117
	bsf	LATB,4,ACCESS
	movlw	1
	movwf	SysWaitTempS,ACCESS
	rcall	Delay_S
	bcf	LATB,4,ACCESS
	movlw	1
	movwf	SysWaitTempS,ACCESS
	rcall	Delay_S
	movlw	1
	movwf	LCDTEMP,ACCESS
	rcall	LCDBACKLIGHT
	bsf	LATB,5,ACCESS
	movlw	1
	movwf	SysWaitTempS,ACCESS
	rcall	Delay_S
	bcf	LATB,5,ACCESS
	movlw	1
	movwf	SysWaitTempS,ACCESS
	rcall	Delay_S
	clrf	LCDTEMP,ACCESS
	rcall	LCDBACKLIGHT
	bra	SysDoLoop_S1
SysDoLoop_E1
BASPROGRAMEND
	sleep
	bra	BASPROGRAMEND

;********************************************************************************

CLS
	bcf	SYSLCDTEMP,1,ACCESS
	movlw	1
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	4
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	128
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	33
	movwf	DELAYTEMP,ACCESS
DelayUS1
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS1
	return

;********************************************************************************

Delay_MS
	incf	SysWaitTempMS_H, F,ACCESS
DMS_START
	movlw	4
	movwf	DELAYTEMP2,ACCESS
DMS_OUTER
	movlw	165
	movwf	DELAYTEMP,ACCESS
DMS_INNER
	decfsz	DELAYTEMP, F,ACCESS
	bra	DMS_INNER
	decfsz	DELAYTEMP2, F,ACCESS
	bra	DMS_OUTER
	decfsz	SysWaitTempMS, F,ACCESS
	bra	DMS_START
	decfsz	SysWaitTempMS_H, F,ACCESS
	bra	DMS_START
	return

;********************************************************************************

Delay_S
DS_START
	movlw	232
	movwf	SysWaitTempMS,ACCESS
	movlw	3
	movwf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	decfsz	SysWaitTempS, F,ACCESS
	bra	DS_START
	return

;********************************************************************************

HI2CINIT
;This method sets the variable `HI2CCurrentMode`, and, if required calls the method `SI2CInit` to set up new MSSP modules - aka K-Mode family chips
	clrf	HI2CCURRENTMODE,ACCESS
	return

;********************************************************************************

HI2CMODE
;This method sets the variable `HI2CCurrentMode`, and, if required, sets the SSPCON1.bits
	bsf	SSPSTAT,SMP,ACCESS
	bsf	SSPCON1,CKP,ACCESS
	bcf	SSPCON1,WCOL,ACCESS
	movlw	12
	subwf	HI2CCURRENTMODE,W,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF18
	bsf	SSPCON1,SSPM3,ACCESS
	bcf	SSPCON1,SSPM2,ACCESS
	bcf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
	movlw	4
	movwf	SSPADD,ACCESS
ENDIF18
	movf	HI2CCURRENTMODE,F,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF19
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
ENDIF19
	movlw	3
	subwf	HI2CCURRENTMODE,W,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF20
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bsf	SSPCON1,SSPM0,ACCESS
ENDIF20
	bsf	SSPCON1,SSPEN,ACCESS
	return

;********************************************************************************

HI2CSEND
;This method sets the registers and register bits to send I2C data
RETRYHI2CSEND
	bcf	SSPCON1,WCOL,ACCESS
	movff	I2CBYTE,SSPBUF
	rcall	HI2CWAITMSSP
	btfss	SSPCON2,ACKSTAT,ACCESS
	bra	ELSE23_1
	setf	HI2CACKPOLLSTATE,ACCESS
	bra	ENDIF23
ELSE23_1
	clrf	HI2CACKPOLLSTATE,ACCESS
ENDIF23
	btfss	SSPCON1,WCOL,ACCESS
	bra	ENDIF24
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	RETRYHI2CSEND
ENDIF24
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bsf	SSPCON1,CKP,ACCESS
	return

;********************************************************************************

HI2CSTART
;This method sets the registers and register bits to generate the I2C  START signal
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	ELSE21_1
	bsf	SSPCON2,SEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF21
ELSE21_1
SysWaitLoop1
	btfss	SSPSTAT,S,ACCESS
	bra	SysWaitLoop1
ENDIF21
	return

;********************************************************************************

HI2CSTOP
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	ELSE22_1
SysWaitLoop2
	btfsc	SSPSTAT,R_NOT_W,ACCESS
	bra	SysWaitLoop2
	bsf	SSPCON2,PEN,ACCESS
	bsf	SSPCON2,PEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF22
ELSE22_1
SysWaitLoop3
	btfss	SSPSTAT,P,ACCESS
	bra	SysWaitLoop3
ENDIF22
	return

;********************************************************************************

HI2CWAITMSSP
	clrf	HI2CWAITMSSPTIMEOUT,ACCESS
HI2CWAITMSSPWAIT
	incf	HI2CWAITMSSPTIMEOUT,F,ACCESS
	movlw	255
	subwf	HI2CWAITMSSPTIMEOUT,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF27
	btfsc	PIR1,SSPIF,ACCESS
	bra	ENDIF28
	nop
	nop
	nop
	nop
	bra	HI2CWAITMSSPWAIT
ENDIF28
	bcf	PIR1,SSPIF,ACCESS
ENDIF27
	return

;********************************************************************************

INITI2CLCD
	movlw	15
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	clrf	I2C_LCD_BYTE,ACCESS
	movlw	3
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	5
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	3
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	3
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	3
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	2
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	40
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	12
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	1
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	15
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	6
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	movlw	1
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	bra	CLS

;********************************************************************************

INITLCD
;`LCD_IO selected is ` LCD_IO
;`LCD_Speed is FAST`
;`OPTIMAL is set to ` OPTIMAL
;`LCD_Speed is set to ` LCD_Speed
	movlw	12
	movwf	HI2CCURRENTMODE,ACCESS
	rcall	HI2CMODE
	movlw	1
	movwf	LCD_BACKLIGHT,ACCESS
	movlw	2
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
	movlw	2
	movwf	SysRepeatTemp1,ACCESS
SysRepeatLoop1
	movlw	78
	movwf	LCD_I2C_ADDRESS_CURRENT,ACCESS
	rcall	INITI2CLCD
	decfsz	SysRepeatTemp1,F,ACCESS
	bra	SysRepeatLoop1
SysRepeatLoopEnd1
	movlw	12
	movwf	LCD_STATE,ACCESS
	return

;********************************************************************************

INITSYS
	movlb	0
;OSCCON type is 104' NoBit(SPLLEN) And NoBit(IRCF3) Or Bit(INTSRC)) and ifdef Bit(HFIOFS)
	movlw	143
	andwf	OSCCON,F,ACCESS
	bsf	OSCCON,IRCF2,ACCESS
	bsf	OSCCON,IRCF1,ACCESS
	bsf	OSCCON,IRCF0,ACCESS
;_Complete_the_chip_setup_of_BSR_ADCs_ANSEL_and_other_key_setup_registers_or_register_bits
	clrf	TBLPTRU,ACCESS
	bcf	ADCON2,ADFM,ACCESS
	bcf	ADCON0,ADON,ACCESS
	bsf	ADCON1,PCFG3,ACCESS
	bsf	ADCON1,PCFG2,ACCESS
	bsf	ADCON1,PCFG1,ACCESS
	bsf	ADCON1,PCFG0,ACCESS
	movlw	7
	movwf	CMCON,ACCESS
	clrf	PORTA,ACCESS
	clrf	PORTB,ACCESS
	clrf	PORTC,ACCESS
	clrf	PORTD,ACCESS
	clrf	PORTE,ACCESS
	return

;********************************************************************************

LCDBACKLIGHT
	movf	LCDTEMP,F,ACCESS
	btfsc	STATUS, Z,ACCESS
	clrf	LCD_BACKLIGHT,ACCESS
	decf	LCDTEMP,W,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF17
	movlw	1
	movwf	LCD_BACKLIGHT,ACCESS
ENDIF17
	bcf	SYSLCDTEMP,1,ACCESS
	clrf	LCDBYTE,ACCESS
	bra	LCDNORMALWRITEBYTE

;********************************************************************************

LCDNORMALWRITEBYTE
	btfss	SYSLCDTEMP,1,ACCESS
	bra	ELSE3_1
	bsf	I2C_LCD_BYTE,0,ACCESS
	bra	ENDIF3
ELSE3_1
	bcf	I2C_LCD_BYTE,0,ACCESS
ENDIF3
	bcf	I2C_LCD_BYTE,1,ACCESS
	bcf	I2C_LCD_BYTE,3,ACCESS
	btfsc	LCD_BACKLIGHT,0,ACCESS
	bsf	I2C_LCD_BYTE,3,ACCESS
	rcall	HI2CSTART
	movff	LCD_I2C_ADDRESS_CURRENT,I2CBYTE
	rcall	HI2CSEND
	bcf	I2C_LCD_BYTE,7,ACCESS
	btfsc	LCDBYTE,7,ACCESS
	bsf	I2C_LCD_BYTE,7,ACCESS
	bcf	I2C_LCD_BYTE,6,ACCESS
	btfsc	LCDBYTE,6,ACCESS
	bsf	I2C_LCD_BYTE,6,ACCESS
	bcf	I2C_LCD_BYTE,5,ACCESS
	btfsc	LCDBYTE,5,ACCESS
	bsf	I2C_LCD_BYTE,5,ACCESS
	bcf	I2C_LCD_BYTE,4,ACCESS
	btfsc	LCDBYTE,4,ACCESS
	bsf	I2C_LCD_BYTE,4,ACCESS
	bsf	I2C_LCD_BYTE,2,ACCESS
	movff	I2C_LCD_BYTE,I2CBYTE
	rcall	HI2CSEND
	bcf	I2C_LCD_BYTE,2,ACCESS
	movff	I2C_LCD_BYTE,I2CBYTE
	rcall	HI2CSEND
	bcf	I2C_LCD_BYTE,7,ACCESS
	btfsc	LCDBYTE,3,ACCESS
	bsf	I2C_LCD_BYTE,7,ACCESS
	bcf	I2C_LCD_BYTE,6,ACCESS
	btfsc	LCDBYTE,2,ACCESS
	bsf	I2C_LCD_BYTE,6,ACCESS
	bcf	I2C_LCD_BYTE,5,ACCESS
	btfsc	LCDBYTE,1,ACCESS
	bsf	I2C_LCD_BYTE,5,ACCESS
	bcf	I2C_LCD_BYTE,4,ACCESS
	btfsc	LCDBYTE,0,ACCESS
	bsf	I2C_LCD_BYTE,4,ACCESS
	bsf	I2C_LCD_BYTE,2,ACCESS
	movff	I2C_LCD_BYTE,I2CBYTE
	rcall	HI2CSEND
	bcf	I2C_LCD_BYTE,2,ACCESS
	movff	I2C_LCD_BYTE,I2CBYTE
	rcall	HI2CSEND
	rcall	HI2CSTOP
	movlw	12
	movwf	LCD_STATE,ACCESS
	movlw	6
	movwf	DELAYTEMP,ACCESS
DelayUS2
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS2
	nop
	btfsc	SYSLCDTEMP,1,ACCESS
	bra	ENDIF4
	movlw	16
	subwf	LCDBYTE,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF5
	movf	LCDBYTE,W,ACCESS
	sublw	7
	btfss	STATUS, C,ACCESS
	movff	LCDBYTE,LCD_STATE
ENDIF5
ENDIF4
	return

;********************************************************************************

PRINT117
	clrf	LCDVALUETEMP,ACCESS
	bsf	SYSLCDTEMP,1,ACCESS
	movlw	100
	subwf	LCDVALUE,W,ACCESS
	btfss	STATUS, C,ACCESS
	bra	ENDIF1
	movff	LCDVALUE,SysBYTETempA
	movlw	100
	movwf	SysBYTETempB,ACCESS
	rcall	SYSDIVSUB
	movff	SysBYTETempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
ENDIF1
	movff	LCDVALUETEMP,SysBYTETempB
	clrf	SysBYTETempA,ACCESS
	rcall	SYSCOMPLESSTHAN
	movff	SysByteTempX,SysTemp1
	movff	LCDVALUE,SysBYTETempA
	movlw	10
	movwf	SysBYTETempB,ACCESS
	rcall	SYSCOMPLESSTHAN
	comf	SysByteTempX,F,ACCESS
	movf	SysTemp1,W,ACCESS
	iorwf	SysByteTempX,W,ACCESS
	movwf	SysTemp2,ACCESS
	btfss	SysTemp2,0,ACCESS
	bra	ENDIF2
	movff	LCDVALUE,SysBYTETempA
	movlw	10
	movwf	SysBYTETempB,ACCESS
	rcall	SYSDIVSUB
	movff	SysBYTETempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
ENDIF2
	movlw	48
	addwf	LCDVALUE,W,ACCESS
	movwf	LCDBYTE,ACCESS
	bra	LCDNORMALWRITEBYTE

;********************************************************************************

SYSCOMPLESSTHAN
	setf	SYSBYTETEMPX,ACCESS
	movf	SYSBYTETEMPB, W,ACCESS
	cpfslt	SYSBYTETEMPA,ACCESS
	clrf	SYSBYTETEMPX,ACCESS
	return

;********************************************************************************

SYSDIVSUB
	movf	SYSBYTETEMPB, F,ACCESS
	btfsc	STATUS, Z,ACCESS
	return
	clrf	SYSBYTETEMPX,ACCESS
	movlw	8
	movwf	SYSDIVLOOP,ACCESS
SYSDIV8START
	bcf	STATUS, C,ACCESS
	rlcf	SYSBYTETEMPA, F,ACCESS
	rlcf	SYSBYTETEMPX, F,ACCESS
	movf	SYSBYTETEMPB, W,ACCESS
	subwf	SYSBYTETEMPX, F,ACCESS
	bsf	SYSBYTETEMPA, 0,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	DIV8NOTNEG
	bcf	SYSBYTETEMPA, 0,ACCESS
	movf	SYSBYTETEMPB, W,ACCESS
	addwf	SYSBYTETEMPX, F,ACCESS
DIV8NOTNEG
	decfsz	SYSDIVLOOP, F,ACCESS
	bra	SYSDIV8START
	return

;********************************************************************************


 END
