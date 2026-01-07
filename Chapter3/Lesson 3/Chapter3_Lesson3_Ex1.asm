; Chapter 3 - Lesson 3 (Ex1)
; Data Types in Assembly (DB, DW, DD, DQ) - DB fundamentals
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson3_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1

default rel
global _start

section .data
hex_digits  db "0123456789ABCDEF"
title       db "DB demo: byte sequences and strings", 10
title_len   equ $-title

; DB defines raw bytes. There is no "type" in memory, only bytes.
bytes1      db 0x00, 0x7F, 0x80, 0xFF, 'A', 'z'
bytes1_len  equ $-bytes1

; Strings are just bytes. Here we also include a NUL terminator to mimic C strings.
hello_cstr  db "Hello, NASM", 0
hello_len   equ $-hello_cstr

; You can duplicate data with TIMES.
pattern     db 0x5A
bytes2      times 16 db 0x5A
bytes2_len  equ $-bytes2

newline     db 10

section .bss
outbuf      resb 512

section .text

; write(fd=1, buf=rsi, len=rdx)
write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; dump_bytes(rsi=ptr, rdx=len)
; Prints: two hex chars per byte + space, then newline.
dump_bytes:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rsi            ; data ptr
    mov r13, rdx            ; data len
    xor r14d, r14d          ; i = 0
    mov rbx, outbuf         ; dst

.dump_loop:
    cmp r14, r13
    je .done

    mov al, byte [r12 + r14]
    mov ah, al
    shr al, 4
    and ah, 0x0F

    movzx eax, al
    mov dl, byte [hex_digits + rax]     ; high nibble
    mov byte [rbx], dl
    inc rbx

    movzx eax, ah
    mov dl, byte [hex_digits + rax]     ; low nibble
    mov byte [rbx], dl
    inc rbx

    mov byte [rbx], ' '
    inc rbx

    inc r14
    jmp .dump_loop

.done:
    mov byte [rbx], 10
    inc rbx

    ; write outbuf, length = rbx - outbuf
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
    ; Print title
    mov rsi, title
    mov rdx, title_len
    call write_stdout

    ; Dump bytes1
    mov rsi, bytes1
    mov rdx, bytes1_len
    call dump_bytes

    ; Dump hello_cstr (includes terminating 0 byte)
    mov rsi, hello_cstr
    mov rdx, hello_len
    call dump_bytes

    ; Dump bytes2 (TIMES duplication)
    mov rsi, bytes2
    mov rdx, bytes2_len
    call dump_bytes

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall
