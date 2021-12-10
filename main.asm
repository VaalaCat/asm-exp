assume ss:sseg, cs:cseg, ds:dseg

dseg segment 
buf db 8
    db ?
    db 8 dup(?)
str db 8
    db ?
    db 8 dup(?)
num dw ?  
min db "Min :",'$'
max db "Max :",'$'
dseg ends 

sseg segment stack
    dw 64 dup(?)
sseg ends

cseg segment 

transform proc near
    xor ch, ch
    mov cl, buf[1]
    xor dx, dx 
    mov si, 0
lop:
    push cx
    mov  ax, dx 
    mov  cl, 3
    shl  dx, cl 
    shl  ax, 1
    add  dx, ax 
    xor  ah, ah 
    mov  al, buf[si+2]
    inc  si 
    sub  al, '0'
    add  dx, ax  
    pop  cx 
    loop lop 
    mov  ax, dx 
    ret
transform endp

; facsum=-10
; min	=-8
; max	=-6
; i		=cx
start:    
    mov ax,dseg
    mov ds,ax 
	mov ax,sseg
	mov ss,ax
	mov sp,20h
	mov bp,sp
	sub sp,10h

	mov dx,offset min
	mov ah,09h
	int 21h

    lea  dx, buf 
    mov  ah, 0ah
    int  21h
    call transform
	mov ss:[bp-8],ax

	mov	ah, 2
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h

	mov dx,offset max
	mov ah,09h
	int 21h

    lea  dx, buf 
    mov  ah, 0ah
    int  21h
    call transform
	mov ss:[bp-6],ax	; max

    mov cx,0dch
	jmp L0t

L0:
    cmp cx,0
    jz  exit
	mov ax,cx	; i
	mov di,ax
	call GetFactorSum
	mov ss:[bp-10],ax	; facsum

	mov ax,ss:[bp-8]
	cmp ss:[bp-10],ax 	; fac >= min ?
	jb  next
	mov ax,ss:[bp-6]
	cmp ss:[bp-10],ax	; fac <= max ?
	ja 	next

	mov ax,ss:[bp-10]
	mov di,ax
	call GetFactorSum
	cmp cx,ax	        ; i == fac(facnum) ?
	jnz next
	cmp cx,ss:[bp-10]	; i < facnum ?
	jnb next

output:
	mov	ah, 2
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h

	push cx
	mov ax,cx
	call print
	pop cx

	mov	ah, 2
	mov dl, '-'
	int 21h
	
	push cx
	mov ax,ss:[bp-10]
	call print
	pop cx

next:
	inc cx  	        ; i++
L0t:
	mov ax,ss:[bp-6]	; max
	cmp cx,ax
	jbe L0

exit:    
    mov ax, 4c00h
    int 21h

GetFactorSum:
; tmp 	=-6
; sum	=-4
; i 	=-2
	push bp
	mov bp,sp
	sub sp,08h

    mov ax,di
    shr ax,1
	mov ss:[bp-6],di
	mov word ptr ss:[bp-2],01h
	mov word ptr ss:[bp-4],00h
	jmp lp 
l:
	mov ax,ss:[bp-6]
	xor dx,dx
	div word ptr ss:[bp-2]
	mov ax,dx
	test ax,ax
	jnz n
	mov ax,ss:[bp-2]
	add ss:[bp-4],ax
n:
	add word ptr ss:[bp-2],1

lp: 
	mov ax,ss:[bp-2]
	cmp ax,ss:[bp-6]
	jb  l

	mov ax,ss:[bp-4]
	mov sp,bp
	pop bp
	ret

print proc near					
	push bp
	mov bp,sp

	mov di,offset str		;di指向要存入的地址
	cmp ax,0				
	jz zero					;ax为0直接跳至zero

	mov bx,10				;每次除10得各位值
	xor cx,cx				;cx存压栈次数

n3:	xor dx,dx				;(dx ax)/bx
	div bx					;余数存dx,商存ax
	push dx					;将当前余数压栈
	inc cx					;cx存压栈次数
	cmp ax,0				;判断商是否为0
	jz re					;为0则跳至reverse
	jmp n3					;否则不为0,继续处理

zero:
;为0,直接存入0
	mov byte ptr [di],'0'
	inc di
	mov byte ptr [di],'$'
	jmp fi					

re:							;此时cx存压栈次数,di指向要存入的地址
	pop ax
	add al,30h				;将数字转化成对应的asii码
	mov [di],al				;注意是al!
	inc di
	loop re
	mov byte ptr [di],'$'

fi:	mov dx,offset str	
	mov ah,09h
	int 21h
		
	mov sp,bp
	pop bp
	ret
print endp

cseg ends
end start