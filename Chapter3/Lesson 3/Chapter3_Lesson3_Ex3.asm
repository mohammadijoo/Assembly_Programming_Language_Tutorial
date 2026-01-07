; Chapter 3 - Lesson 3 (Ex3)
; DD and DQ: 32-bit and 64-bit storage, and "pointer-looking" data
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3

default rel
global _start

section .data
hex_digits  db "0123456789ABCDEF"
msg         db "DD/DQ demo: dword, qword, and storing addresses", 10
msg_len     equ $-msg

d1          dd 0x11223344
q1          dq 0x1122334455667788

; dq can also hold addresses. This will assemble into a relocation for q1.
ptr_to_q1   dq q1

; Mixed definitions: NASM just emits bytes in order.
mixed:
    db 0xAA
    dd 0x01020304
    dq 0x0A0B0C0D0E0F1011
mixed_len   equ $-mixed

section .bss
outbuf      resb 512

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; print_hex64(rax=value). Writes 16 hex digits + newline.
print_hex64:
    push rbx
    push rcx
    push rdx

    mov rbx, outbuf
    mov rcx, 16            ; 16 nibbles

.hex_loop:
    mov rdx, rax
    shr rdx, 60
    and edx, 0x0F
    mov dl, byte [hex_digits + rdx]
    mov byte [rbx], dl
    inc rbx
    shl rax, 4
    loop .hex_loop

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

    ; Inspect raw bytes for d1 (4 bytes) and q1 (8 bytes)
    mov rsi, d1
    mov rdx, 4
    call dump_bytes

    mov rsi, q1
    mov rdx, 8
    call dump_bytes

    ; Show what ptr_to_q1 contains (address of q1) as 64-bit hex
    mov rax, [ptr_to_q1]
    call print_hex64

    ; Dump mixed region bytes
    mov rsi, mixed
    mov rdx, mixed_len
    call dump_bytes

    mov eax, 60
    xor edi, edi
    syscall
