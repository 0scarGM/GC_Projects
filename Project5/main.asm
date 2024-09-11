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
;   Source file      : C:\repos\GC_Projects\Project5\main.gcb
;   Setting file     : C:\GCstudio\gcbasic\use.ini
;   Preserve mode    : 0
;   Assembler        : GCASM
;   Programmer       : C:\GCstudio\gcbasic\..\PICKitPlus\PICKitCommandline.exe
;   Output file      : C:\repos\GC_Projects\Project5\main.asm
;   Float Capability : 0
;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=18F45K50, r=DEC
#include <P18F45K50.inc>
 CONFIG WRTD = OFF, WRTB = OFF, CPD = OFF, XINST = OFF, LVP = OFF, MCLRE = OFF, WDTEN = OFF, FCMEN = ON, FOSC = INTOSCIO, CPUDIV = NOCLKDIV

;********************************************************************************

;Set aside memory locations for variables
DELAYTEMP                        EQU       0          ; 0x0
DELAYTEMP2                       EQU       1          ; 0x1
HI2CACKPOLLSTATE                 EQU       4          ; 0x4
HI2CCURRENTMODE                  EQU       9          ; 0x9
HI2CWAITMSSPTIMEOUT              EQU      10          ; 0xA
HI2C_BAUD_TEMP                   EQU      11          ; 0xB
I2CBYTE                          EQU      12          ; 0xC
I2C_LCD_BYTE                     EQU      13          ; 0xD
LCDBYTE                          EQU      14          ; 0xE
LCD_BACKLIGHT                    EQU      15          ; 0xF
LCD_I2C_ADDRESS_CURRENT          EQU      16          ; 0x10
LCD_STATE                        EQU      17          ; 0x11
PRINTLEN                         EQU      18          ; 0x12
STRINGPOINTER                    EQU      19          ; 0x13
SYSCALCTEMPA                     EQU       5          ; 0x5
SYSLCDTEMP                       EQU      20          ; 0x14
SYSPRINTDATAHANDLER              EQU      21          ; 0x15
SYSPRINTDATAHANDLER_H            EQU      22          ; 0x16
SYSPRINTTEMP                     EQU      23          ; 0x17
SYSREPEATTEMP1                   EQU      24          ; 0x18
SYSSTRINGA                       EQU       7          ; 0x7
SYSSTRINGA_H                     EQU       8          ; 0x8
SYSSTRINGLENGTH                  EQU       6          ; 0x6
SYSSTRINGPARAM1                  EQU    2043          ; 0x7FB
SYSTEMP1                         EQU      25          ; 0x19
SYSWAITTEMPMS                    EQU       2          ; 0x2
SYSWAITTEMPMS_H                  EQU       3          ; 0x3
SYSWAITTEMPUS                    EQU       5          ; 0x5
SYSWAITTEMPUS_H                  EQU       6          ; 0x6

;********************************************************************************

;Alias variables
AFSR0 EQU 4073
AFSR0_H EQU 4074

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
	rcall	NEXUSHARDWARE_INIT
	rcall	HI2CINIT
	rcall	INITLCD

;Start_of_the_main_program
	bsf	TRISB,0,ACCESS
	bsf	TRISB,1,ACCESS
	movlw	12
	movwf	HI2CCURRENTMODE,ACCESS
	rcall	HI2CMODE
SysDoLoop_S1
	rcall	CLS
	lfsr	1,SYSSTRINGPARAM1
	movlw	low StringTable1
	movwf	TBLPTRL,ACCESS
	movlw	high StringTable1
	movwf	TBLPTRH,ACCESS
	rcall	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler,ACCESS
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H,ACCESS
	rcall	PRINT119
	movlw	250
	movwf	SysWaitTempMS,ACCESS
	clrf	SysWaitTempMS_H,ACCESS
	rcall	Delay_MS
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
	movlw	133
	movwf	DELAYTEMP,ACCESS
DelayUS1
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS1
	return

;********************************************************************************

Delay_MS
	incf	SysWaitTempMS_H, F,ACCESS
DMS_START
	movlw	14
	movwf	DELAYTEMP2,ACCESS
DMS_OUTER
	movlw	189
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
	bra	ENDIF17
	bsf	SSPCON1,SSPM3,ACCESS
	bcf	SSPCON1,SSPM2,ACCESS
	bcf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
	movlw	127
	andwf	HI2C_BAUD_TEMP,W,ACCESS
	movwf	SSPADD,ACCESS
ENDIF17
	movf	HI2CCURRENTMODE,F,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF18
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
ENDIF18
	movlw	3
	subwf	HI2CCURRENTMODE,W,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF19
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bsf	SSPCON1,SSPM0,ACCESS
ENDIF19
	bsf	SSPCON1,SSPEN,ACCESS
	return

;********************************************************************************

HI2CSEND
;This method sets the registers and register bits to send I2C data
RETRYHI2CSEND
	bcf	SSPCON1,WCOL,ACCESS
	movff	I2CBYTE,SSPBUF
	rcall	HI2CWAITMSSP
	btfss	SSP1CON2,ACKSTAT,ACCESS
	bra	ELSE22_1
	setf	HI2CACKPOLLSTATE,ACCESS
	bra	ENDIF22
ELSE22_1
	clrf	HI2CACKPOLLSTATE,ACCESS
ENDIF22
	btfss	SSPCON1,WCOL,ACCESS
	bra	ENDIF23
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	RETRYHI2CSEND
ENDIF23
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
	bra	ELSE20_1
	bsf	SSP1CON2,SEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF20
ELSE20_1
SysWaitLoop1
	btfss	SSPSTAT,S,ACCESS
	bra	SysWaitLoop1
ENDIF20
	return

;********************************************************************************

HI2CSTOP
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	ELSE21_1
SysWaitLoop2
	btfsc	SSP1STAT,R_NOT_W,ACCESS
	bra	SysWaitLoop2
	bsf	SSPCON2,PEN,ACCESS
	bsf	SSPCON2,PEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF21
ELSE21_1
SysWaitLoop3
	btfss	SSPSTAT,P,ACCESS
	bra	SysWaitLoop3
ENDIF21
	return

;********************************************************************************

HI2CWAITMSSP
	clrf	HI2CWAITMSSPTIMEOUT,ACCESS
HI2CWAITMSSPWAIT
	incf	HI2CWAITMSSPTIMEOUT,F,ACCESS
	movlw	255
	subwf	HI2CWAITMSSPTIMEOUT,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF26
	btfsc	PIR1,SSP1IF,ACCESS
	bra	ENDIF28
	movlw	5
	movwf	DELAYTEMP,ACCESS
DelayUS3
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS3
	bra	HI2CWAITMSSPWAIT
ENDIF28
	bcf	PIR1,SSP1IF,ACCESS
ENDIF26
	incf	HI2CWAITMSSPTIMEOUT,W,ACCESS
	btfsc	STATUS, Z,ACCESS
	bcf	PIR2,BCL1IF,ACCESS
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
	bsf	OSCCON,IRCF2,ACCESS
	bsf	OSCCON,IRCF1,ACCESS
	bcf	OSCCON,IRCF0,ACCESS
	bsf	OSCCON2,PLLEN,ACCESS
	bcf	OSCTUNE,SPLLMULT,ACCESS
;_Complete_the_chip_setup_of_BSR_ADCs_ANSEL_and_other_key_setup_registers_or_register_bits
	clrf	TBLPTRU,ACCESS
	bcf	ADCON2,ADFM,ACCESS
	bcf	ADCON0,ADON,ACCESS
	banksel	ANSELA
	clrf	ANSELA,BANKED
	clrf	ANSELB,BANKED
	clrf	ANSELC,BANKED
	clrf	ANSELD,BANKED
	clrf	ANSELE,BANKED
	bcf	CM2CON0,C2ON,ACCESS
	bcf	CM1CON0,C1ON,ACCESS
	clrf	PORTA,ACCESS
	clrf	PORTB,ACCESS
	clrf	PORTC,ACCESS
	clrf	PORTD,ACCESS
	clrf	PORTE,ACCESS
	banksel	0
	return

;********************************************************************************

LCDNORMALWRITEBYTE
	btfss	SYSLCDTEMP,1,ACCESS
	bra	ELSE4_1
	bsf	I2C_LCD_BYTE,0,ACCESS
	bra	ENDIF4
ELSE4_1
	bcf	I2C_LCD_BYTE,0,ACCESS
ENDIF4
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
	movlw	26
	movwf	DELAYTEMP,ACCESS
DelayUS2
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS2
	nop
	btfsc	SYSLCDTEMP,1,ACCESS
	bra	ENDIF5
	movlw	16
	subwf	LCDBYTE,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF6
	movf	LCDBYTE,W,ACCESS
	sublw	7
	btfss	STATUS, C,ACCESS
	movff	LCDBYTE,LCD_STATE
ENDIF6
ENDIF5
	return

;********************************************************************************

NEXUSHARDWARE_INIT
	return

;********************************************************************************

PRINT119
	movff	SysPRINTDATAHandler,AFSR0
	movff	SysPRINTDATAHandler_H,AFSR0_H
	movff	INDF0,PRINTLEN
	movf	PRINTLEN,F,ACCESS
	btfsc	STATUS, Z,ACCESS
	return
	bsf	SYSLCDTEMP,1,ACCESS
	clrf	SYSPRINTTEMP,ACCESS
	movlw	1
	subwf	PRINTLEN,W,ACCESS
	btfss	STATUS, C,ACCESS
	bra	SysForLoopEnd1
SysForLoop1
	incf	SYSPRINTTEMP,F,ACCESS
	movf	SYSPRINTTEMP,W,ACCESS
	addwf	SysPRINTDATAHandler,W,ACCESS
	movwf	AFSR0,ACCESS
	movlw	0
	addwfc	SysPRINTDATAHandler_H,W,ACCESS
	movwf	AFSR0_H,ACCESS
	movff	INDF0,LCDBYTE
	rcall	LCDNORMALWRITEBYTE
	movf	PRINTLEN,W,ACCESS
	subwf	SYSPRINTTEMP,W,ACCESS
	btfss	STATUS, C,ACCESS
	bra	SysForLoop1
SysForLoopEnd1
	return

;********************************************************************************

SYSREADSTRING
	tblrd*+
	movff	TABLAT,SYSCALCTEMPA
	movff	TABLAT,INDF1
	bra	SYSSTRINGREADCHECK
SYSREADSTRINGPART
	tblrd*+
	movf	TABLAT, W,ACCESS
	movwf	SYSCALCTEMPA,ACCESS
	addwf	SYSSTRINGLENGTH,F,ACCESS
SYSSTRINGREADCHECK
	movf	SYSCALCTEMPA,F,ACCESS
	btfsc	STATUS,Z,ACCESS
	return
SYSSTRINGREAD
	tblrd*+
	movff	TABLAT,PREINC1
	decfsz	SYSCALCTEMPA, F,ACCESS
	bra	SYSSTRINGREAD
	return

;********************************************************************************

SysStringTables

StringTable1
	db	4,104,111,108,97


;********************************************************************************


 END
