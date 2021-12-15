DATA SEGMENT
	MSG  DB 'PLEASE INPUT N:$'
	MSG1  DB 'Overflow!$'
DATA ENDS

CODE SEGMENT
	        ASSUME CS:CODE,DS:DATA
MAIN PROC NEAR
	START:  
	        MOV    AX,DATA
	        MOV    DS,AX
	        MOV    DX, OFFSET MSG
	        MOV    AH,09H         	;显示DX中字符串          	;显示DX中字符串
	        INT    21H
			
	        CALL   DECIBIN        	;接收N的子程序,N在BX中     	;接收N的子程序,N在BX中
	        MOV    DX,0D
	        MOV    CX,100D
	LOOP1:  
	        ADD    DX,BX          	;100N的值存入DX        	;100N的值存入DX
	        LOOP   LOOP1          	;循环计算              	;循环计算
	        CALL   SUM1
	        MOV    BX,AX          	;1-100和存于BX        	;1-100和存于BX
	        ADD    BX,DX          	;最终的结果存于BX         	;最终的结果存于BX
			
			JO     ERRORN
	        CALL   CRLF  
	        CALL   BINI           	;显示BX中的内容                            	;显示BX中的内容
	        MOV    AH,4CH         	;输出字符串，返回          	;输出字符串，返回
	        INT    21H
			RET
	ERRORN:
			CALL ERRORX
			
MAIN ENDP
	;------------------------------
DECIBIN PROC NEAR             		;接收N子程序           		;接收N子程序
	        MOV    BX,0
	NEWCHAR:
	        MOV    AH,1           	;21号中断1号功能，输入存AL   	;21号中断1号功能，输入存AL
	        INT    21H
	        SUB    AL,30H         	;ASCLL转化成10进制数字    	;ASCLL转化成10进制数字
	        JL     EXIT           	;符号位为负直接退出         	;符号位为负直接退出
	        CMP    AL,9D
	        JG     EXIT           	;输入每一位大于9就退出       	;输入每一位大于9就退出
	        CBW
	        XCHG   AX,BX          	;交换AX,BX寄存器内容      	;交换AX,BX寄存器内容
	        MOV    CX,10D         	;CX存10             	;CX存10
	        MUL    CX             	;AX和CX相乘,初始AX=0，结果低16位放AX，高16位放DX=0，结果低16位放AX，高16位放DX
	        XCHG   AX,BX          	;换回，乘积低16位在BX，本次读入字符在AX，乘积低16位在BX，本次读入字符在AX
	        ADD    BX,AX          	;相加存BX             	;相加存BX
	        JMP    NEWCHAR        	;继续读               	;继续读
	EXIT:   
	        RET
DECIBIN ENDP
	;---------------------------------------
ERRORX PROC NEAR
			
			MOV    DX,OFFSET MSG1
	        MOV    AH,09H         	;显示DX中字符串          	;显示DX中字符串
	        INT    21H
			RET
ERRORX ENDP
SUM1 PROC NEAR
	        MOV    CX,99D
	        MOV    AX,0D
	SUM:    
	        ADD    AX,CX
	        LOOP   SUM            	;计算1-100的和         	;计算1-100的和
	        RET
SUM1 ENDP
	;-------------------------------------------
BINI PROC NEAR                		;转化为十进制输出子程序      		;转化为十进制输出子程序
	        MOV    CX,10000D      	;最高位，以此类推          	;最高位，以此类推
	        CALL   BIN
	        MOV    CX,1000D
	        CALL   BIN
	        MOV    CX,100D
	        CALL   BIN
	        MOV    CX,10D
	        CALL   BIN
	        MOV    CX,1D
	        CALL   BIN
	        RET
BINI ENDP
	;-------------------------------------------

	
BIN PROC NEAR
	        MOV    AX,BX
	        MOV    DX,0           	;获取每一位                	;获取每一位
	        DIV    CX
	        MOV    BX,DX
	        MOV    DL,AL
	        ADD    DL,30H         	;转化成ASCLL码         	;转化成ASCLL码
	        MOV    AH,02H         	;输出                	;输出
	        INT    21H
	        RET
BIN ENDP
	;--------------------------------
CRLF PROC NEAR                		;回车换行子程序          		;回车换行子程序
	        MOV    DL,0DH         	;回车                	;回车
	        MOV    AH,02H         	;回显输出              	;回显输出
	        INT    21H
	        MOV    DL,0AH         	;换行                	;换行
	        INT    21H
	        RET
CRLF ENDP
CODE ENDS
    END START