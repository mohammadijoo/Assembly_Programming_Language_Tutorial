; Chapter3_Lesson1_Ex8.asm
; Lesson goal: .bss is zero-initialized by the loader; initialize at runtime too.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8
; Run:
;   ./ex8

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
hex_digits db "0123456789abcdef"
m0 db "First 16 bytes of .bss buffer at entry:", 10, 0
m1 db "After filling with 0xCC (rep stosb):", 10, 0

section .bss
align 16
buf resb 64

section .text
global _start

print_16_bytes_hex:
    ; RSI points to buffer, prints 16 bytes as "xx " tokens + newline.
    push rbx
    xor rbx, rbx
.loop:
    cmp rbx, 16
    jae .done

    mov al, [rsi + rbx]
    mov r8b, al

    sub rsp, 8
    lea rdi, [rsp]
    mov al, r8b
    shr al, 4
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 0], al

    mov al, r8b
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 1], al

    mov byte [rdi + 2], ' '
    sys_write FD_STDOUT, rdi, 3
    add rsp, 8

    inc rbx
    jmp .loop

.done:
    sub rsp, 8
    mov byte [rsp], 10
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8
    pop rbx
    ret

_start:
    lea rdi, [m0]
    call write_z

    lea rsi, [buf]
    call print_16_bytes_hex

    ; Fill buffer with 0xCC
    lea rdi, [buf]
    mov rcx, 64
    mov al, 0xCC
    rep stosb

    lea rdi, [m1]
    call write_z

    lea rsi, [buf]
    call print_16_bytes_hex

    sys_exit 0
