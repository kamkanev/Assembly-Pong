BITS 16

pong:
call start
jmp exit

%include "boot.asm"

%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define ENEMY_X_POS 10
%define ENEMY_COLOR RED

%define PLAYER_WIDTH 5
%define PLAYER_HEIGHT 50
%define PLAYER_X_POS ( SCREEN_WIDTH - PLAYER_WIDTH - ENEMY_X_POS )
%define PLAYER_START_POS ( SCREEN_HEIGHT - PLAYER_HEIGHT ) / 2
%define PLAYER_STEP_SIZE 10
%define PLAYER_COLOR BLUE

%define BALL_SIZE 5
%define BALL_START_X (SCREEN_WIDTH - BALL_SIZE) / 2 
%define BALL_START_Y (SCREEN_HEIGHT - BALL_SIZE) / 2 
%define BALL_COLOR 15
%define BALL_STEP_SIZE 2

%define KEY_UP 048h
%define KEY_DOWN 050h
%define KEY_W 011h
%define KEY_S 01Fh

start:
    ;SETUP STACK
    
    mov ax, 07C0h   ;; 07C0h:0000h is the point we are loaded to
    mov ds, ax      ;; Setup datasegment
    add ax, 020h    ;; The size of the bootloader is 512 bytes.
                    ;; The segment-registers go in 16-byte-steps.
                    ;; So we add (512/16) to it, to go after our bootloader.
    
    
    
    mov ss, ax
    mov sp, 4096    ; Set the size of the stack to 4k
    
    ;Set stack frame
    mov bp, sp
    
    call set_video_mode
    
.main_loop:

        ; SLEEP FOR 33.333 MILISECONDS
	; 33.333 = 0b1000001000110101 Luckily this number fits a 16-bit register.
	mov ah, 86h
	mov cx, 0
	mov dx, 12500
	int 15h	

	; MOVE BALL
	mov ax, [ball_step_x]
	mov bx, [ball_step_y]
	add [ball_x], ax
	add [ball_y], bx
	cmp word [ball_x], ENEMY_X_POS + PLAYER_WIDTH
	jb .enemy_line		; Ball is above enemy, do smthng!
	cmp word [ball_x], PLAYER_X_POS - BALL_SIZE
	ja .player_line		; Ball is below player, do smthng!
	jmp .check_horizontal	; Ball is somewhere in the field, just check
				; if it hits the wall.



.enemy_line:
    mov ax, [enemy_y]	; Check if enemy_y <= ball_x <= enemy_y +
    cmp [ball_y], ax	; player_width
    jb .player_point	; If yes, flip the y_step of the ball.
    add ax, PLAYER_HEIGHT	; Else give the player a point.
    cmp [ball_y], ax
    ja .player_point
    ; BALL HIT ENEMY
    neg word [ball_step_x]
    jmp .check_horizontal	; Just check, if the ball is in the corner.


.player_line:

    mov ax, [player_y]
    cmp [ball_y], ax
    jb .enemy_point
    add ax, PLAYER_HEIGHT
    cmp [ball_y], ax
    ja .enemy_point
    ; BALL HIT PLAYER
    neg word [ball_step_x]
    jmp .check_horizontal
    

.player_point:
    call reset_ball
    inc word [score_player]
    
    cmp word [score_player], 10
    jl .end_player_point
    
    ret
    ;jmp exit
    
.end_player_point:
    
    jmp .check_horizontal

.enemy_point:
    call reset_ball
    inc word [score_enemy]
    
    cmp word[score_enemy], 10
    jl .check_horizontal
    
    ret
    ;jmp exit
    

.check_horizontal:
    mov ax, [ball_y]
    cmp ax, 0
    jb .flip_horizontal
    cmp ax, SCREEN_HEIGHT - BALL_SIZE
    jb .end_move_ball

.flip_horizontal:
    ;Ball hits a wall changes directions
    neg word [ball_step_y]

.end_move_ball:

    ;MOVE PLAYER AND ENEMY
    mov ah, 01h
    int 16h
    je .move_player_done        ;; If no key was pressed, zero_flag=1
    
    mov ah, 00h
    int 16h
    cmp ah, KEY_UP            ;; Scancode stored in ah
    je .player_up
    cmp ah, KEY_DOWN
    je .player_down
    cmp ah, KEY_W
    je .enemy_up
    cmp ah, KEY_S
    je .enemy_down
    jmp .move_player_done

    

.player_down:
	cmp word [player_y], SCREEN_HEIGHT - (PLAYER_STEP_SIZE + PLAYER_HEIGHT)
	ja .move_player_done
	add word [player_y], PLAYER_STEP_SIZE
	jmp .move_player_done

.player_up:	
	cmp word [player_y], PLAYER_STEP_SIZE
	jb .move_player_done
	sub word [player_y], PLAYER_STEP_SIZE
	jmp .move_player_done

.enemy_down:
	cmp word [enemy_y], SCREEN_HEIGHT - (PLAYER_STEP_SIZE + PLAYER_HEIGHT)
	ja .move_player_done
	add word [enemy_y], PLAYER_STEP_SIZE
	jmp .move_player_done

.enemy_up:	
	cmp word [enemy_y], PLAYER_STEP_SIZE
	jb .move_player_done
	sub word [enemy_y], PLAYER_STEP_SIZE

.move_player_done:
        ; Clear the screen
	;push word 0
	;push word 0
	;push word 320
	;push word 200
	;mov ah, 0
	;call draw_rect
        call set_video_mode
        
        ;DRAW SCORE
        mov ah, 02h
        mov bh, 0       ; Page 0
        mov dh, 2       ; Line 2
        mov dl, 29       ; Column 29 for player score
        pusha
        int 0x10
        
        mov ax, [score_player]
        mov bl, PLAYER_COLOR
        call print_score
        popa
        
        mov dl, 10              ; Column 10 for enemy score
        int 0x10
        mov ax, [score_enemy]
        mov bl, ENEMY_COLOR
        call print_score
        
        ;DRAW PLAYER
        push word PLAYER_X_POS        
        push word[player_y]

        push PLAYER_WIDTH
	push PLAYER_HEIGHT
	mov ah, PLAYER_COLOR
	call draw_rect

       ;DRAW ENEMY
        push word ENEMY_X_POS
        push word[enemy_y]

        push PLAYER_WIDTH
	push PLAYER_HEIGHT
	mov ah, ENEMY_COLOR
	call draw_rect

        ;DRAW BALL
        push word [ball_x]
	push word [ball_y]
	push BALL_SIZE
	push BALL_SIZE
	mov ah, BALL_COLOR
	call draw_rect

        jmp .main_loop
        

reset_ball:
    
    mov word[ball_x], BALL_START_X
    mov word[ball_y], BALL_START_Y
    ret
exit:

; ###############################
; #	Data Segment		#
; ###############################

	ball_x dw BALL_START_X
	ball_y dw BALL_START_Y
	ball_step_x dw BALL_STEP_SIZE
	ball_step_y dw BALL_STEP_SIZE

	score_player dw 0
	score_enemy dw 0

	player_y dw PLAYER_START_POS
	enemy_y dw PLAYER_START_POS

; The bios loads exact 512 bytes. Here we fill this file to byte 510 with zeros
; and the add a "boot signature", whatever this shit is.
	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
