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
;   Source file      : C:\Users\osccar\Desktop\Project3\main.gcb
;   Setting file     : C:\GCstudio\gcbasic\use.ini
;   Preserve mode    : 0
;   Assembler        : GCASM
;   Programmer       : C:\GCstudio\gcbasic\..\PICKitPlus\PICKitCommandline.exe
;   Output file      : C:\Users\osccar\Desktop\Project3\main.asm
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
HI2CACKPOLLSTATE                 EQU      13          ; 0xD
HI2CCURRENTMODE                  EQU      14          ; 0xE
HI2CWAITMSSPTIMEOUT              EQU      15          ; 0xF
I                                EQU      16          ; 0x10
I2CBYTE                          EQU      18          ; 0x12
I2C_LCD_BYTE                     EQU      19          ; 0x13
I_H                              EQU      17          ; 0x11
LCDBYTE                          EQU      20          ; 0x14
LCDVALUE                         EQU      21          ; 0x15
LCDVALUETEMP                     EQU      23          ; 0x17
LCDVALUE_H                       EQU      22          ; 0x16
LCD_BACKLIGHT                    EQU      24          ; 0x18
LCD_I2C_ADDRESS_CURRENT          EQU      25          ; 0x19
LCD_STATE                        EQU      26          ; 0x1A
PRINTLEN                         EQU      27          ; 0x1B
STRINGPOINTER                    EQU      28          ; 0x1C
SYSBITVAR0                       EQU      29          ; 0x1D
SYSBYTETEMPX                     EQU       0          ; 0x0
SYSCALCTEMPA                     EQU       5          ; 0x5
SYSCALCTEMPX                     EQU       0          ; 0x0
SYSCALCTEMPX_H                   EQU       1          ; 0x1
SYSDIVLOOP                       EQU       4          ; 0x4
SYSDIVMULTA                      EQU       7          ; 0x7
SYSDIVMULTA_H                    EQU       8          ; 0x8
SYSDIVMULTB                      EQU      11          ; 0xB
SYSDIVMULTB_H                    EQU      12          ; 0xC
SYSDIVMULTX                      EQU       2          ; 0x2
SYSDIVMULTX_H                    EQU       3          ; 0x3
SYSLCDTEMP                       EQU      30          ; 0x1E
SYSPRINTDATAHANDLER              EQU      31          ; 0x1F
SYSPRINTDATAHANDLER_H            EQU      32          ; 0x20
SYSPRINTTEMP                     EQU      33          ; 0x21
SYSREPEATTEMP1                   EQU      34          ; 0x22
SYSSTRINGA                       EQU       7          ; 0x7
SYSSTRINGA_H                     EQU       8          ; 0x8
SYSSTRINGLENGTH                  EQU       6          ; 0x6
SYSSTRINGPARAM1                  EQU    2026          ; 0x7EA
SYSTEMP1                         EQU      35          ; 0x23
SYSTEMP1_H                       EQU      36          ; 0x24
SYSTEMP2                         EQU      37          ; 0x25
SYSWAITTEMPMS                    EQU       2          ; 0x2
SYSWAITTEMPMS_H                  EQU       3          ; 0x3
SYSWAITTEMPUS                    EQU       5          ; 0x5
SYSWAITTEMPUS_H                  EQU       6          ; 0x6
SYSWORDTEMPA                     EQU       5          ; 0x5
SYSWORDTEMPA_H                   EQU       6          ; 0x6
SYSWORDTEMPB                     EQU       9          ; 0x9
SYSWORDTEMPB_H                   EQU      10          ; 0xA
SYSWORDTEMPX                     EQU       0          ; 0x0
SYSWORDTEMPX_H                   EQU       1          ; 0x1

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
	rcall	HI2CINIT
	rcall	INITLCD

;Start_of_the_main_program
	bsf	TRISB,0,ACCESS
	bsf	TRISB,1,ACCESS
	movlw	12
	movwf	HI2CCURRENTMODE,ACCESS
	rcall	HI2CMODE
	bsf	TRISC,6,ACCESS
	bcf	TRISC,7,ACCESS
	bcf	LATC,7,ACCESS
	bcf	SYSBITVAR0,0,ACCESS
	clrf	I,ACCESS
	clrf	I_H,ACCESS
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
	rcall	PRINT116
SysDoLoop_S1
	bsf	LATC,7,ACCESS
	movlw	6
	movwf	DELAYTEMP,ACCESS
DelayUS1
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS1
	nop
	bcf	LATC,7,ACCESS
SysDoLoop_S2
	btfsc	PORTC,6,ACCESS
	bra	SysDoLoop_E2
	nop
	bra	SysDoLoop_S2
SysDoLoop_E2
SysDoLoop_S3
	clrf	SysByteTempX,ACCESS
	btfss	portc,6,ACCESS
	comf	SysByteTempX,F,ACCESS
	movff	SysByteTempX,SysTemp1
	clrf	SysByteTempX,ACCESS
	btfsc	sysbitvar0,0,ACCESS
	comf	SysByteTempX,F,ACCESS
	movf	SysTemp1,W,ACCESS
	iorwf	SysByteTempX,W,ACCESS
	movwf	SysTemp2,ACCESS
	btfsc	SysTemp2,0,ACCESS
	bra	SysDoLoop_E3
	movlw	66
	movwf	DELAYTEMP,ACCESS
DelayUS2
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS2
	nop
	incf	I,F,ACCESS
	btfsc	STATUS,Z,ACCESS
	incf	I_H,F,ACCESS
	movff	I,SysWORDTempA
	movff	I_H,SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB,ACCESS
	movlw	3
	movwf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPEQUAL16
	btfsc	SysByteTempX,0,ACCESS
	bsf	SYSBITVAR0,0,ACCESS
	bra	SysDoLoop_S3
SysDoLoop_E3
	bsf	LATC,7,ACCESS
	btfsc	SYSBITVAR0,0,ACCESS
	bra	ELSE2_1
	rcall	CLS
	lfsr	1,SYSSTRINGPARAM1
	movlw	low StringTable2
	movwf	TBLPTRL,ACCESS
	movlw	high StringTable2
	movwf	TBLPTRH,ACCESS
	rcall	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler,ACCESS
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H,ACCESS
	rcall	PRINT116
	movff	I,LCDVALUE
	movff	I_H,LCDVALUE_H
	rcall	PRINT118
	bra	ENDIF2
ELSE2_1
	rcall	CLS
	lfsr	1,SYSSTRINGPARAM1
	movlw	low StringTable3
	movwf	TBLPTRL,ACCESS
	movlw	high StringTable3
	movwf	TBLPTRH,ACCESS
	rcall	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler,ACCESS
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H,ACCESS
	rcall	PRINT116
	rcall	CLS
ENDIF2
	bcf	SYSBITVAR0,0,ACCESS
	clrf	I,ACCESS
	clrf	I_H,ACCESS
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
	movlw	33
	movwf	DELAYTEMP,ACCESS
DelayUS3
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS3
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
	bra	ENDIF25
	bsf	SSPCON1,SSPM3,ACCESS
	bcf	SSPCON1,SSPM2,ACCESS
	bcf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
	movlw	4
	movwf	SSPADD,ACCESS
ENDIF25
	movf	HI2CCURRENTMODE,F,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF26
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bcf	SSPCON1,SSPM0,ACCESS
ENDIF26
	movlw	3
	subwf	HI2CCURRENTMODE,W,ACCESS
	btfss	STATUS, Z,ACCESS
	bra	ENDIF27
	bcf	SSPCON1,SSPM3,ACCESS
	bsf	SSPCON1,SSPM2,ACCESS
	bsf	SSPCON1,SSPM1,ACCESS
	bsf	SSPCON1,SSPM0,ACCESS
ENDIF27
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
	bra	ELSE30_1
	setf	HI2CACKPOLLSTATE,ACCESS
	bra	ENDIF30
ELSE30_1
	clrf	HI2CACKPOLLSTATE,ACCESS
ENDIF30
	btfss	SSPCON1,WCOL,ACCESS
	bra	ENDIF31
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	RETRYHI2CSEND
ENDIF31
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
	bra	ELSE28_1
	bsf	SSPCON2,SEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF28
ELSE28_1
SysWaitLoop1
	btfss	SSPSTAT,S,ACCESS
	bra	SysWaitLoop1
ENDIF28
	return

;********************************************************************************

HI2CSTOP
	movf	HI2CCURRENTMODE,W,ACCESS
	sublw	10
	btfsc	STATUS, C,ACCESS
	bra	ELSE29_1
SysWaitLoop2
	btfsc	SSPSTAT,R_NOT_W,ACCESS
	bra	SysWaitLoop2
	bsf	SSPCON2,PEN,ACCESS
	bsf	SSPCON2,PEN,ACCESS
	rcall	HI2CWAITMSSP
	bra	ENDIF29
ELSE29_1
SysWaitLoop3
	btfss	SSPSTAT,P,ACCESS
	bra	SysWaitLoop3
ENDIF29
	return

;********************************************************************************

HI2CWAITMSSP
	clrf	HI2CWAITMSSPTIMEOUT,ACCESS
HI2CWAITMSSPWAIT
	incf	HI2CWAITMSSPTIMEOUT,F,ACCESS
	movlw	255
	subwf	HI2CWAITMSSPTIMEOUT,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF34
	btfsc	PIR1,SSPIF,ACCESS
	bra	ENDIF35
	nop
	nop
	nop
	nop
	bra	HI2CWAITMSSPWAIT
ENDIF35
	bcf	PIR1,SSPIF,ACCESS
ENDIF34
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

LCDNORMALWRITEBYTE
	btfss	SYSLCDTEMP,1,ACCESS
	bra	ELSE10_1
	bsf	I2C_LCD_BYTE,0,ACCESS
	bra	ENDIF10
ELSE10_1
	bcf	I2C_LCD_BYTE,0,ACCESS
ENDIF10
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
DelayUS4
	decfsz	DELAYTEMP,F,ACCESS
	bra	DelayUS4
	nop
	btfsc	SYSLCDTEMP,1,ACCESS
	bra	ENDIF11
	movlw	16
	subwf	LCDBYTE,W,ACCESS
	btfsc	STATUS, C,ACCESS
	bra	ENDIF12
	movf	LCDBYTE,W,ACCESS
	sublw	7
	btfss	STATUS, C,ACCESS
	movff	LCDBYTE,LCD_STATE
ENDIF12
ENDIF11
	return

;********************************************************************************

PRINT116
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

PRINT118
	bsf	SYSLCDTEMP,1,ACCESS
	clrf	LCDVALUETEMP,ACCESS
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	16
	movwf	SysWORDTempB,ACCESS
	movlw	39
	movwf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPLESSTHAN16
	comf	SysByteTempX,F,ACCESS
	btfss	SysByteTempX,0,ACCESS
	bra	ENDIF6
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	16
	movwf	SysWORDTempB,ACCESS
	movlw	39
	movwf	SysWORDTempB_H,ACCESS
	rcall	SYSDIVSUB16
	movff	SysWORDTempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movff	SYSCALCTEMPX_H,LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	bra	LCDPRINTWORD1000
ENDIF6
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB,ACCESS
	movlw	3
	movwf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPLESSTHAN16
	comf	SysByteTempX,F,ACCESS
	btfss	SysByteTempX,0,ACCESS
	bra	ENDIF7
LCDPRINTWORD1000
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB,ACCESS
	movlw	3
	movwf	SysWORDTempB_H,ACCESS
	rcall	SYSDIVSUB16
	movff	SysWORDTempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movff	SYSCALCTEMPX_H,LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	bra	LCDPRINTWORD100
ENDIF7
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB,ACCESS
	clrf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPLESSTHAN16
	comf	SysByteTempX,F,ACCESS
	btfss	SysByteTempX,0,ACCESS
	bra	ENDIF8
LCDPRINTWORD100
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB,ACCESS
	clrf	SysWORDTempB_H,ACCESS
	rcall	SYSDIVSUB16
	movff	SysWORDTempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movff	SYSCALCTEMPX_H,LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
	bra	LCDPRINTWORD10
ENDIF8
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB,ACCESS
	clrf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPLESSTHAN16
	comf	SysByteTempX,F,ACCESS
	btfss	SysByteTempX,0,ACCESS
	bra	ENDIF9
LCDPRINTWORD10
	movff	LCDVALUE,SysWORDTempA
	movff	LCDVALUE_H,SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB,ACCESS
	clrf	SysWORDTempB_H,ACCESS
	rcall	SYSDIVSUB16
	movff	SysWORDTempA,LCDVALUETEMP
	movff	SYSCALCTEMPX,LCDVALUE
	movff	SYSCALCTEMPX_H,LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W,ACCESS
	movwf	LCDBYTE,ACCESS
	rcall	LCDNORMALWRITEBYTE
ENDIF9
	movlw	48
	addwf	LCDVALUE,W,ACCESS
	movwf	LCDBYTE,ACCESS
	bra	LCDNORMALWRITEBYTE

;********************************************************************************

SYSCOMPEQUAL16
	clrf	SYSBYTETEMPX,ACCESS
	movf	SYSWORDTEMPB, W,ACCESS
	cpfseq	SYSWORDTEMPA,ACCESS
	return
	movf	SYSWORDTEMPB_H, W,ACCESS
	cpfseq	SYSWORDTEMPA_H,ACCESS
	return
	setf	SYSBYTETEMPX,ACCESS
	return

;********************************************************************************

SYSCOMPLESSTHAN16
	clrf	SYSBYTETEMPX,ACCESS
	movf	SYSWORDTEMPA_H,W,ACCESS
	subwf	SYSWORDTEMPB_H,W,ACCESS
	btfss	STATUS,C,ACCESS
	return
	movf	SYSWORDTEMPB_H,W,ACCESS
	subwf	SYSWORDTEMPA_H,W,ACCESS
	bnc	SCLT16TRUE
	movf	SYSWORDTEMPB,W,ACCESS
	subwf	SYSWORDTEMPA,W,ACCESS
	btfsc	STATUS,C,ACCESS
	return
SCLT16TRUE
	comf	SYSBYTETEMPX,F,ACCESS
	return

;********************************************************************************

SYSDIVSUB16
	movff	SYSWORDTEMPA,SYSDIVMULTA
	movff	SYSWORDTEMPA_H,SYSDIVMULTA_H
	movff	SYSWORDTEMPB,SYSDIVMULTB
	movff	SYSWORDTEMPB_H,SYSDIVMULTB_H
	clrf	SYSDIVMULTX,ACCESS
	clrf	SYSDIVMULTX_H,ACCESS
	movff	SYSDIVMULTB,SysWORDTempA
	movff	SYSDIVMULTB_H,SysWORDTempA_H
	clrf	SysWORDTempB,ACCESS
	clrf	SysWORDTempB_H,ACCESS
	rcall	SYSCOMPEQUAL16
	btfss	SysByteTempX,0,ACCESS
	bra	ENDIF23
	clrf	SYSWORDTEMPA,ACCESS
	clrf	SYSWORDTEMPA_H,ACCESS
	return
ENDIF23
	movlw	16
	movwf	SYSDIVLOOP,ACCESS
SYSDIV16START
	bcf	STATUS,C,ACCESS
	rlcf	SYSDIVMULTA,F,ACCESS
	rlcf	SYSDIVMULTA_H,F,ACCESS
	rlcf	SYSDIVMULTX,F,ACCESS
	rlcf	SYSDIVMULTX_H,F,ACCESS
	movf	SYSDIVMULTB,W,ACCESS
	subwf	SYSDIVMULTX,F,ACCESS
	movf	SYSDIVMULTB_H,W,ACCESS
	subwfb	SYSDIVMULTX_H,F,ACCESS
	bsf	SYSDIVMULTA,0,ACCESS
	btfsc	STATUS,C,ACCESS
	bra	ENDIF24
	bcf	SYSDIVMULTA,0,ACCESS
	movf	SYSDIVMULTB,W,ACCESS
	addwf	SYSDIVMULTX,F,ACCESS
	movf	SYSDIVMULTB_H,W,ACCESS
	addwfc	SYSDIVMULTX_H,F,ACCESS
ENDIF24
	decfsz	SYSDIVLOOP, F,ACCESS
	bra	SYSDIV16START
	movff	SYSDIVMULTA,SYSWORDTEMPA
	movff	SYSDIVMULTA_H,SYSWORDTEMPA_H
	movff	SYSDIVMULTX,SYSWORDTEMPX
	movff	SYSDIVMULTX_H,SYSWORDTEMPX_H
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
	db	12,67,97,114,103,97,110,100,111,32,46,46,46


StringTable2
	db	8,84,105,101,109,112,111,58,32


StringTable3
	db	21,69,114,114,111,114,44,32,97,108,103,111,32,101,115,116,97,32,109,97,108,46


;********************************************************************************


 END
