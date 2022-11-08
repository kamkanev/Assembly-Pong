BITS 16
	mov 	ax, 07C0h
	mov 	ds, ax		
	;; Set video mode 0, 40x25 B/W text
	xor 	ax,ax
	int 	10h

	mov 	si, msg_h
	;; int 10,e - teletype mode
	mov 	ah, 0eh
loop:
	;; Load byte from [ds:si] into al and increment si.
	lodsb               
	int 	10h
	;; Check for end of string
	test 	al, al
	jnz	loop
	;; $ refers to the address of the beginning of the line
	;; Therefore this is an infinite loop
	jmp 	$
msg_h:	db "Hello, world!", 0
	;; Fill the rest of the file with zeros.
	times 510-($-$$) db 0    
	dw 0xaa55
