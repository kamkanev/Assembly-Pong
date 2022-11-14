BITS 16

jmp title_screen

%include "boot.asm"
%include "pong.asm"

title_screen:

    call set_video_mode
    mov ah, 01h
    int 16h
    je title_screen
    
    call pong

; The bios loads exact 512 bytes. Here we fill this file to byte 510 with zeros
; and the add a "boot signature", whatever this shit is.
	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature