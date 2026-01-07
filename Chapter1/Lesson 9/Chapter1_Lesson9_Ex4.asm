; file: start.asm
default rel

global _start
extern sys_write
extern sys_exit
extern compute_value

section .rodata
msg: db "result = ", 0
nl:  db 10

section .bss
buf: resb 32

section .text

; Convert unsigned integer in EAX to decimal ASCII in [buf], return:
;   RSI = pointer to first digit
;   EDX = length
; Destroys: RAX, RBX, RCX, RDX, RDI, R8
utoa32:
    lea rdi, [buf + 31]
    mov byte [rdi], 0
    mov ebx, 10
    xor ecx, ecx          ; digit count

.u_loop:
    xor edx, edx
    div ebx               ; EDX = remainder, EAX = quotient
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc ecx
    test eax, eax
    jnz .u_loop

    mov rsi, rdi
    mov edx, ecx
    ret

_start:
    ; Call compute_value() in another object:
    call compute_value     ; returns value in EAX

    ; Print "result = "
    mov edi, 1
    lea rsi, [msg]
    mov edx, 9            ; len("result = ")
    call sys_write

    ; Convert EAX to decimal and print digits
    call utoa32
    mov edi, 1
    call sys_write

    ; Print newline
    mov edi, 1
    lea rsi, [nl]
    mov edx, 1
    call sys_write

    ; exit(0)
    xor edi, edi
    call sys_exit
