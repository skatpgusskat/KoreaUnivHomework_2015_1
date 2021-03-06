TITLE	.HW7 (EXE) Encryption
	.MODEL	SMALL
	.STACK	64
	.DATA


TABLE_SIZE	EQU	256
ENCRYPT_TABLE	DB	TABLE_SIZE DUP (0)

PARLIST LABEL BYTE
MAXLEN	DB	128
ACTULEN	DB	?
KBNAME	DB	128 DUP(' ')

ENCRYPT	DB	131 DUP	(' ')	; FIRST ENCRYPTION
RESTORE	DB	131 DUP(' ')	; SECOND ENCRYPTION

LINEFEED	DB	0AH, 0DH, '$'

	.CODE
	.386
A10_MAIN PROC	NEAR
	MOV	AX, @data
	MOV DS, AX
	MOV ES, AX

	CALL	B10_MAKE_TABLE

	CALL	C10_INPUT

	;SET DISPLAY TARGET
	LEA	DX, LINEFEED	
	CALL	E10_DISPLAY


	;SET ENCRYPT TARGET
	LEA SI, KBNAME		;SOURCE
	LEA	DI, ENCRYPT		;DESTINATION
	MOV	CL, ACTULEN		;LENGTH OF STRING
	MOV	CH, 0
	CALL	D10_ENCRYPT

	;SET DISPLAY TARGET
	LEA	DX, ENCRYPT	
	CALL	E10_DISPLAY

	;SET ENCRYPT TARGET
	LEA SI, ENCRYPT		;SOURCE
	LEA	DI, RESTORE		;DESTINATION
	MOV	CL, ACTULEN		;LENGTH OF STRING
	MOV	CH, 0
	CALL	D10_ENCRYPT

	;SET DISPLAY TARGET
	LEA	DX, RESTORE	
	CALL	E10_DISPLAY


	MOV AX, 4C00H
	INT 21H 
A10_MAIN	ENDP

B10_MAKE_TABLE	PROC	NEAR
	MOV	CX, 256
	LEA	DI, ENCRYPT_TABLE
	MOV AL, 0FFH;
B20:
	MOV	[DI], AL
	INC	DI
	DEC	AL
	LOOP B20

	RET
B10_MAKE_TABLE ENDP

C10_INPUT	PROC	NEAR
	MOV AH, 0AH	; Input String from keyboards
	LEA DX, PARLIST
	INT 21H
	RET
C10_INPUT	ENDP


;----------------------------------------
	;MUST SET SOURCE BUFFER TO SI
	;AND SET BUFFER SIZE TO CX
	;FINALLY SET DESTINATION BUFFER TO DI
	; SI, DI, CX
;----------------------------------------
D10_ENCRYPT	PROC	NEAR
D20:
	MOV AL, [SI]
	XLAT	ENCRYPT_TABLE
	MOV [DI], AL
	INC SI
	INC DI
	LOOP D20

	; ADD LINE FEED AND CARRIAGE RETURN
	; TO SEEM GOOD ON MONITOR :)
	MOV BYTE PTR [DI], 0DH
	INC DI
	MOV BYTE PTR [DI], 0AH
	INC DI
	MOV BYTE PTR [DI], '$'
	RET
D10_ENCRYPT	ENDP

;----------------------------------------
	;MUST SET DISPLAY BUFFER TO DX
	; DX
;---------------------------------------
E10_DISPLAY	PROC	NEAR
	MOV AH, 09H	; display dx
	INT 21H

	RET
E10_DISPLAY	ENDP
	
	END	A10_MAIN