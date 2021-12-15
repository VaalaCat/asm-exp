assume cs:codesg,ss:stacksg,ds:datasg

datasg segment			
 min_low        db 4 dup(0)
 min_high       db 4 dup(0)

 max_low        db 4 dup(0)
 max_high       db 4 dup(0)

 sum_low        db 4 dup(0) ; sum in getsum
 sum_high       db 4 dup(0) ; sum in getsum
 
 i_low          db 4 dup(0) ; i in main
 i_high         db 4 dup(0) ; i in main

 j_low          db 4 dup(0) ; j in getsum
 j_high         db 4 dup(0) ; j in getsum

 tmp_low        db 4 dup(0)
 tmp_high       db 4 dup(0)

 range_low        db 4 dup(0)
 range_high       db 4 dup(0)

 arg_low        db 4 dup(0)
 arg_high       db 4 dup(0)

 out_low        db 4 dup(0)
 out_high       db 4 dup(0)
 str_buf            db 8 dup(0)
datasg ends

stacksg segment
	db 128 dup(0)
stacksg ends

codesg segment
large_div proc near
            ;(dx, ax)/cx
            ;@param dx-H, ax-L, cx-N
            ;@return dx-hi, ax-lo, cx-
                push    bx
                ;H/N
                mov     bx, ax ;L
                mov     ax, dx
                mov     dx, 0
                div     cx  ;shang-int(H/N)-ax, yu-rem(H/N)-dx
                push    ax ;int(H/N)
                
                ;int(H/N)*65536
                ;ax00
                ;[rem(H/N)*65536+L]/N
                ;dx bx
                mov     ax, bx
                div     cx
                mov     cx, dx ;yu

                ;int(H/N)*65536 + [rem(H/N)*65536+L]/N
                ;dx00 + ax = dxax
                pop     dx
                pop     bx
                ret

large_div endp

REVERSE PROC
    push ax
    push dx
    push cx
    ; load the offset of
    ; the string
    MOV SI, OFFSET str_buf
 
    ; count of characters of the;
    ;string
    MOV CX, 0H
 
    LOOP1:
    ; compare if this is;
    ;the last character
    MOV AX, [SI]
    CMP AL, '$'
    JE LABEL1
 
    ; else push it in the;
    ;stack
    PUSH [SI]
 
    ; increment the pointer;
    ;and count
    INC SI
    INC CX
 
    JMP LOOP1
 
    LABEL1:
    ; again load the starting;
    ;address of the string
    MOV SI, OFFSET str_buf
 
        LOOP2:
        ;if count not equal to zero
        CMP CX,0
        JE  break
 
        ; pop the top of stack
        POP DX
 
        ; make dh, 0
        XOR DH, DH
 
        ; put the character of the;
        ;reversed string
        MOV [SI], DX
 
        ; increment si and;
        ;decrement count
        INC SI
        DEC CX
 
        JMP LOOP2
 
                 
    break:
    ; add $ to the end of string
    MOV [SI],'$ '
    pop cx
    pop DX
    pop ax
    RET
         
REVERSE ENDP

output          proc near  
                xor di, di
                mov ax, word ptr out_low
                mov dx, word ptr out_high
next:
                mov cx, 10
                call large_div

                add cx, '0'
                mov byte ptr str_buf[di], cl
                inc di

                cmp ax, 0
                jne next
                cmp dx, 0
                jne next

fi:             

                mov byte ptr str_buf[di], '$'
                call REVERSE
                mov dx, offset str_buf
                mov ah,09h
                int 21h

                ret

output          endp

start:
                mov     ax,stacksg
                mov     ss,ax
                mov     sp,40h
                mov     bp,sp
                mov     ax,datasg
                mov     ds,ax
                
                ; mov     word ptr min_low, 8885h
                ; mov     word ptr min_high, 0001h
                ; mov     word ptr max_low, 2227h
                ; mov     word ptr max_high, 002h
				mov     word ptr min_low, 00dah
                mov     word ptr min_high, 0001h
                mov     word ptr max_low, 2227h
                mov     word ptr max_high, 002h
                mov     word ptr arg_low, 00h
                mov     word ptr arg_high, 00h

; big for start
                mov     ax, word ptr min_high
                mov     word ptr i_high, ax
                jmp     loc_10367                  ; first test i max

; if (i_high==min_high && min_high==max_high)
if1_test1:
                mov     ax, word ptr i_high         ; i_high == min_high ?
                cmp     ax, word ptr min_high
                jz      loc_1012f            
                jmp     loc_101ba

loc_1012f:
                mov     ax, word ptr min_high       ; min_high == max_high ? 
                cmp     ax, word ptr max_high    
                jz      loc_1013b
                jmp     loc_101ba

; part 1 loop start
loc_1013b:
                mov     ax, word ptr min_low        ; i low = min low
                mov     word ptr i_low, ax
                jmp     loc_101ae

loc_10143:
                mov     ax, word ptr i_high         ; arg high = i high
                mov     word ptr arg_high, ax       
                mov     ax, word ptr i_low          ; arg low  = i low
                mov     word ptr arg_low, ax 
                call    getsum                     ; get sum
                mov     ax, word ptr sum_high
                mov     word ptr tmp_high, ax       ; tmp high = sum high           
                mov     ax, word ptr sum_low
                mov     word ptr tmp_low, ax        ; tmp low = sum low
                mov     ax, word ptr tmp_high       
                mov     word ptr arg_high, ax       ; arg high = tmp high
                mov     ax, word ptr tmp_low
                mov     word ptr arg_low, ax        ; arg low = tmp low
                call    getsum
                mov     ax, word ptr i_high         ; i high == sum high ?
                cmp     ax, word ptr sum_high
                jnz     loc_101aa                   
                mov     ax, word ptr i_low
                cmp     ax, word ptr sum_low        ; i low == sum low ? 
                jnz     loc_101aa                   
                mov     ax, word ptr i_high         ; i high> tmp high ?
                cmp     ax, word ptr tmp_high       
                jbe     loc_1018a
                jmp     loc_101aa

loc_1018a:
                mov     ax, word ptr i_high         ; i high == tmp high ?
                cmp     ax, word ptr tmp_high
                jnz     loc_1019e
                mov     ax, word ptr i_low          ; i low >= tmp_low ?
                cmp     ax, word ptr tmp_low
                jb      loc_1019e
                jmp     loc_101aa

loc_1019e:
                mov     ax, word ptr i_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr i_low
                mov     word ptr out_low, ax
                call    output
                mov     ax, word ptr tmp_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr tmp_low
                mov     word ptr out_low, ax
                call    output
                mov	    ah, 2
                mov     dl, 13
                int     21h
                mov     dl, 10
                int     21h

loc_101aa:                          ; i_low ++
                inc     word ptr i_low

loc_101ae:                          ; i low  <= max low
                mov     ax, word ptr i_low
                cmp     ax, word ptr max_low
                jbe     fuck1
                jmp     loc_10373                   ; break
; part 1 end
fuck1:
                jmp     loc_10143
; if (i_high==min_high && min_high!=max_high)
loc_101ba:
                mov     ax, word ptr i_high         ; i_high==min_high ?
                cmp     ax, word ptr min_high
                jz      loc_101c6
tt1:
                jmp     loc_10245

loc_101c6:
                mov     ax, word ptr min_high       ; min_high!=max_high ?
                cmp     ax, word ptr max_high
                jz      tt1
; part 2 start
                mov     ax, word ptr min_low        ; i low = min low
                mov     word ptr i_low, ax

loc_101D5:                              
                mov     ax, word ptr i_high         ; arg_high=i_high;
                mov     word ptr arg_high, ax
                mov     ax, word ptr i_low          ; arg_low=i_low;
                mov     word ptr arg_low, ax
                call    getsum                      ; get sum 
                mov     ax, word ptr sum_high       
                mov     word ptr tmp_high, ax       ; tmp_high=sum_high;
                mov     ax, word ptr sum_low
                mov     word ptr tmp_low, ax        ; tmp_low=sum_low;
                mov     ax, word ptr tmp_high
                mov     word ptr arg_high, ax       ; arg_high=tmp_high;
                mov     ax, word ptr tmp_low
                mov     word ptr arg_low, ax        ; arg_low=tmp_low;
                call    getsum     ; getsum(void)   ; get sum

; if (i_high==sum_high && i_low==sum_low )
                mov     ax, word ptr i_high         
                cmp     ax, word ptr sum_high       ; i_high==sum_high ?
                jnz     short loc_1023C
                mov     ax, word ptr i_low
                cmp     ax, word ptr sum_low        ; i_low==sum_low ?
                jnz     short loc_1023C

                mov     ax, word ptr i_high         ; i_high>tmp_high
                cmp     ax, word ptr tmp_high       
                jbe     short loc_1021C
                jmp     short loc_1023C

; if (i_high==tmp_high && i_low>=tmp_low)
 loc_1021C:                             
                mov     ax, word ptr i_high        ; i_high==tmp_high ?
                cmp     ax, word ptr tmp_high
                jnz     short loc_10230
                mov     ax, word ptr i_low         ; i_low>=tmp_low ?
                cmp     ax, word ptr tmp_low
                jb      short loc_10230
                jmp     short loc_1023C

 loc_10230:                                 
                mov     ax, word ptr i_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr i_low
                mov     word ptr out_low, ax
                call    output
                mov     ax, word ptr tmp_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr tmp_low
                mov     word ptr out_low, ax
                call    output
                mov	    ah, 2
                mov     dl, 13
                int     21h
                mov     dl, 10
                int     21h

 loc_1023C:                              
                                        
                inc     word ptr i_low
                cmp     word ptr i_low, 0
                jz      tmp_jmp1
                jmp     loc_101D5
;  _main           endp
tmp_jmp1:       jmp     loc_10363
; part 2 end maybe

loc_10245:                             
; if (i_high!=min_high && min_high!=max_high && i_high!=max_high)                                         
                mov     ax, word ptr i_high     ; i_high!=min_high
                cmp     ax, word ptr min_high
                jnz     short loc_10251
                jmp     loc_102DC

 loc_10251:                                     ; min_high!=max_high
                mov     ax, word ptr min_high
                cmp     ax, word ptr max_high
                jnz     short loc_1025D

tt2:
                jmp     loc_102DC

 loc_1025D:                                     ; i_high!=max_high
                mov     ax, word ptr i_high
                cmp     ax, word ptr max_high
                jz      tt2
; part 3 for start
                mov     word ptr i_low, 0       ; i_low=0

 loc_1026C:                                     
                mov     ax, word ptr i_high     ; arg_high=i_high;
                mov     word ptr arg_high, ax
                mov     ax, word ptr i_low      ; arg_low=i_low;
                mov     word ptr arg_low, ax
                call    getsum                  ; getsum(void)
                mov     ax, word ptr sum_high   ; tmp_high=sum_high;
                mov     word ptr tmp_high, ax   
                mov     ax, word ptr sum_low    ; tmp_low=sum_low;
                mov     word ptr tmp_low, ax
                mov     ax, word ptr tmp_high   ; arg_high=tmp_high;
                mov     word ptr arg_high, ax
                mov     ax, word ptr tmp_low    ; arg_low=tmp_low;
                mov     word ptr arg_low, ax
                call    getsum                 ; getsum(void)
                mov     ax, word ptr i_high
                cmp     ax, word ptr sum_high  ; i_high==sum_high ?
                jnz     short loc_102D3
                mov     ax, word ptr i_low
                cmp     ax, word ptr sum_low   ; i_low==sum_low
                jnz     short loc_102D3
                mov     ax, word ptr i_high    
                cmp     ax, word ptr tmp_high  ; i_high>tmp_high
                jbe     short loc_102B3
                jmp     short loc_102D3

 loc_102B3:                              
                mov     ax, word ptr i_high    ; i_high==tmp_high
                cmp     ax, word ptr tmp_high
                jnz     short loc_102C7
                mov     ax, word ptr i_low
                cmp     ax, word ptr tmp_low   ; i_low>=tmp_low
                jb      short loc_102C7
                jmp     short loc_102D3

 loc_102C7:                              
                                         
                mov     ax, word ptr i_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr i_low
                mov     word ptr out_low, ax
                call    output
                mov     ax, word ptr tmp_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr tmp_low
                mov     word ptr out_low, ax
                call    output
                mov	    ah, 2
                mov     dl, 13
                int     21h
                mov     dl, 10
                int     21h

 loc_102D3:                              
                                        
                inc     word ptr i_low
                cmp     word ptr i_low, 0
                jz      tmp_jmp2
                jmp     loc_1026C
; part 3 end
tmp_jmp2:       jmp     loc_10363
; if (i_high==max_high)
 loc_102DC:                              
                mov     ax, word ptr i_high
                cmp     ax, word ptr max_high        ; i_high==max_high
                jnz     tmp_jmp2
                mov     word ptr i_low, 0       ; i_low = 0
                jmp     loc_10358

 loc_102ED:                              
                mov     ax, word ptr i_high     ; arg_high=i_high;
                mov     word ptr arg_high, ax   
                mov     ax, word ptr i_low      ; arg_low=i_low;
                mov     word ptr arg_low, ax
                call    getsum                  ; getsum(void)
                mov     ax, word ptr sum_high
                mov     word ptr tmp_high, ax   ; tmp_high=sum_high;
                mov     ax, word ptr sum_low
                mov     word ptr tmp_low, ax    ; tmp_low=sum_low;
                mov     ax, word ptr tmp_high
                mov     word ptr arg_high, ax   ; arg_high=tmp_high;
                mov     ax, word ptr tmp_low
                mov     word ptr arg_low, ax    ; arg_low=tmp_low;
                call    getsum                  ; getsum(void)
; if (i_high==sum_high && i_low==sum_low )
                mov     ax, word ptr i_high     ; i_high==sum_high
                cmp     ax, word ptr sum_high
                jnz     short loc_10354
                mov     ax, word ptr i_low      ; i_low==sum_low
                cmp     ax, word ptr sum_low
                jnz     short loc_10354
                mov     ax, word ptr i_high     ; i_high>tmp_high
                cmp     ax, word ptr tmp_high
                jbe     short loc_10334
                jmp     short loc_10354

 loc_10334:                              
                mov     ax, word ptr i_high     ; i_high==tmp_high
                cmp     ax, word ptr tmp_high
                jnz     short loc_10348
                mov     ax, word ptr i_low      ; i_low>=tmp_low
                cmp     ax, word ptr tmp_low
                jb      short loc_10348
                jmp     short loc_10354
 ; ---------------------------------------------------------------------------

 loc_10348:                              

                mov     ax, word ptr i_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr i_low
                mov     word ptr out_low, ax
                call    output
                mov     ax, word ptr tmp_high    ; out put !!!
                mov     word ptr out_high, ax
                mov     ax, word ptr tmp_low
                mov     word ptr out_low, ax
                call    output

                mov	    ah, 2
                mov     dl, 13
                int     21h
                mov     dl, 10
                int     21h

 loc_10354:                              
                                        
                inc     word ptr i_low          ; i low ++

 loc_10358:                              
                mov     ax, word ptr i_low
                cmp     ax, word ptr max_low    ; i_low<=max_low
                jbe     fuck2
                jmp     loc_10363 
fuck2:
                jmp     loc_102ED
 loc_10363:                              
                                        
                inc     word ptr i_high         ; i high ++

 loc_10367:                                 
                mov     ax, word ptr i_high 
                cmp     ax, word ptr max_high   ; i_high<=max_high
                ja      loc_10373
                jmp     if1_test1

 loc_10373:                             
                jmp     loc_10377

loc_10377:                             
exit:  	
	            mov     ax, 4c00h
  	            int 21h


getsum          proc near              

                mov     ax, word ptr arg_low
                mov     dx, word ptr arg_high
                mov     cx, 02h
                call    large_div
                mov     word ptr range_low, ax
                mov     word ptr range_high, dx


                push    si
                mov     word ptr sum_high, 0
                mov     word ptr sum_low, 0
; for start
                mov     word ptr j_high, 0
                jmp     loc_100E2

loc_10029:                             
                mov     ax, word ptr j_high
                cmp     ax, word ptr arg_high       ; j_high == arg_high ?
                jnz     short loc_1008E
; f1 start
                mov     word ptr j_low, 0           ; j_low=0
                jmp     short loc_10083             

; if (j_high==arg_high && j_low==arg_low)
loc_1003A:                              
                mov     ax, word ptr j_high         ; j_high==arg_high ? 
                cmp     ax, word ptr arg_high       
                jnz     short loc_1004F
                mov     ax, word ptr j_low
                cmp     ax, word ptr arg_low         ; j_low==arg_low ?
                jnz     short loc_1004F
                jmp     loc_100F0

loc_1004F:                            

                mov     ax, word ptr arg_low
                mov     dx, word ptr arg_high
                mov     cx, word ptr j_low
                cmp     cx, 0
                jz      loc_1007F
                call    large_div                   ; arg % j == 0 ?
                cmp     cx, 00h
                jnz     loc_1007F


                mov     ax, word ptr sum_low
                mov     bx, word ptr sum_high
                mov     cx, word ptr j_low
                mov     dx, word ptr j_high

                add     ax, cx
                adc     bx, dx
            
                mov     word ptr sum_low, ax
                mov     word ptr sum_high, bx

loc_1007F: 
                inc     word ptr j_low          ; j_low ++

loc_10083:                              
                mov     ax, word ptr j_low
                cmp     ax, word ptr range_low    ; j_low<=arg_low ? 
                jbe     short loc_1003A
                jmp     short loc_100DE

; else 
loc_1008E:                              
                mov     word ptr j_low, 0       ; j_low = 0

; if (j_high==arg_high && j_low==arg_low)
loc_10094:                              
                mov     ax, word ptr j_high     
                cmp     ax, word ptr arg_high   ; j_high==arg_high
                jnz     short loc_100A8
                mov     ax, word ptr j_low
                cmp     ax, word ptr arg_low    ; j_low==arg_low
                jnz     short loc_100A8
                jmp     short loc_100F0

loc_100A8:                              

                mov     ax, word ptr arg_low
                mov     dx, word ptr arg_high
                mov     cx, word ptr j_low
                cmp     cx, 0
                jz      loc_100D8
                call    large_div                   ; arg % j == 0 ?
                cmp     cx, 00h
                jnz     loc_100D8


                mov     ax, word ptr sum_low
                mov     bx, word ptr sum_high
                mov     cx, word ptr j_low
                mov     dx, word ptr j_high

                add     ax, cx
                adc     bx, dx
            
                mov     word ptr sum_low, ax
                mov     word ptr sum_high, bx

loc_100D8:                              
                inc     word ptr j_low      ; j low ++
                cmp     word ptr j_low, 0
                je      loc_100DE
                jmp     short loc_10094

loc_100DE:                              
                inc     word ptr j_high     ; j high ++

loc_100E2:                             
                mov     ax, word ptr j_high
                cmp     ax, word ptr range_high   ; j_high<=arg_high ?
                ja      loc_100EE
                jmp     loc_10029

loc_100EE:                              
                jmp     loc_100F0

loc_100F0:                                                   
                pop     si
                ret
getsum          endp

codesg ends

end start