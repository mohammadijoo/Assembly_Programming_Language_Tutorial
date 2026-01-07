; Chapter 3 - Lesson 3 (Ex2)
; DW: 16-bit words and little-endian layout
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
;   ./ex2

default rel
global _start

section .data
hex_digits  db "0123456789ABCDEF"

msg         db "DW demo: inspect word bytes (little-endian)", 10
msg_len     equ $-msg

w1          dw 0x1234
w2          dw 0xABCD
w3          dw 'A'              ; character constant promoted to 16-bit value 0x0041
w_arr       dw 0x0102, 0x0304, 0x0506
w_arr_len   equ $-w_arr

newline     db 10

section .bss
outbuf      resb 512

section .text
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

dump_bytes:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rsi
    mov r13, rdx
    xor r14d, r14d
    mov rbx, outbuf

.loop:
    cmp r14, r13
    je .done
    mov al, byte [r12 + r14]
    mov ah, al
    shr al, 4
    and ah, 0x0F

    movzx eax, al
    mov dl, byte [hex_digits + rax]
    mov byte [rbx], dl
    inc rbx

    movzx eax, ah
    mov dl, byte [hex_digits + rax]
    mov byte [rbx], dl
    inc rbx

    mov byte [rbx], ' '
    inc rbx
    inc r14
    jmp .loop

.done:
    mov byte [rbx], 10
    inc rbx

    mov rsi, outbuf
    mov rdx, rbx
    sub rdx, rsi
    call write_stdout

    pop r14
    pop r13
    pop r12
    pop rbx
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    ; Each DW is 2 bytes. Dump individually to see endian order.
    mov rsi, w1
    mov rdx, 2
    call dump_bytes

    mov rsi, w2
    mov rdx, 2
    call dump_bytes

    mov rsi, w3
    mov rdx, 2
    call dump_bytes

    ; Dump array of words (6 bytes)
    mov rsi, w_arr
    mov rdx, w_arr_len
    call dump_bytes

    mov eax, 60
    xor edi, edi
    syscall
