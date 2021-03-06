TITLE	.HW8 (EXE) DleteUnder64KB
	.MODEL	SMALL
	.STACK	64
	.DATA
ROW	DB	00	; Screen ROW
COL	DB	10	; And Col
PATHNAME	DB	'C:\TEST\*.DOC', 00H
PROMPT1	DB	'IN C:\TEST ...'
PROM_1_LEN	EQU	14
PROMPT2	DB	'Remainder Count : '
PROM_2_LEN	EQU	18
PROMPT3	DB	'NO .DOC FILE IN C:\TEST\'
PROM_3_LEN	EQU	24
PROMPT4	DB	'REMAINDER .DOC FILE COUNT : '
PROM_4_LEN	EQU	28

DISKAREA	DB	43	DUP	(20H)
FILECOUNT	DB	0
ASCII_FILECOUNT	DB	10	DUP	(00H)
ASCII_FILECOUNT_LEN	DW	0
;------------------------------------
	.CODE
A10_MAIN	PROC	NEAR
	
	CALL	Q10_INITIALIZE
	CALL	B10_FIRST
	CMP	AX, 00H
	JNE	A90_END

	LEA	BP, PROMPT1
	MOV	CX,	PROM_1_LEN
	CALL F10_DISPALY
	INC ROW

A20:
	CALL	D10_MESSG	;DISPLAY FILE NAME
	INC ROW
	CALL	E10_JUDGE	; JUDGE THAT DELETE FILE OR LEAVE IT
	CALL	C10_NEXT	; END NEXT FILE,
	CMP AX, 00H		; MORE ENTRIES?
	JE	A20			; THEN LOOP.

	LEA	BP, PROMPT4
	MOV	CX,	PROM_4_LEN
	CALL F10_DISPALY
	ADD COL, PROM_4_LEN

	CALL H10_HEXTODEC
	LEA	BP, ASCII_FILECOUNT
	MOV	CX,	ASCII_FILECOUNT_LEN
	CALL F10_DISPALY
	INC ROW


A90_END:
	MOV	AX, 4C00H
	INT	21H
A10_MAIN	ENDP


;	FIND FIRST ENTRY IN DIRECTORY
;	---------------------------------
B10_FIRST	PROC	NEAR
	MOV	AH, 1AH
	LEA	DX, DISKAREA
	INT 21H
	MOV	AH, 4EH
	LEA	DX, PATHNAME
	INT 21H
	JNC	B90_END

	PUSH AX
	LEA	BP, PROMPT3
	MOV	CX, PROM_3_LEN
	CALL	F10_DISPALY
	POP AX
B90_END:	RET
B10_FIRST	ENDP

;	FIND SUCCEEDING ENTRIES IN DIRECTORY
;	---------------------------------
C10_NEXT	PROC	NEAR
	MOV	AH, 4FH
	INT	21H
	RET
C10_NEXT	ENDP

;	CALCULATE LENGTH OF FILENAME AND DISPALY
;	---------------------------------
D10_MESSG	PROC	NEAR
	MOV	COL, 18
	LEA	DI, DISKAREA+30	;FILE NAME IN DTA
	MOV	AL, 00H
	MOV	CX,13
	REPNE	SCASB
	NEG	CX
	ADD CX, 13
	LEA	BP, DISKAREA+1EH
	CALL	F10_DISPALY
	RET
D10_MESSG	ENDP

;	COMPARE FILE SIZE, IF < 64KB, CALL DELETE
;	--------------------------------
E10_JUDGE	PROC	NEAR
	;	64KB -> 16BIT.
	;	THERE ARE HIGH SIZE AND LOW SIZE.
	;	HIGH SIZE * 2^16 + LOW SIZE.
	;	= HIGH SIZE * 64KB + LOW SIZE. 
	;	THEN, IF FILE SIZE SMALL TEAN 64KB,
	;	THERE ARE NO BIT IN HIGH SIZE.
	;	-> HIGH SIZE == 0000 0000 0000 0000

	LEA	DI, DISKAREA+1CH	; HIGH SIZE
	CMP WORD PTR [DI], 0
	JE	E20_DELETE
	JNE	E30_LEAVE
E20_DELETE:
	CALL	G10_DELETE
	JMP E90_END
E30_LEAVE:
	INC	FILECOUNT
	JMP	E90_END
E90_END:	RET
E10_JUDGE	ENDP



;	DISPLAY LENGTH -> CX, DATA -> BP
;	-------------------------------
F10_DISPALY	PROC	NEAR
	MOV	AX, 1301H
	MOV	BX,0016H
	MOV DH, ROW
	MOV DL, COL
	INT 10H
	RET
F10_DISPALY ENDP

;	DELETE FILE
;	-------------------------
G10_DELETE	PROC	NEAR
	MOV	AH, 41H
	LEA	DX, DISKAREA+1EH
	INT	21H
	INT 3
	JNC G90_END
	INT 3
G90_END:	RET
G10_DELETE	ENDP

Q10_INITIALIZE	PROC	NEAR
	MOV	AX, @data
	MOV	DS, AX
	MOV	ES, AX
	MOV	AX,0003H
	INT	10H
	RET
Q10_INITIALIZE	ENDP

;	FROM HW4, HEXA TO DEC
;	--------------------------------
H10_HEXTODEC	PROC	NEAR
	LEA DI, ASCII_FILECOUNT	; ready to printing Decimal, not Hex
	MOV	AL, FILECOUNT
	MOV CH, 10	; to devide 10
HEXTODEC:
	MOV AH, 0	; erase AH's value to devide only AL with 10
	DIV CH		; AL / 10. then AH = Remainder, AL : Quotient
	ADD AH, 30H	; ADD '0'
	MOV [DI], AH	; store Remainder
	
	INC DI

	CMP AL, 0	; if all number changed from hex to dec,
	JNZ HEXTODEC	; then stop looping

	LEA SI, ASCII_FILECOUNT
	NEG	SI
	ADD SI, DI
	MOV	ASCII_FILECOUNT_LEN, SI;


	LEA SI, ASCII_FILECOUNT	; Ready to Reverse Decimal numbers
	DEC DI		; Because I calculated in Little Endian
			; si : start->end of OUTPUT, di : end->start of OUTPUT

	

REVERSE:
	CMP SI, DI	; if SI is over DI
	JNB H90_END	; then stop reverse
	MOV BH, [DI]	; Or, Reverse
	MOV DL, [SI]
	MOV [DI], DL
	MOV [SI], BH
	
	INC SI		; to reverse next number
	DEC DI
	JMP REVERSE

H90_END:	RET
H10_HEXTODEC	ENDP

	END	A10_MAIN