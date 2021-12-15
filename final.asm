ASSUME CS:CODESG,SS:STACKSG,DS:DATASG

DATASG SEGMENT			
 MIN_LOW        DB 4 DUP(0)
 MIN_HIGH       DB 4 DUP(0)

 MAX_LOW        DB 4 DUP(0)
 MAX_HIGH       DB 4 DUP(0)

 SUM_LOW        DB 4 DUP(0) ; SUM IN GETSUM
 SUM_HIGH       DB 4 DUP(0) ; SUM IN GETSUM
 
 I_LOW          DB 4 DUP(0) ; I IN MAIN
 I_HIGH         DB 4 DUP(0) ; I IN MAIN

 J_LOW          DB 4 DUP(0) ; J IN GETSUM
 J_HIGH         DB 4 DUP(0) ; J IN GETSUM

 TMP_LOW        DB 4 DUP(0)
 TMP_HIGH       DB 4 DUP(0)

 RANGE_LOW        DB 4 DUP(0)
 RANGE_HIGH       DB 4 DUP(0)

 ARG_LOW        DB 4 DUP(0)
 ARG_HIGH       DB 4 DUP(0)

 OUT_LOW        DB 4 DUP(0)
 OUT_HIGH       DB 4 DUP(0)
 STR_BUF            DB 8 DUP(0)
DATASG ENDS

STACKSG SEGMENT
	DB 128 DUP(0)
STACKSG ENDS

CODESG SEGMENT
LARGE_DIV PROC NEAR
            ;(DX, AX)/CX
            ;@PARAM DX-H, AX-L, CX-N
            ;@RETURN DX-HI, AX-LO, CX-
                PUSH    BX
                ;H/N
                MOV     BX, AX ;L
                MOV     AX, DX
                MOV     DX, 0
                DIV     CX  ;SHANG-INT(H/N)-AX, YU-REM(H/N)-DX
                PUSH    AX ;INT(H/N)
                
                ;INT(H/N)*65536
                ;AX00
                ;[REM(H/N)*65536+L]/N
                ;DX BX
                MOV     AX, BX
                DIV     CX
                MOV     CX, DX ;YU

                ;INT(H/N)*65536 + [REM(H/N)*65536+L]/N
                ;DX00 + AX = DXAX
                POP     DX
                POP     BX
                RET

LARGE_DIV ENDP

REVERSE PROC
    PUSH AX
    PUSH DX
    PUSH CX
    ; LOAD THE OFFSET OF
    ; THE STRING
    MOV SI, OFFSET STR_BUF
 
    ; COUNT OF CHARACTERS OF THE;
    ;STRING
    MOV CX, 0H
 
    LOOP1:
    ; COMPARE IF THIS IS;
    ;THE LAST CHARACTER
    MOV AX, [SI]
    CMP AL, '$'
    JE LABEL1
 
    ; ELSE PUSH IT IN THE;
    ;STACK
    PUSH [SI]
 
    ; INCREMENT THE POINTER;
    ;AND COUNT
    INC SI
    INC CX
 
    JMP LOOP1
 
    LABEL1:
    ; AGAIN LOAD THE STARTING;
    ;ADDRESS OF THE STRING
    MOV SI, OFFSET STR_BUF
 
        LOOP2:
        ;IF COUNT NOT EQUAL TO ZERO
        CMP CX,0
        JE  BREAK
 
        ; POP THE TOP OF STACK
        POP DX
 
        ; MAKE DH, 0
        XOR DH, DH
 
        ; PUT THE CHARACTER OF THE;
        ;REVERSED STRING
        MOV [SI], DX
 
        ; INCREMENT SI AND;
        ;DECREMENT COUNT
        INC SI
        DEC CX
 
        JMP LOOP2
 
                 
    BREAK:
    ; ADD $ TO THE END OF STRING
    MOV [SI],'$ '
    POP CX
    POP DX
    POP AX
    RET
         
REVERSE ENDP

OUTPUT          PROC NEAR  
                XOR DI, DI
                MOV AX, WORD PTR OUT_LOW
                MOV DX, WORD PTR OUT_HIGH
NEXT:
                MOV CX, 10
                CALL LARGE_DIV

                ADD CX, '0'
                MOV BYTE PTR STR_BUF[DI], CL
                INC DI

                CMP AX, 0
                JNE NEXT
                CMP DX, 0
                JNE NEXT

FI:             

                MOV BYTE PTR STR_BUF[DI], '$'
                CALL REVERSE
                MOV DX, OFFSET STR_BUF
                MOV AH,09H
                INT 21H

                RET

OUTPUT          ENDP

START:
                MOV     AX,STACKSG
                MOV     SS,AX
                MOV     SP,40H
                MOV     BP,SP
                MOV     AX,DATASG
                MOV     DS,AX
                
                ; MOV     WORD PTR MIN_LOW, 8885H
                ; MOV     WORD PTR MIN_HIGH, 0001H
                ; MOV     WORD PTR MAX_LOW, 2227H
                ; MOV     WORD PTR MAX_HIGH, 002H
				MOV     WORD PTR MIN_LOW, 00DAH
                MOV     WORD PTR MIN_HIGH, 0000H
                MOV     WORD PTR MAX_LOW, 2227H
                MOV     WORD PTR MAX_HIGH, 002H
                MOV     WORD PTR ARG_LOW, 00H
                MOV     WORD PTR ARG_HIGH, 00H

; BIG FOR START
                MOV     AX, WORD PTR MIN_HIGH
                MOV     WORD PTR I_HIGH, AX
                JMP     LOC_10367                  ; FIRST TEST I MAX

; IF (I_HIGH==MIN_HIGH && MIN_HIGH==MAX_HIGH)
IF1_TEST1:
                MOV     AX, WORD PTR I_HIGH         ; I_HIGH == MIN_HIGH ?
                CMP     AX, WORD PTR MIN_HIGH
                JZ      LOC_1012F            
                JMP     LOC_101BA

LOC_1012F:
                MOV     AX, WORD PTR MIN_HIGH       ; MIN_HIGH == MAX_HIGH ? 
                CMP     AX, WORD PTR MAX_HIGH    
                JZ      LOC_1013B
                JMP     LOC_101BA

; PART 1 LOOP START
LOC_1013B:
                MOV     AX, WORD PTR MIN_LOW        ; I LOW = MIN LOW
                MOV     WORD PTR I_LOW, AX
                JMP     LOC_101AE

LOC_10143:
                MOV     AX, WORD PTR I_HIGH         ; ARG HIGH = I HIGH
                MOV     WORD PTR ARG_HIGH, AX       
                MOV     AX, WORD PTR I_LOW          ; ARG LOW  = I LOW
                MOV     WORD PTR ARG_LOW, AX 
                CALL    GETSUM                     ; GET SUM
                MOV     AX, WORD PTR SUM_HIGH
                MOV     WORD PTR TMP_HIGH, AX       ; TMP HIGH = SUM HIGH           
                MOV     AX, WORD PTR SUM_LOW
                MOV     WORD PTR TMP_LOW, AX        ; TMP LOW = SUM LOW
                MOV     AX, WORD PTR TMP_HIGH       
                MOV     WORD PTR ARG_HIGH, AX       ; ARG HIGH = TMP HIGH
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR ARG_LOW, AX        ; ARG LOW = TMP LOW
                CALL    GETSUM
                MOV     AX, WORD PTR I_HIGH         ; I HIGH == SUM HIGH ?
                CMP     AX, WORD PTR SUM_HIGH
                JNZ     LOC_101AA                   
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR SUM_LOW        ; I LOW == SUM LOW ? 
                JNZ     LOC_101AA                   
                MOV     AX, WORD PTR I_HIGH         ; I HIGH> TMP HIGH ?
                CMP     AX, WORD PTR TMP_HIGH       
                JBE     LOC_1018A
                JMP     LOC_101AA

LOC_1018A:
                MOV     AX, WORD PTR I_HIGH         ; I HIGH == TMP HIGH ?
                CMP     AX, WORD PTR TMP_HIGH
                JNZ     LOC_1019E
                MOV     AX, WORD PTR I_LOW          ; I LOW >= TMP_LOW ?
                CMP     AX, WORD PTR TMP_LOW
                JB      LOC_1019E
                JMP     LOC_101AA

LOC_1019E:
                MOV     AX, WORD PTR I_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR I_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV     AX, WORD PTR TMP_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV	    AH, 2
                MOV     DL, 13
                INT     21H
                MOV     DL, 10
                INT     21H

LOC_101AA:                          ; I_LOW ++
                INC     WORD PTR I_LOW

LOC_101AE:                          ; I LOW  <= MAX LOW
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR MAX_LOW
                JBE     FUCK1
                JMP     LOC_10373                   ; BREAK
; PART 1 END
FUCK1:
                JMP     LOC_10143
; IF (I_HIGH==MIN_HIGH && MIN_HIGH!=MAX_HIGH)
LOC_101BA:
                MOV     AX, WORD PTR I_HIGH         ; I_HIGH==MIN_HIGH ?
                CMP     AX, WORD PTR MIN_HIGH
                JZ      LOC_101C6
TT1:
                JMP     LOC_10245

LOC_101C6:
                MOV     AX, WORD PTR MIN_HIGH       ; MIN_HIGH!=MAX_HIGH ?
                CMP     AX, WORD PTR MAX_HIGH
                JZ      TT1
; PART 2 START
                MOV     AX, WORD PTR MIN_LOW        ; I LOW = MIN LOW
                MOV     WORD PTR I_LOW, AX

LOC_101D5:                              
                MOV     AX, WORD PTR I_HIGH         ; ARG_HIGH=I_HIGH;
                MOV     WORD PTR ARG_HIGH, AX
                MOV     AX, WORD PTR I_LOW          ; ARG_LOW=I_LOW;
                MOV     WORD PTR ARG_LOW, AX
                CALL    GETSUM                      ; GET SUM 
                MOV     AX, WORD PTR SUM_HIGH       
                MOV     WORD PTR TMP_HIGH, AX       ; TMP_HIGH=SUM_HIGH;
                MOV     AX, WORD PTR SUM_LOW
                MOV     WORD PTR TMP_LOW, AX        ; TMP_LOW=SUM_LOW;
                MOV     AX, WORD PTR TMP_HIGH
                MOV     WORD PTR ARG_HIGH, AX       ; ARG_HIGH=TMP_HIGH;
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR ARG_LOW, AX        ; ARG_LOW=TMP_LOW;
                CALL    GETSUM     ; GETSUM(VOID)   ; GET SUM

; IF (I_HIGH==SUM_HIGH && I_LOW==SUM_LOW )
                MOV     AX, WORD PTR I_HIGH         
                CMP     AX, WORD PTR SUM_HIGH       ; I_HIGH==SUM_HIGH ?
                JNZ     SHORT LOC_1023C
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR SUM_LOW        ; I_LOW==SUM_LOW ?
                JNZ     SHORT LOC_1023C

                MOV     AX, WORD PTR I_HIGH         ; I_HIGH>TMP_HIGH
                CMP     AX, WORD PTR TMP_HIGH       
                JBE     SHORT LOC_1021C
                JMP     SHORT LOC_1023C

; IF (I_HIGH==TMP_HIGH && I_LOW>=TMP_LOW)
 LOC_1021C:                             
                MOV     AX, WORD PTR I_HIGH        ; I_HIGH==TMP_HIGH ?
                CMP     AX, WORD PTR TMP_HIGH
                JNZ     SHORT LOC_10230
                MOV     AX, WORD PTR I_LOW         ; I_LOW>=TMP_LOW ?
                CMP     AX, WORD PTR TMP_LOW
                JB      SHORT LOC_10230
                JMP     SHORT LOC_1023C

 LOC_10230:                                 
                MOV     AX, WORD PTR I_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR I_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV     AX, WORD PTR TMP_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV	    AH, 2
                MOV     DL, 13
                INT     21H
                MOV     DL, 10
                INT     21H

 LOC_1023C:                              
                                        
                INC     WORD PTR I_LOW
                CMP     WORD PTR I_LOW, 0
                JZ      TMP_JMP1
                JMP     LOC_101D5
;  _MAIN           ENDP
TMP_JMP1:       JMP     LOC_10363
; PART 2 END MAYBE

LOC_10245:                             
; IF (I_HIGH!=MIN_HIGH && MIN_HIGH!=MAX_HIGH && I_HIGH!=MAX_HIGH)                                         
                MOV     AX, WORD PTR I_HIGH     ; I_HIGH!=MIN_HIGH
                CMP     AX, WORD PTR MIN_HIGH
                JNZ     SHORT LOC_10251
                JMP     LOC_102DC

 LOC_10251:                                     ; MIN_HIGH!=MAX_HIGH
                MOV     AX, WORD PTR MIN_HIGH
                CMP     AX, WORD PTR MAX_HIGH
                JNZ     SHORT LOC_1025D

TT2:
                JMP     LOC_102DC

 LOC_1025D:                                     ; I_HIGH!=MAX_HIGH
                MOV     AX, WORD PTR I_HIGH
                CMP     AX, WORD PTR MAX_HIGH
                JZ      TT2
; PART 3 FOR START
                MOV     WORD PTR I_LOW, 0       ; I_LOW=0

 LOC_1026C:                                     
                MOV     AX, WORD PTR I_HIGH     ; ARG_HIGH=I_HIGH;
                MOV     WORD PTR ARG_HIGH, AX
                MOV     AX, WORD PTR I_LOW      ; ARG_LOW=I_LOW;
                MOV     WORD PTR ARG_LOW, AX
                CALL    GETSUM                  ; GETSUM(VOID)
                MOV     AX, WORD PTR SUM_HIGH   ; TMP_HIGH=SUM_HIGH;
                MOV     WORD PTR TMP_HIGH, AX   
                MOV     AX, WORD PTR SUM_LOW    ; TMP_LOW=SUM_LOW;
                MOV     WORD PTR TMP_LOW, AX
                MOV     AX, WORD PTR TMP_HIGH   ; ARG_HIGH=TMP_HIGH;
                MOV     WORD PTR ARG_HIGH, AX
                MOV     AX, WORD PTR TMP_LOW    ; ARG_LOW=TMP_LOW;
                MOV     WORD PTR ARG_LOW, AX
                CALL    GETSUM                 ; GETSUM(VOID)
                MOV     AX, WORD PTR I_HIGH
                CMP     AX, WORD PTR SUM_HIGH  ; I_HIGH==SUM_HIGH ?
                JNZ     SHORT LOC_102D3
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR SUM_LOW   ; I_LOW==SUM_LOW
                JNZ     SHORT LOC_102D3
                MOV     AX, WORD PTR I_HIGH    
                CMP     AX, WORD PTR TMP_HIGH  ; I_HIGH>TMP_HIGH
                JBE     SHORT LOC_102B3
                JMP     SHORT LOC_102D3

 LOC_102B3:                              
                MOV     AX, WORD PTR I_HIGH    ; I_HIGH==TMP_HIGH
                CMP     AX, WORD PTR TMP_HIGH
                JNZ     SHORT LOC_102C7
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR TMP_LOW   ; I_LOW>=TMP_LOW
                JB      SHORT LOC_102C7
                JMP     SHORT LOC_102D3

 LOC_102C7:                              
                                         
                MOV     AX, WORD PTR I_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR I_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV     AX, WORD PTR TMP_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV	    AH, 2
                MOV     DL, 13
                INT     21H
                MOV     DL, 10
                INT     21H

 LOC_102D3:                              
                                        
                INC     WORD PTR I_LOW
                CMP     WORD PTR I_LOW, 0
                JZ      TMP_JMP2
                JMP     LOC_1026C
; PART 3 END
TMP_JMP2:       JMP     LOC_10363
; IF (I_HIGH==MAX_HIGH)
 LOC_102DC:                              
                MOV     AX, WORD PTR I_HIGH
                CMP     AX, WORD PTR MAX_HIGH        ; I_HIGH==MAX_HIGH
                JNZ     TMP_JMP2
                MOV     WORD PTR I_LOW, 0       ; I_LOW = 0
                JMP     LOC_10358

 LOC_102ED:                              
                MOV     AX, WORD PTR I_HIGH     ; ARG_HIGH=I_HIGH;
                MOV     WORD PTR ARG_HIGH, AX   
                MOV     AX, WORD PTR I_LOW      ; ARG_LOW=I_LOW;
                MOV     WORD PTR ARG_LOW, AX
                CALL    GETSUM                  ; GETSUM(VOID)
                MOV     AX, WORD PTR SUM_HIGH
                MOV     WORD PTR TMP_HIGH, AX   ; TMP_HIGH=SUM_HIGH;
                MOV     AX, WORD PTR SUM_LOW
                MOV     WORD PTR TMP_LOW, AX    ; TMP_LOW=SUM_LOW;
                MOV     AX, WORD PTR TMP_HIGH
                MOV     WORD PTR ARG_HIGH, AX   ; ARG_HIGH=TMP_HIGH;
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR ARG_LOW, AX    ; ARG_LOW=TMP_LOW;
                CALL    GETSUM                  ; GETSUM(VOID)
; IF (I_HIGH==SUM_HIGH && I_LOW==SUM_LOW )
                MOV     AX, WORD PTR I_HIGH     ; I_HIGH==SUM_HIGH
                CMP     AX, WORD PTR SUM_HIGH
                JNZ     SHORT LOC_10354
                MOV     AX, WORD PTR I_LOW      ; I_LOW==SUM_LOW
                CMP     AX, WORD PTR SUM_LOW
                JNZ     SHORT LOC_10354
                MOV     AX, WORD PTR I_HIGH     ; I_HIGH>TMP_HIGH
                CMP     AX, WORD PTR TMP_HIGH
                JBE     SHORT LOC_10334
                JMP     SHORT LOC_10354

 LOC_10334:                              
                MOV     AX, WORD PTR I_HIGH     ; I_HIGH==TMP_HIGH
                CMP     AX, WORD PTR TMP_HIGH
                JNZ     SHORT LOC_10348
                MOV     AX, WORD PTR I_LOW      ; I_LOW>=TMP_LOW
                CMP     AX, WORD PTR TMP_LOW
                JB      SHORT LOC_10348
                JMP     SHORT LOC_10354
 LOC_10348:                              

                MOV     AX, WORD PTR I_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR I_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT
                MOV     AX, WORD PTR TMP_HIGH    ; OUT PUT !!!
                MOV     WORD PTR OUT_HIGH, AX
                MOV     AX, WORD PTR TMP_LOW
                MOV     WORD PTR OUT_LOW, AX
                CALL    OUTPUT

                MOV	    AH, 2
                MOV     DL, 13
                INT     21H
                MOV     DL, 10
                INT     21H

 LOC_10354:                              
                                        
                INC     WORD PTR I_LOW          ; I LOW ++

 LOC_10358:                              
                MOV     AX, WORD PTR I_LOW
                CMP     AX, WORD PTR MAX_LOW    ; I_LOW<=MAX_LOW
                JBE     FUCK2
                JMP     LOC_10363 
FUCK2:
                JMP     LOC_102ED
 LOC_10363:                              
                                        
                INC     WORD PTR I_HIGH         ; I HIGH ++

 LOC_10367:                                 
                MOV     AX, WORD PTR I_HIGH 
                CMP     AX, WORD PTR MAX_HIGH   ; I_HIGH<=MAX_HIGH
                JA      LOC_10373
                JMP     IF1_TEST1

 LOC_10373:                             
                JMP     LOC_10377

LOC_10377:                             
EXIT:  	
	            MOV     AX, 4C00H
  	            INT 21H


GETSUM          PROC NEAR              

                MOV     AX, WORD PTR ARG_LOW
                MOV     DX, WORD PTR ARG_HIGH
                MOV     CX, 02H
                CALL    LARGE_DIV
                MOV     WORD PTR RANGE_LOW, AX
                MOV     WORD PTR RANGE_HIGH, DX


                PUSH    SI
                MOV     WORD PTR SUM_HIGH, 0
                MOV     WORD PTR SUM_LOW, 0
; FOR START
                MOV     WORD PTR J_HIGH, 0
                JMP     LOC_100E2

LOC_10029:                             
                MOV     AX, WORD PTR J_HIGH
                CMP     AX, WORD PTR ARG_HIGH       ; J_HIGH == ARG_HIGH ?
                JNZ     SHORT LOC_1008E
; F1 START
                MOV     WORD PTR J_LOW, 0           ; J_LOW=0
                JMP     SHORT LOC_10083             

; IF (J_HIGH==ARG_HIGH && J_LOW==ARG_LOW)
LOC_1003A:                              
                MOV     AX, WORD PTR J_HIGH         ; J_HIGH==ARG_HIGH ? 
                CMP     AX, WORD PTR ARG_HIGH       
                JNZ     SHORT LOC_1004F
                MOV     AX, WORD PTR J_LOW
                CMP     AX, WORD PTR ARG_LOW         ; J_LOW==ARG_LOW ?
                JNZ     SHORT LOC_1004F
                JMP     LOC_100F0

LOC_1004F:                            

                MOV     AX, WORD PTR ARG_LOW
                MOV     DX, WORD PTR ARG_HIGH
                MOV     CX, WORD PTR J_LOW
                CMP     CX, 0
                JZ      LOC_1007F
                CALL    LARGE_DIV                   ; ARG % J == 0 ?
                CMP     CX, 00H
                JNZ     LOC_1007F


                MOV     AX, WORD PTR SUM_LOW
                MOV     BX, WORD PTR SUM_HIGH
                MOV     CX, WORD PTR J_LOW
                MOV     DX, WORD PTR J_HIGH

                ADD     AX, CX
                ADC     BX, DX
            
                MOV     WORD PTR SUM_LOW, AX
                MOV     WORD PTR SUM_HIGH, BX

LOC_1007F: 
                INC     WORD PTR J_LOW          ; J_LOW ++

LOC_10083:                              
                MOV     AX, WORD PTR J_LOW
                CMP     AX, WORD PTR RANGE_LOW    ; J_LOW<=ARG_LOW ? 
                JBE     SHORT LOC_1003A
                JMP     SHORT LOC_100DE

; ELSE 
LOC_1008E:                              
                MOV     WORD PTR J_LOW, 0       ; J_LOW = 0

; IF (J_HIGH==ARG_HIGH && J_LOW==ARG_LOW)
LOC_10094:                              
                MOV     AX, WORD PTR J_HIGH     
                CMP     AX, WORD PTR ARG_HIGH   ; J_HIGH==ARG_HIGH
                JNZ     SHORT LOC_100A8
                MOV     AX, WORD PTR J_LOW
                CMP     AX, WORD PTR ARG_LOW    ; J_LOW==ARG_LOW
                JNZ     SHORT LOC_100A8
                JMP     SHORT LOC_100F0

LOC_100A8:                              

                MOV     AX, WORD PTR ARG_LOW
                MOV     DX, WORD PTR ARG_HIGH
                MOV     CX, WORD PTR J_LOW
                CMP     CX, 0
                JZ      LOC_100D8
                CALL    LARGE_DIV                   ; ARG % J == 0 ?
                CMP     CX, 00H
                JNZ     LOC_100D8


                MOV     AX, WORD PTR SUM_LOW
                MOV     BX, WORD PTR SUM_HIGH
                MOV     CX, WORD PTR J_LOW
                MOV     DX, WORD PTR J_HIGH

                ADD     AX, CX
                ADC     BX, DX
            
                MOV     WORD PTR SUM_LOW, AX
                MOV     WORD PTR SUM_HIGH, BX

LOC_100D8:                              
                INC     WORD PTR J_LOW      ; J LOW ++
                CMP     WORD PTR J_LOW, 0
                JE      LOC_100DE
                JMP     SHORT LOC_10094

LOC_100DE:                              
                INC     WORD PTR J_HIGH     ; J HIGH ++

LOC_100E2:                             
                MOV     AX, WORD PTR J_HIGH
                CMP     AX, WORD PTR RANGE_HIGH   ; J_HIGH<=ARG_HIGH ?
                JA      LOC_100EE
                JMP     LOC_10029

LOC_100EE:                              
                JMP     LOC_100F0

LOC_100F0:                                                   
                POP     SI
                RET
GETSUM          ENDP

CODESG ENDS

END START