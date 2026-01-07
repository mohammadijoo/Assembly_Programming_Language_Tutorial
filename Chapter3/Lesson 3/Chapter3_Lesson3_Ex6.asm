; Chapter 3 - Lesson 3 (Ex6)
; Uninitialized storage (.bss) with RESB/RESW/RESD/RESQ + runtime stores
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db ".bss demo: reserved storage is zeroed by the loader", 10
msg_len    equ $-msg

section .bss
b          resb 1
w          resw 1
d          resd 1
q          resq 1
outbuf     resb 128

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

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

    ; Read initial values (should be 0)
    movzx eax, byte [b]
    movzx rax, eax
    call print_hex64

    movzx eax, word [w]
    movzx rax, eax
    call print_hex64

    mov eax, dword [d]
    movzx rax, eax
    call print_hex64

    mov rax, qword [q]
    call print_hex64

    ; Store some values with explicit sizes
    mov byte [b], 0xFE
    mov word [w], 0x1234
    mov dword [d], 0x89ABCDEF
    mov qword [q], 0x1122334455667788

    ; Read back
    movzx eax, byte [b]
    movzx rax, eax
    call print_hex64

    movzx eax, word [w]
    movzx rax, eax
    call print_hex64

    mov eax, dword [d]
    movzx rax, eax
    call print_hex64

    mov rax, qword [q]
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
