[org 0x7c00]
    xor ax, ax      ; Clear ax
    mov ds, ax      ; Set data segment to 0
    mov es, ax      ; Set extra segment to 0
    mov si, msg     ; Set si to point to the message
    call print      ; Call print function
    call get_string
    jmp $           ; Infinite loop

print:
    lodsb           ; Load character from si into al
    or al, al       ; Check for null terminator
    jz done         ; If null terminator, jump to done
    mov ah, 0x0e    ; Set teletype mode
    int 0x10        ; Call BIOS interrupt to print character
    jmp print       ; Loop back to print next character


get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret

done:
    ret

msg:
    db "Hello, World!", 0 ; Null-terminated message string

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55 ; Boot signature
