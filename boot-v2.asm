[org 0x7c00]

mov bp, 0x8000  ; BP (Base Pointer): We place the base of the stack at 0x8000
                ; Why 0x8000? Our code is at 0x7C00
                ; 0x8000 is further away in memory, leaving enough space
                ; for the stack to grow without overwriting our code

mov sp, bp      ; SP (Stack Pointer): At the beginning, the stack is empty,
                ; so the top (SP) is equal to the base (Base Pointer).

mov bx, welcome_msg ; Load the address of the welcome_msg message into BX
                    ; BX is used here as a "pointer" (like *ptr in C)
call print_str

mov bx, pos_msg ; Load the address of the second message into BX
call print_str

jmp $

print_str:
        pusha   ; Save context, "Push All" registers (AX, BX, CX, etc.) onto the Stack
                ; This prevents the function from modifying the main program's registers
        mov ah, 0x0e

.loop:  ; Start of the display loop
        mov al, [bx]    ; dereferencing! the brackets [] mean "take the value at address BX"
                        ; If BX = 0x7C1E, AL receives the letter stored at 0x7C1E

        cmp al, 0       ; Is the character 0 (null terminator)?
        je .done        ; If yes (Jump if Equal), we are done, jump to .done

        int 0x10        ; Otherwise call the BIOS to display the character in AL

        inc bx          ; Increment pointer BX to move to the next character in memor
        jmp .loop       ; Repeat the loop

.done:
        popa            ; Restore context
                        ; "Pop All": Restores register values from the Stack
                        ; They return exactly to their state before the function call
        ret             ; RETURN: Pop the return address and jump back to main

; 0x0d = CR (Carriage Return)
; 0x0a = LF (Line Feed)
; 0    = End-of-string character (Null byte)
welcome_msg: db 'Welcome on the OS better than Windows', 0x0d, 0x0a, 0
pos_msg: db 'P.O.S', 0x0d, 0x0a, 0

times 510-($-$$) db 0
dw 0xAA55