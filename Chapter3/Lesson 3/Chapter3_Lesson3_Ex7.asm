; Chapter 3 - Lesson 3 (Ex7)
; Alignment: observing addresses and controlling alignment with ALIGN
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Alignment demo: label addresses and address mod constraints", 10
msg_len    equ $-msg

; Intentionally misalign a qword by putting it right after 1 byte.
mis0       db 0x00
mis_q      dq 0x1122334455667788

; Now force alignment to 8 and 16.
align 8
a8_q       dq 0x0102030405060708

align 16
a16_q      dq 0x0A0B0C0D0E0F1011

nl         db 10

section .bss
outbuf     resb 128

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; print_hex64(rax) -> 16 digits + newline
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

; print_addr_and_mod(rsi=label_address, rdx=mask) prints:
;   address (hex)
;   address & mask (hex)
print_addr_and_mod:
    mov rax, rsi
    call print_hex64
    mov rax, rsi
    and rax, rdx
    call print_hex64
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    ; Address of mis_q, and mis_q & 7 (alignment-to-8 remainder)
    lea rsi, [mis_q]
    mov rdx, 7
    call print_addr_and_mod

    ; Address of a8_q, and a8_q & 7
    lea rsi, [a8_q]
    mov rdx, 7
    call print_addr_and_mod

    ; Address of a16_q, and a16_q & 15
    lea rsi, [a16_q]
    mov rdx, 15
    call print_addr_and_mod

    mov eax, 60
    xor edi, edi
    syscall
