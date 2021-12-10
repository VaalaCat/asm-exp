assume ss:sseg, cs:cseg, ds:dseg

dseg segment
	buf  db 8
	     db ?
	     db 8 dup(?)
	str  db 8
	     db ?
	     db 8 dup(?)
	num  dw ?
	min  db "Start at :",'$'
	max  db "End at :",'$'
dseg ends 

sseg segment stack
	     dw 64 dup(?)
sseg ends

cseg segment

transform proc near
	             xor  ch, ch
	             mov  cl, buf[1]
	             xor  dx, dx
	             mov  si, 0
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
	             mov  ax,dseg
	             mov  ds,ax
	             mov  ax,sseg
	             mov  ss,ax
	             mov  sp,20h
	             mov  bp,sp
	             sub  sp,10h

	             mov  dx,offset min
	             mov  ah,09h
	             int  21h

	             lea  dx, buf
	             mov  ah, 0ah
	             int  21h
	             call transform
	             mov  ss:[bp-8],ax

	             mov  ah, 2
	             mov  dl, 13
	             int  21h
	             mov  dl, 10
	             int  21h

	             mov  dx,offset max
	             mov  ah,09h
	             int  21h

	             lea  dx, buf
	             mov  ah, 0ah
	             int  21h
	             call transfor
	             loop re
	             mov  byte ptr [di],'$'

	fi:          mov  dx,offset str
	             mov  ah,09h
	             int  21h
		
	             mov  sp,bp
	             pop  bp
	             ret
print endp

cseg ends
	mov byte ptr [di],'$'
	jmp fi					

	pop ax
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