; Chapter 3 - Lesson 3 (Ex4)
; Operand sizes: why NASM needs explicit size, and how loads interpret bytes.
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Operand-size discipline: byte/word/dword/qword loads", 10
msg_len    equ $-msg

; 8 bytes in memory, chosen to make endian effects obvious.
buf        db 0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88

section .bss
outbuf     resb 128

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; print_hex64(rax=value) -> 16 hex digits + newline
print_hex64:
    push rbx
    push rcx
    push rdx

    mov rbx, outbuf
    mov rcx, 16

.loop:
    mov rdx, rax
    shr rdx, 60
    and edx, 0x0F
    mov dl, byte [hex_digits + rdx]
    mov byte [rbx], dl
    inc rbx
    shl rax, 4
    loop .loop

    mov byte [rbx], 10
    inc rbx

    mov rsi, outbuf
    mov rdx, rbx
    sub rdx, rsi
    call write_stdout

    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    ; 1) Load 8 bytes as a 64-bit integer
    mov rax, qword [buf]
    call print_hex64

    ; 2) Load 4 bytes as a 32-bit integer (zero-extends to 64-bit in rax when using eax)
    mov eax, dword [buf]
    movzx rax, eax
    call print_hex64

    ; 3) Load 2 bytes as a 16-bit integer (zero-extend)
    movzx eax, word [buf]
    movzx rax, eax
    call print_hex64

    ; 4) Load 1 byte as an unsigned integer (zero-extend)
    movzx eax, byte [buf]
    movzx rax, eax
    call print_hex64

    ; 5) Signed vs unsigned byte load
    ; buf[1] = 0x22 is positive in signed byte; demonstrate pattern anyway.
    movsx eax, byte [buf+1]
    movsxd rax, eax
    call print_hex64

    ; Notes:
    ; - If you write: mov rax, [buf] NASM can infer qword because of rax.
    ; - If you write: mov [buf], 1 NASM cannot infer size and you must specify:
    ;     mov byte [buf], 1

    mov eax, 60
    xor edi, edi
    syscall
