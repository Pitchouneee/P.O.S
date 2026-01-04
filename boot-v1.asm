; Minimal x86 boot sector (BIOS, 16-bit real mode)
; Goal: display "P.O.S" then remain blocked

[org 0x7c00]    ; The BIOS loads the boot sector at address 0x7C00
                ; ORG tells the assembler that this code is "intended" to run at 0x7C00

mov ah, 0x0e    ; AH = 0x0E -> BIOS video function INT 10h: teletype output
                ; (displays the character stored in AL)

mov al, 'P' ; AL = ASCII code of 'P'
int 0x10    ; BIOS video call -> displays 'P'

mov al, '.' ; AL = '.'
int 0x10    ; display '.'

mov al, 'O' ; AL = 'O'
int 0x10    ; display 'O'

mov al, '.' ; AL = '.'
int 0x10    ; display '.'

mov al, 'S' ; AL = 'S'
int 0x10    ; display 'S'

jmp $   ; Infinite loop: jump to the current instruction
        ; Prevents the CPU from executing padding/signature as code

times 510-($-$$) db 0   ; Fill (padding) with zeros up to byte 510
                        ; $  = current position
                        ; $$ = beginning of the code (origin)
                        ; ($-$$) = size already generated
                        ; The signature must occupy the last 2 bytes (512 total)

dw 0xAA55   ; Mandatory bootable signature at the end of the sector (2 bytes)
            ; In memory: 55 AA (little-endian), but the value is 0xAA55
