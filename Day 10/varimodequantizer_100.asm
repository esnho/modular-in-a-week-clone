;variable mode cv quantizer for 16F684
;usting external 20mhz clock
;Input 0-5VDC on pin 10, 
;PIN 9: mode select, Major, Major Pentatonic, Minor, Minor Pentatonic, Chromatic
; output PWM on Pin 5
;Quantizes to 1/12th of a volt.  When used as 1v/Oct this corresponds to a chromatic scale
;
;Rev1.0
;5-29-2010
;
;equates start here

TMR0	EQU 	01H
STATUS	EQU	3
ZEROBIT EQU	2
CARRY	EQU	0
PORTC	EQU	07h
TMR2	EQU	11h
T2CON	EQU	12h
PR2		EQU	92h
CCPR1L	EQU	13h
CCP1CON	EQU	15h
ADRESL	EQU	9Eh
ADRESH	EQU	1Eh
ANSEL	EQU	91h
VOLTHI	EQU	40h
VOLTLO	EQU	41h
PIR1	EQU	0Ch
ADCON0	EQU	1Fh
TRISC	EQU	87h
ADCON1	EQU	9Fh
PORTA	EQU	05h
OSCCON	EQU	8Fh
CALIBHI	EQU	42h
CALIBTEMP	EQU	43h
MODEHI	EQU	44h


;equates end here
;*************************
List 	P=16F684
ORG	0
GOTO	START



;***********************

;first set up PWM
START	
		MOVLW	B'00000100'
	MOVWF	T2CON	
	BSF		STATUS,5
		MOVLW	B'00100000'
		MOVWF	TRISC
		BCF		STATUS,5
	CLRF	PORTC
	CLRF	PORTA	
		BSF		STATUS,5		
		movlw	D'255'
		movwf	PR2
		BCF	STATUS,5
		MOVLW	B'00000000'
		MOVWF	CCPR1L
		BSF	STATUS,5
	MOVLW	B'11011111'
	MOVWF	TRISC
	BCF	STATUS,5

	MOVLW	B'00001100'
	MOVWF	CCP1CON	
	BCF	STATUS,5
	CLRF	PORTC
;now setup the ADC
	MOVLW	B'00010001'		;set ADCon file
	MOVWF	ADCON0	
	BSF		STATUS,5	
	MOVLW	B'01100000'
	MOVWF	ADCON1
	MOVLW	B'00000011'
	MOVWF	TRISC
	MOVLW	B'00110000'
	MOVWF	ANSEL
	BCF	STATUS,5
	MOVLW	.56
	MOVWF	CALIBHI
;start main loop
;get AD reading
BEGIN	MOVLW	B'00010001'		;DO AD READING FOR VOLTAGE TO QUANTIZE
	MOVWF	ADCON0			;STORE IT IN VOLTHI
	BSF	ADCON0,1
WAIT	BTFSC	ADCON0,1
	GOTO	WAIT
	MOVF	ADRESH,W
	MOVWF	VOLTHI
	MOVLW	B'00010101'		
	MOVWF	ADCON0
	BSF	ADCON0,1		;DO AD READING FOR MODE
	BTFSC	ADCON0,1		;STORE IT IN MODEHI
	GOTO	$-1
	MOVF	ADRESH,W
	MOVWF	MODEHI

	MOVF	MODEHI,W		;FIGURE OUT WHAT MODE TO GO TO
	SUBLW	.52
	BTFSC	STATUS,0
	GOTO	MAJOR

	MOVF	MODEHI,W		;FIGURE OUT WHAT MODE TO GO TO
	SUBLW	.104
	BTFSC	STATUS,0
	GOTO	MAJORPEN

	MOVF	MODEHI,W		;FIGURE OUT WHAT MODE TO GO TO
	SUBLW	.153
	BTFSC	STATUS,0
	GOTO	MINOR

	MOVF	MODEHI,W		;FIGURE OUT WHAT MODE TO GO TO
	SUBLW	.204
	BTFSC	STATUS,0
	GOTO	MINORPEN

	MOVF	MODEHI,W		;FIGURE OUT WHAT MODE TO GO TO
	SUBLW	.255
	BTFSC	STATUS,0
	GOTO	CHROM

;search to see what voltage it corresponds to
	;MAJOR SCALE voltage scanning
;reads calibration voltage, adds an integer to it, uses this
;as the maximum voltage for a range, then compares the input
;voltage and goes to the proper set subroutine.

CHROM	MOVF	VOLTHI,W
	SUBLW	.2
	BTFSC	STATUS,0
	GOTO	SETC1
	MOVF	VOLTHI,W
	SUBLW	.6
	BTFSC	STATUS,0
	GOTO	SETDb1
	MOVF	VOLTHI,W
	SUBLW	.11
	BTFSC	STATUS,0
	GOTO	SETD1
	MOVF	VOLTHI,W
	SUBLW	.15
	BTFSC	STATUS,0
	GOTO	SETEb1
	MOVF	VOLTHI,W
	SUBLW	.19
	BTFSC	STATUS,0
	GOTO	SETE1
	MOVF	VOLTHI,W
	SUBLW	.23
	BTFSC	STATUS,0
	GOTO	SETF1
	MOVF	VOLTHI,W
	SUBLW	.28
	BTFSC	STATUS,0
	GOTO	SETGb1
	MOVF	VOLTHI,W
	SUBLW	.32
	BTFSC	STATUS,0
	GOTO	SETG1
	MOVF	VOLTHI,W
	SUBLW	.36
	BTFSC	STATUS,0
	GOTO	SETAb1
	MOVF	VOLTHI,W
	SUBLW	.40
	BTFSC	STATUS,0
	GOTO	SETA1
	MOVF	VOLTHI,W
	SUBLW	.45
	BTFSC	STATUS,0
	GOTO	SETBb1
	MOVF	VOLTHI,W
	SUBLW	.49
	BTFSC	STATUS,0
	GOTO	SETB1
	MOVF	VOLTHI,W
	SUBLW	.53
	BTFSC	STATUS,0
	GOTO	SETC2
	MOVF	VOLTHI,W
	SUBLW	.57
	BTFSC	STATUS,0
	GOTO	SETDb2
	MOVF	VOLTHI,W
	SUBLW	.62
	BTFSC	STATUS,0
	GOTO	SETD2
	MOVF	VOLTHI,W
	SUBLW	.66
	BTFSC	STATUS,0
	GOTO	SETEb2
	MOVF	VOLTHI,W
	SUBLW	.70
	BTFSC	STATUS,0
	GOTO	SETE2
	MOVF	VOLTHI,W
	SUBLW	.74
	BTFSC	STATUS,0
	GOTO	SETF2
	MOVF	VOLTHI,W
	SUBLW	.79
	BTFSC	STATUS,0
	GOTO	SETGb2
	MOVF	VOLTHI,W
	SUBLW	.83
	BTFSC	STATUS,0
	GOTO	SETG2
	MOVF	VOLTHI,W
	SUBLW	.87
	BTFSC	STATUS,0
	GOTO	SETAb2
	MOVF	VOLTHI,W
	SUBLW	.91
	BTFSC	STATUS,0
	GOTO	SETA2
	MOVF	VOLTHI,W
	SUBLW	.96
	BTFSC	STATUS,0
	GOTO	SETBb2
	MOVF	VOLTHI,W
	SUBLW	.100
	BTFSC	STATUS,0
	GOTO	SETB2
	MOVF	VOLTHI,W
	SUBLW	.104
	BTFSC	STATUS,0
	GOTO	SETC3
	MOVF	VOLTHI,W
	SUBLW	.108
	BTFSC	STATUS,0
	GOTO	SETDb3
	MOVF	VOLTHI,W
	SUBLW	.113
	BTFSC	STATUS,0
	GOTO	SETD3
	MOVF	VOLTHI,W
	SUBLW	.117
	BTFSC	STATUS,0
	GOTO	SETEb3
	MOVF	VOLTHI,W
	SUBLW	.121
	BTFSC	STATUS,0
	GOTO	SETE3
	MOVF	VOLTHI,W
	SUBLW	.125
	BTFSC	STATUS,0
	GOTO	SETF3
	MOVF	VOLTHI,W
	SUBLW	.130
	BTFSC	STATUS,0
	GOTO	SETGb3
	MOVF	VOLTHI,W
	SUBLW	.134
	BTFSC	STATUS,0
	GOTO	SETG3
	MOVF	VOLTHI,W
	SUBLW	.138
	BTFSC	STATUS,0
	GOTO	SETAb3
	MOVF	VOLTHI,W
	SUBLW	.142
	BTFSC	STATUS,0
	GOTO	SETA3
	MOVF	VOLTHI,W
	SUBLW	.147
	BTFSC	STATUS,0
	GOTO	SETBb3
	MOVF	VOLTHI,W
	SUBLW	.151
	BTFSC	STATUS,0
	GOTO	SETB3
	MOVF	VOLTHI,W
	SUBLW	.155
	BTFSC	STATUS,0
	GOTO	SETC4
	MOVF	VOLTHI,W
	SUBLW	.159
	BTFSC	STATUS,0
	GOTO	SETDb4
	MOVF	VOLTHI,W
	SUBLW	.164
	BTFSC	STATUS,0
	GOTO	SETD4
	MOVF	VOLTHI,W
	SUBLW	.168
	BTFSC	STATUS,0
	GOTO	SETEb4
	MOVF	VOLTHI,W
	SUBLW	.172
	BTFSC	STATUS,0
	GOTO	SETE4
	MOVF	VOLTHI,W
	SUBLW	.176
	BTFSC	STATUS,0
	GOTO	SETF4
	MOVF	VOLTHI,W
	SUBLW	.181
	BTFSC	STATUS,0
	GOTO	SETGb4
	MOVF	VOLTHI,W
	SUBLW	.185
	BTFSC	STATUS,0
	GOTO	SETG4
	MOVF	VOLTHI,W
	SUBLW	.189
	BTFSC	STATUS,0
	GOTO	SETAb4
	MOVF	VOLTHI,W
	SUBLW	.193
	BTFSC	STATUS,0
	GOTO	SETA4
	MOVF	VOLTHI,W
	SUBLW	.198
	BTFSC	STATUS,0
	GOTO	SETBb4
	MOVF	VOLTHI,W
	SUBLW	.202
	BTFSC	STATUS,0
	GOTO	SETB4
	MOVF	VOLTHI,W
	SUBLW	.206
	BTFSC	STATUS,0
	GOTO	SETC5
	MOVF	VOLTHI,W
	SUBLW	.210
	BTFSC	STATUS,0
	GOTO	SETDb5
	MOVF	VOLTHI,W
	SUBLW	.215
	BTFSC	STATUS,0
	GOTO	SETD5
	MOVF	VOLTHI,W
	SUBLW	.219
	BTFSC	STATUS,0
	GOTO	SETEb5
	MOVF	VOLTHI,W
	SUBLW	.223
	BTFSC	STATUS,0
	GOTO	SETE5
	MOVF	VOLTHI,W
	SUBLW	.227
	BTFSC	STATUS,0
	GOTO	SETF5
	MOVF	VOLTHI,W
	SUBLW	.232
	BTFSC	STATUS,0
	GOTO	SETGb5
	MOVF	VOLTHI,W
	SUBLW	.236
	BTFSC	STATUS,0
	GOTO	SETG5
	MOVF	VOLTHI,W
	SUBLW	.240
	BTFSC	STATUS,0
	GOTO	SETAb5
	MOVF	VOLTHI,W
	SUBLW	.244
	BTFSC	STATUS,0
	GOTO	SETA5
	MOVF	VOLTHI,W
	SUBLW	.249
	BTFSC	STATUS,0
	GOTO	SETBb5
	MOVF	VOLTHI,W
	SUBLW	.253
	BTFSC	STATUS,0
	GOTO	SETB5
	MOVF	VOLTHI,W
	SUBLW	.255
	BTFSC	STATUS,0
	GOTO	SETC6
	

	GOTO	BEGIN

MAJOR	MOVF	VOLTHI,W
	SUBLW	.4
	BTFSC	STATUS,0
	GOTO	SETC1
	MOVF	VOLTHI,W
	SUBLW	.13
	BTFSC	STATUS,0
	GOTO	SETD1
	MOVF	VOLTHI,W
	SUBLW	.19
	BTFSC	STATUS,0
	GOTO	SETE1
	MOVF	VOLTHI,W
	SUBLW	.26
	BTFSC	STATUS,0
	GOTO	SETF1
	MOVF	VOLTHI,W
	SUBLW	.34
	BTFSC	STATUS,0
	GOTO	SETG1
	MOVF	VOLTHI,W
	SUBLW	.43
	BTFSC	STATUS,0
	GOTO	SETA1
	MOVF	VOLTHI,W
	SUBLW	.49
	BTFSC	STATUS,0
	GOTO	SETB1
	MOVF	VOLTHI,W
	SUBLW	.55
	BTFSC	STATUS,0
	GOTO	SETC2
	MOVF	VOLTHI,W
	SUBLW	.64
	BTFSC	STATUS,0
	GOTO	SETD2
	MOVF	VOLTHI,W
	SUBLW	.70
	BTFSC	STATUS,0
	GOTO	SETE2
	MOVF	VOLTHI,W
	SUBLW	.77
	BTFSC	STATUS,0
	GOTO	SETF2
	MOVF	VOLTHI,W
	SUBLW	.85
	BTFSC	STATUS,0
	GOTO	SETG2
	MOVF	VOLTHI,W
	SUBLW	.94
	BTFSC	STATUS,0
	GOTO	SETA2
	MOVF	VOLTHI,W
	SUBLW	.100
	BTFSC	STATUS,0
	GOTO	SETB2
	MOVF	VOLTHI,W
	SUBLW	.106
	BTFSC	STATUS,0
	GOTO	SETC3
	MOVF	VOLTHI,W
	SUBLW	.115
	BTFSC	STATUS,0
	GOTO	SETD3
	MOVF	VOLTHI,W
	SUBLW	.121
	BTFSC	STATUS,0
	GOTO	SETE3
	MOVF	VOLTHI,W
	SUBLW	.128
	BTFSC	STATUS,0
	GOTO	SETF3
	MOVF	VOLTHI,W
	SUBLW	.136
	BTFSC	STATUS,0
	GOTO	SETG3
	MOVF	VOLTHI,W
	SUBLW	.145
	BTFSC	STATUS,0
	GOTO	SETA3
	MOVF	VOLTHI,W
	SUBLW	.151
	BTFSC	STATUS,0
	GOTO	SETB3
	MOVF	VOLTHI,W
	SUBLW	.157
	BTFSC	STATUS,0
	GOTO	SETC4
	MOVF	VOLTHI,W
	SUBLW	.166
	BTFSC	STATUS,0
	GOTO	SETD4
	MOVF	VOLTHI,W
	SUBLW	.172
	BTFSC	STATUS,0
	GOTO	SETE4
	MOVF	VOLTHI,W
	SUBLW	.179
	BTFSC	STATUS,0
	GOTO	SETF4
	MOVF	VOLTHI,W
	SUBLW	.187
	BTFSC	STATUS,0
	GOTO	SETG4
	MOVF	VOLTHI,W
	SUBLW	.196
	BTFSC	STATUS,0
	GOTO	SETA4
	MOVF	VOLTHI,W
	SUBLW	.202
	BTFSC	STATUS,0
	GOTO	SETB4
	MOVF	VOLTHI,W
	SUBLW	.208
	BTFSC	STATUS,0
	GOTO	SETC5
	MOVF	VOLTHI,W
	SUBLW	.217
	BTFSC	STATUS,0
	GOTO	SETD5
	MOVF	VOLTHI,W
	SUBLW	.223
	BTFSC	STATUS,0
	GOTO	SETE5
	MOVF	VOLTHI,W
	SUBLW	.230
	BTFSC	STATUS,0
	GOTO	SETF5
	MOVF	VOLTHI,W
	SUBLW	.238
	BTFSC	STATUS,0
	GOTO	SETG5
	MOVF	VOLTHI,W
	SUBLW	.247
	BTFSC	STATUS,0
	GOTO	SETA5
	MOVF	VOLTHI,W
	SUBLW	.253
	BTFSC	STATUS,0
	GOTO	SETB5
	MOVF	VOLTHI,W
	SUBLW	.259
	BTFSC	STATUS,0
	GOTO	SETC6
	

	GOTO	BEGIN


MAJORPEN	MOVF	VOLTHI,W
	SUBLW	.4
	BTFSC	STATUS,0
	GOTO	SETC1
	MOVF	VOLTHI,W
	SUBLW	.13
	BTFSC	STATUS,0
	GOTO	SETD1
	MOVF	VOLTHI,W
	SUBLW	.23
	BTFSC	STATUS,0
	GOTO	SETE1
	MOVF	VOLTHI,W
	SUBLW	.34
	BTFSC	STATUS,0
	GOTO	SETG1
	MOVF	VOLTHI,W
	SUBLW	.45
	BTFSC	STATUS,0
	GOTO	SETA1
	MOVF	VOLTHI,W
	SUBLW	.55
	BTFSC	STATUS,0
	GOTO	SETC2
	MOVF	VOLTHI,W
	SUBLW	.64
	BTFSC	STATUS,0
	GOTO	SETD2
	MOVF	VOLTHI,W
	SUBLW	.74
	BTFSC	STATUS,0
	GOTO	SETE2
	MOVF	VOLTHI,W
	SUBLW	.85
	BTFSC	STATUS,0
	GOTO	SETG2
	MOVF	VOLTHI,W
	SUBLW	.96
	BTFSC	STATUS,0
	GOTO	SETA2
	MOVF	VOLTHI,W
	SUBLW	.106
	BTFSC	STATUS,0
	GOTO	SETC3
	MOVF	VOLTHI,W
	SUBLW	.115
	BTFSC	STATUS,0
	GOTO	SETD3
	MOVF	VOLTHI,W
	SUBLW	.125
	BTFSC	STATUS,0
	GOTO	SETE3
	MOVF	VOLTHI,W
	SUBLW	.136
	BTFSC	STATUS,0
	GOTO	SETG3
	MOVF	VOLTHI,W
	SUBLW	.147
	BTFSC	STATUS,0
	GOTO	SETA3
	MOVF	VOLTHI,W
	SUBLW	.157
	BTFSC	STATUS,0
	GOTO	SETC4
	MOVF	VOLTHI,W
	SUBLW	.166
	BTFSC	STATUS,0
	GOTO	SETD4
	MOVF	VOLTHI,W
	SUBLW	.176
	BTFSC	STATUS,0
	GOTO	SETE4
	MOVF	VOLTHI,W
	SUBLW	.187
	BTFSC	STATUS,0
	GOTO	SETG4
	MOVF	VOLTHI,W
	SUBLW	.198
	BTFSC	STATUS,0
	GOTO	SETA4
	MOVF	VOLTHI,W
	SUBLW	.208
	BTFSC	STATUS,0
	GOTO	SETC5
	MOVF	VOLTHI,W
	SUBLW	.217
	BTFSC	STATUS,0
	GOTO	SETD5
	MOVF	VOLTHI,W
	SUBLW	.227
	BTFSC	STATUS,0
	GOTO	SETE5
	MOVF	VOLTHI,W
	SUBLW	.238
	BTFSC	STATUS,0
	GOTO	SETG5
	MOVF	VOLTHI,W
	SUBLW	.249
	BTFSC	STATUS,0
	GOTO	SETA5
	MOVF	VOLTHI,W
	SUBLW	.259
	BTFSC	STATUS,0
	GOTO	SETC6

MINOR	MOVF	VOLTHI,W
	SUBLW	.4
	BTFSC	STATUS,0
	GOTO	SETC1
	MOVF	VOLTHI,W
	SUBLW	.11
	BTFSC	STATUS,0
	GOTO	SETD1
	MOVF	VOLTHI,W
	SUBLW	.17
	BTFSC	STATUS,0
	GOTO	SETEb1
	MOVF	VOLTHI,W
	SUBLW	.26
	BTFSC	STATUS,0
	GOTO	SETF1
	MOVF	VOLTHI,W
	SUBLW	.32
	BTFSC	STATUS,0
	GOTO	SETG1
	MOVF	VOLTHI,W
	SUBLW	.38
	BTFSC	STATUS,0
	GOTO	SETAb1
	MOVF	VOLTHI,W
	SUBLW	.47
	BTFSC	STATUS,0
	GOTO	SETBb1
	MOVF	VOLTHI,W
	SUBLW	.55
	BTFSC	STATUS,0
	GOTO	SETC2
	MOVF	VOLTHI,W
	SUBLW	.62
	BTFSC	STATUS,0
	GOTO	SETD2
	MOVF	VOLTHI,W
	SUBLW	.68
	BTFSC	STATUS,0
	GOTO	SETEb2
	MOVF	VOLTHI,W
	SUBLW	.77
	BTFSC	STATUS,0
	GOTO	SETF2
	MOVF	VOLTHI,W
	SUBLW	.83
	BTFSC	STATUS,0
	GOTO	SETG2
	MOVF	VOLTHI,W
	SUBLW	.89
	BTFSC	STATUS,0
	GOTO	SETAb2
	MOVF	VOLTHI,W
	SUBLW	.98
	BTFSC	STATUS,0
	GOTO	SETBb2
	MOVF	VOLTHI,W
	SUBLW	.106
	BTFSC	STATUS,0
	GOTO	SETC3
	MOVF	VOLTHI,W
	SUBLW	.113
	BTFSC	STATUS,0
	GOTO	SETD3
	MOVF	VOLTHI,W
	SUBLW	.119
	BTFSC	STATUS,0
	GOTO	SETEb3
	MOVF	VOLTHI,W
	SUBLW	.128
	BTFSC	STATUS,0
	GOTO	SETF3
	MOVF	VOLTHI,W
	SUBLW	.134
	BTFSC	STATUS,0
	GOTO	SETG3
	MOVF	VOLTHI,W
	SUBLW	.140
	BTFSC	STATUS,0
	GOTO	SETAb3
	MOVF	VOLTHI,W
	SUBLW	.149
	BTFSC	STATUS,0
	GOTO	SETBb3
	MOVF	VOLTHI,W
	SUBLW	.157
	BTFSC	STATUS,0
	GOTO	SETC4
	MOVF	VOLTHI,W
	SUBLW	.164
	BTFSC	STATUS,0
	GOTO	SETD4
	MOVF	VOLTHI,W
	SUBLW	.170
	BTFSC	STATUS,0
	GOTO	SETEb4
	MOVF	VOLTHI,W
	SUBLW	.179
	BTFSC	STATUS,0
	GOTO	SETF4
	MOVF	VOLTHI,W
	SUBLW	.185
	BTFSC	STATUS,0
	GOTO	SETG4
	MOVF	VOLTHI,W
	SUBLW	.191
	BTFSC	STATUS,0
	GOTO	SETAb4
	MOVF	VOLTHI,W
	SUBLW	.200
	BTFSC	STATUS,0
	GOTO	SETBb4
	MOVF	VOLTHI,W
	SUBLW	.208
	BTFSC	STATUS,0
	GOTO	SETC5
	MOVF	VOLTHI,W
	SUBLW	.215
	BTFSC	STATUS,0
	GOTO	SETD5
	MOVF	VOLTHI,W
	SUBLW	.221
	BTFSC	STATUS,0
	GOTO	SETEb5
	MOVF	VOLTHI,W
	SUBLW	.230
	BTFSC	STATUS,0
	GOTO	SETF5
	MOVF	VOLTHI,W
	SUBLW	.236
	BTFSC	STATUS,0
	GOTO	SETG5
	MOVF	VOLTHI,W
	SUBLW	.242
	BTFSC	STATUS,0
	GOTO	SETAb5
	MOVF	VOLTHI,W
	SUBLW	.251
	BTFSC	STATUS,0
	GOTO	SETBb5
	MOVF	VOLTHI,W
	SUBLW	.259
	BTFSC	STATUS,0
	GOTO	SETC6
	

	GOTO	BEGIN

MINORPEN	MOVF	VOLTHI,W
	SUBLW	.6
	BTFSC	STATUS,0
	GOTO	SETC1
	MOVF	VOLTHI,W
	SUBLW	.17
	BTFSC	STATUS,0
	GOTO	SETEb1
	MOVF	VOLTHI,W
	SUBLW	.26
	BTFSC	STATUS,0
	GOTO	SETF1
	MOVF	VOLTHI,W
	SUBLW	.36
	BTFSC	STATUS,0
	GOTO	SETG1
	MOVF	VOLTHI,W
	SUBLW	.47
	BTFSC	STATUS,0
	GOTO	SETBb1
	MOVF	VOLTHI,W
	SUBLW	.57
	BTFSC	STATUS,0
	GOTO	SETC2
	MOVF	VOLTHI,W
	SUBLW	.68
	BTFSC	STATUS,0
	GOTO	SETEb2
	MOVF	VOLTHI,W
	SUBLW	.77
	BTFSC	STATUS,0
	GOTO	SETF2
	MOVF	VOLTHI,W
	SUBLW	.87
	BTFSC	STATUS,0
	GOTO	SETG2
	MOVF	VOLTHI,W
	SUBLW	.98
	BTFSC	STATUS,0
	GOTO	SETBb2
	MOVF	VOLTHI,W
	SUBLW	.108
	BTFSC	STATUS,0
	GOTO	SETC3
	MOVF	VOLTHI,W
	SUBLW	.119
	BTFSC	STATUS,0
	GOTO	SETEb3
	MOVF	VOLTHI,W
	SUBLW	.128
	BTFSC	STATUS,0
	GOTO	SETF3
	MOVF	VOLTHI,W
	SUBLW	.138
	BTFSC	STATUS,0
	GOTO	SETG3
	MOVF	VOLTHI,W
	SUBLW	.149
	BTFSC	STATUS,0
	GOTO	SETBb3
	MOVF	VOLTHI,W
	SUBLW	.159
	BTFSC	STATUS,0
	GOTO	SETC4
	MOVF	VOLTHI,W
	SUBLW	.170
	BTFSC	STATUS,0
	GOTO	SETEb4
	MOVF	VOLTHI,W
	SUBLW	.179
	BTFSC	STATUS,0
	GOTO	SETF4
	MOVF	VOLTHI,W
	SUBLW	.189
	BTFSC	STATUS,0
	GOTO	SETG4
	MOVF	VOLTHI,W
	SUBLW	.200
	BTFSC	STATUS,0
	GOTO	SETBb4
	MOVF	VOLTHI,W
	SUBLW	.210
	BTFSC	STATUS,0
	GOTO	SETC5
	MOVF	VOLTHI,W
	SUBLW	.221
	BTFSC	STATUS,0
	GOTO	SETEb5
	MOVF	VOLTHI,W
	SUBLW	.230
	BTFSC	STATUS,0
	GOTO	SETF5
	MOVF	VOLTHI,W
	SUBLW	.240
	BTFSC	STATUS,0
	GOTO	SETG5
	MOVF	VOLTHI,W
	SUBLW	.251
	BTFSC	STATUS,0
	GOTO	SETBb5
	MOVF	VOLTHI,W
	SUBLW	.261
	BTFSC	STATUS,0
	GOTO	SETC6
	

	GOTO	BEGIN

SETC1	MOVLW	B'00000000'
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETDb1	MOVLW	.4
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETD1	MOVLW	.9
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	MOVWF	CCPR1L
	GOTO	BEGIN

SETEb1	MOVLW	.13
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETE1	MOVLW	.17
	MOVWF	CCPR1L
	BCF	CCP1CON,4
	BCF	CCP1CON,5
	
	GOTO	BEGIN

SETF1	MOVLW	.21
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETGb1	MOVLW	.25
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN


SETG1	MOVLW	.30
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETAb1	MOVLW	.34
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETA1	MOVLW	.38
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN


SETBb1	MOVLW	.43
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETB1	MOVLW	.47
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETC2	MOVLW	.51
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETDb2	MOVLW	.55
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETD2	MOVLW	.59
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETEb2	MOVLW	.64
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETE2	MOVLW	.68
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETF2	MOVLW	.72
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETGb2	MOVLW	.76
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETG2	MOVLW	.81
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN


SETAb2	MOVLW	.85
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETA2	MOVLW	.89
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETBb2	MOVLW	.93
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETB2	MOVLW	.98
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETC3	MOVLW	.102
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETDb3	MOVLW	.106
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETD3	MOVLW	.110
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETEb3	MOVLW	.115
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETE3	MOVLW	.119
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETF3	MOVLW	.123
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETGb3	MOVLW	.128
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETG3	MOVLW	.132
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETAb3	MOVLW	.136
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETA3	MOVLW	.140
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETBb3	MOVLW	.145
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETB3	MOVLW	.149
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETC4	MOVLW	.153
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETDb4	MOVLW	.157
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETD4	MOVLW	.162
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETEb4	MOVLW	.166
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETE4	MOVLW	.170
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETF4	MOVLW	.174
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETGb4	MOVLW	.179
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETG4	MOVLW	.183
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETAb4	MOVLW	.187
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETA4	MOVLW	.191
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN


SETBb4	MOVLW	.196
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETB4	MOVLW	.200
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETC5	MOVLW	.204
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETDb5	MOVLW	.208
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETD5	MOVLW	.213
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETEb5	MOVLW	.217
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETE5	MOVLW	.221
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETF5	MOVLW	.225
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETGb5	MOVLW	.230
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETG5	MOVLW	.234
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETAb5	MOVLW	.238
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETA5	MOVLW	.242
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETBb5	MOVLW	.246
	MOVWF	CCPR1L
	BCF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

SETB5	MOVLW	.251
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BCF	CCP1CON,4
	GOTO	BEGIN

SETC6	MOVLW	.255
	MOVWF	CCPR1L
	BSF	CCP1CON,5
	BSF	CCP1CON,4
	GOTO	BEGIN

END
