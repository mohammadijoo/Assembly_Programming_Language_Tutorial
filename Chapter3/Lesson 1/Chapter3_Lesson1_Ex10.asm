; Chapter3_Lesson1_Ex10.asm
; Programming Exercise 1 (solution):
; Implement a reusable hexdump(buffer, len) that prints offset + bytes, 16 per line.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex10.asm -o ex10.o
;   ld ex10.o -o ex10
; Run:
;   ./ex10

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
hex_digits db "0123456789abcdef"
intro db "Exercise 1 solution: hexdump with offsets", 10, 0

section .data
align 1
sample db 0x00,0x01,0x02,0x03,0x10,0x11,0x12,0x13
       db 0x20,0x21,0x22,0x23,0x30,0x31,0x32,0x33
       db 0x41,0x42,0x43,0x44,0x7F,0x80,0xFE,0xFF

section .text
global _start

; write_hex_u8:
;   input AL = byte
;   prints "xx"
write_hex_u8:
    sub rsp, 8
    lea rdi, [rsp]

    mov r8b, al
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

    sys_write FD_STDOUT, rdi, 2
    add rsp, 8
    ret

; hexdump:
;   input RSI = pointer, RCX = length
;   prints: 0000000000000000: xx xx ... (16 bytes) newline
hexdump:
    push rbx
    push r12
    xor rbx, rbx             ; offset
.outer:
    cmp rbx, rcx
    jae .done

    ; print offset label (16 hex digits) then ": "
    mov rax, rbx
    sub rsp, 32
    lea rdi, [rsp]
    call hex64_to_ascii
    mov byte [rsp+16], ':'
    mov byte [rsp+17], ' '
    sys_write FD_STDOUT, rsp, 18
    add rsp, 32

    ; print up to 16 bytes
    mov r12, 0
.inner:
    cmp rbx, rcx
    jae .newline
    cmp r12, 16
    jae .newline

    mov al, [rsi + rbx]
    call write_hex_u8

    ; space
    sub rsp, 8
    mov byte [rsp], ' '
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8

    inc rbx
    inc r12
    jmp .inner

.newline:
    sub rsp, 8
    mov byte [rsp], 10
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8
    jmp .outer

.done:
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [intro]
    call write_z

    lea rsi, [sample]
    mov rcx, sample_end - sample
    call hexdump

    sys_exit 0

sample_end:
