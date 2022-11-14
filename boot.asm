%define BLUE 1
%define RED 4

set_video_mode:
    ;; This sets the video mode
    
    mov ah, 0       ;INterupts set video mode
    mov al, 0x13    ;Set size to 320x100, 256c
    int 0x10
    
    ret

print_score:
    ; THIS FUNCTION PRINTS AN UNSIGNED INTEGER FROM THE AX REGISTER WITH THE
    ; COLOR FROM THE BL REGISTER.
    
    add ax, 30h     ;61h - a     ;Get ascii of int
    mov ah, 09h
    mov bh, 0       ;Page 0
    mov cx, 1       ;Times print: 1
    int 0x10
    
    ret

draw_rect:
    ;This draws a rectangle
    ;It takes 5 parameters:
    ; - ah - color of the rect
    ; - x-possition of the top left corner (stack)
    ; - y-possition of the top left corner (stack)
    ; - the width  (stack)
    ; - the height (stack)
    
    mov cx, 0A000h
    mov es, cx
    
    pop di
    pop dx
    pop cx
    pop bx
    pop si
    push di
    
    mov bp, sp          ;set stack frame
    sub sp, 11          ;allocate 11 bytes on stack
    mov [bp-11], ah     ; save all arguments on stack
    
    mov [bp-2], si
    mov [bp-4], bx
    mov [bp-6], cx
    inc dx
    mov [bp-8], dx
    
    inc cx
    mov [bp-10], cx
    
    
        ; MEMORYMAP:
	; |--------------------- | <- [bp]
	; | x-top-left		|
	; |--------------------- | <- [bp-2]
	; | y-top-left		|
	; |--------------------- | <- [bp-4]
	; | width		|
	; |--------------------- | <- [bp-6]
	; | height		|
	; |--------------------- | <- [bp-8]
	; | loop-var for width	|
	; |--------------------- | <- [bp-10]
	; | color		|
	; |--------------------- | <- [bp-11] ; [sp]

.height_loop:
        cmp word[bp-8], 0
        je .draw_rect_done
        
        ;decrese height stored in stack
        mov ax, [bp-8]
        dec ax
        mov [bp-8], ax
        
        ;restore helper var
        mov ax, [bp-6]
        mov [bp-10], ax
        
.width_loop:
            cmp word[bp-10], 0
            je .height_loop
            
            mov cx, [bp-2]
            add cx, [bp-10]
            
            mov dx, [bp-4]
            add dx, [bp-8]
            
            ;SET PIZEL ON SCREEN
            mov ax, dx
            mov bx, 320
            mul bx
            add ax, cx
            mov bx, ax
            mov cl, [bp-11]
            mov [es:bx], cl
            
            ;decrese helper var
            mov ax, [bp-10]
            dec ax
            mov [bp-10], ax
            
            jmp .width_loop

.draw_rect_done:
        add sp, 11      ;free 11 bytes on stack
        ret