ASSUME SS:SSEG, CS:CSEG, DS:DSEG

DSEG SEGMENT 
BUF DB 8
	DB ?
	DB 8 DUP(?)
FACSUM DW ?
INPUTMIN DD ?
INPUTMAX DD ?
SUM DD ?
HALF DW ?
I1 DW ? ; I1 是Filter中的循环变量，范围是TMPNUM的一半
STR DB 8
	DB ?
	DB 8 DUP(?)
NUM DW ?  
MIN DB "Start At :",'$'
MAX DB "End At :",'$'
NUM1 DD 15FFFH
NUM2 DD 1FFFFh
TMPNUM DD ?
RESULT DW ?
DSEG ENDS

SSEG SEGMENT STACK
	DW 64 DUP(?)
SSEG ENDS

CSEG SEGMENT 

; 功能是找出TMPNUM数的因数和并且放在RESULT中
FILTER: ; 初始化栈空间
	PUSH BP
	MOV BP,SP
	SUB SP,08H

; 高四位，由于范围限制，高四位只会出现0或者1，所以直接写两段运算，
; 分别计算为0的时候是多少，为1的时候是多少，并且除2过后范围一定
; 是在低四位中，所以只需要计算一个高四位加低四位除2的情况，并且
; 这个功能可以使用IDIV实现
	MOV AX,WORD PTR TMPNUM ; 将TMPNUM的低BIT放入AX
	SHR AX,1 ; 右移（除以2）
	ADD AX,1000H ; 把高位中的值加上
	MOV HALF, AX ; 保存下除以二的结果
	; MOV TMP,TMPNUM ; 取代原来的传参
	MOV WORD PTR I1, 01H ; I从1开始循环
	MOV WORD PTR SUM, 00H ; 总和初始值为0
	MOV WORD PTR SUM+2, 00H
	JMP LOOPEXIT
LOOP2:
; 在进行加法运算的时候可以发现循环变量不会超过寄存器的范围，但是
; 结果会超过寄存器范围，所以在与SUM进行加法运算的时候要注意使用
; 大数运算，
	MOV AX,TMPNUM
	; XOR DX,DX ; 寄存器清零
	MOV DX, TMPNUM+2 ; 把高位移入DX
	IDIV WORD PTR I1 ; TMPNUM除以I1，商在AX中，余数在DX中
	MOV AX,DX ; 商用不到，只需要判断余数是不是0
	TEST AX,AX
	JNZ FORADD ; AX如果不是0则跳转
	MOV AX,I1 ; AX如果是0那么就是因数，需要把当前的I1放到SUM中
			  ; 要注意的是这里的I1是不会超过TMPNUM的一半的
	;ADD SUM,AX ; 需要虽然I1并不会超过寄存器范围，但是SUM可能超过
			   ; 所以这里需要用大数相加，先取SUM的低位与AX相加，
			   ; 然后将SUM的高位与运算结果拼接后放入SUM
	MOV CX, WORD PTR SUM ; 把SUM的低位放入CX
	MOV BX, WORD PTR SUM+2 ; 把SUM的高位放入BX
	ADD AX, CX ; 把SUM的高位与AX相加后的结果放入AX
	ADC BX, 0000H ; 带进位的加法，将前一步操作的CF加到结果中
	MOV WORD PTR SUM, AX ; 结果的低位放入SUM的低位
	MOV WORD PTR SUM+2 ,BX ; 结果的高位放入SUM的高位

FORADD:
	ADD WORD PTR I1,1 ; 如果余数不是0就不需要加，直接继续循环

LOOPEXIT: 
	MOV AX,I1 ; 将循环变量放入AX
	CMP AX,HALF ; 比较是否相等
	JB  LOOP2 ; 如果循环没到达一半就跳转

	MOV AX,SUM ; 如果循环到达一半了就要停止，这个时候的SUM就是想要得到的结果
	MOV SP,BP ; 栈平衡，返回
	POP BP
	RET

START: ; 首先初始化程序和栈空间
	MOV AX,DSEG
	MOV DS,AX 
	MOV AX,SSEG
	MOV SS,AX
	MOV SP,20H
	MOV BP,SP
	SUB SP,10H
	; 以下是输入，省略
	; MOV DX,OFFSET MIN
	; MOV AH,09H
	; INT 21H

	; LEA  DX, BUF 
	; MOV  AH, 0AH
	; INT  21H
	; CALL ASCII2NUM
	; MOV INPUTMIN,AX

	; MOV	AH, 2
	; MOV DL, 13
	; INT 21H
	; MOV DL, 10
	; INT 21H

	; MOV DX,OFFSET MAX
	; MOV AH,09H
	; INT 21H

	; LEA  DX, BUF 
	; MOV  AH, 0AH
	; INT  21H
	; CALL ASCII2NUM
	; MOV INPUTMAX,AX

	MOV CX,0DCH ; CX从220开始
	JMP FORIF ; 循环开始直接跳转到判断

LOOP0:
	CMP CX,0
	JZ  EXIT
	MOV AX,CX
	MOV DI,AX
	CALL FILTER
	MOV FACSUM,AX

	MOV AX,INPUTMIN
	CMP FACSUM,AX
	JB  FORADD1
	MOV AX,INPUTMAX
	CMP FACSUM,AX
	JA 	FORADD1

	MOV AX,FACSUM
	MOV DI,AX
	CALL FILTER
	CMP CX,AX
	JNZ FORADD1
	CMP CX,FACSUM
	JNB FORADD1

	MOV	AH, 2
	MOV DL, 13
	INT 21H
	MOV DL, 10
	INT 21H

	PUSH CX
	MOV AX,CX
	CALL PRINT
	POP CX

	MOV	AH, 2
	MOV DL, '-'
	INT 21H
	
	PUSH CX
	MOV AX,FACSUM
	CALL PRINT
	POP CX

FORADD1:
	INC CX
FORIF:
	MOV AX,INPUTMAX
	CMP CX,AX
	JBE LOOP0

EXIT:    
	MOV AX, 4C00H
	INT 21H

PRINT PROC NEAR
	PUSH BP
	MOV BP,SP

	MOV DI,OFFSET STR
	CMP AX,0
	JZ ZERO

	MOV BX,10
	XOR CX,CX

N3:	XOR DX,DX
	DIV BX
	PUSH DX
	INC CX
	CMP AX,0
	JZ RE
	JMP N3

ZERO:
	MOV BYTE PTR [DI],'0'
	INC DI
	MOV BYTE PTR [DI],'$'
	JMP FI					

RE:
	POP AX
	ADD AL,30H
	MOV [DI],AL
	INC DI
	LOOP RE
	MOV BYTE PTR [DI],'$'

FI:	MOV DX,OFFSET STR
	MOV AH,09H
	INT 21H

	MOV SP,BP
	POP BP
	RET
PRINT ENDP

ASCII2NUM PROC NEAR
	XOR CH, CH
	MOV CL, BUF[1]
	XOR DX, DX 
	MOV SI, 0
LOOP1:
	PUSH CX
	MOV  AX, DX 
	MOV  CL, 3
	SHL  DX, CL 
	SHL  AX, 1
	ADD  DX, AX 
	XOR  AH, AH 
	MOV  AL, BUF[SI+2]
	INC  SI 
	SUB  AL, '0'
	ADD  DX, AX  
	POP  CX 
	LOOP LOOP1 
	MOV  AX, DX 
	RET
ASCII2NUM ENDP

CSEG ENDS
END START