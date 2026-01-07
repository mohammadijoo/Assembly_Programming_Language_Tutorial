; Chapter 3 - Lesson 3 (Ex10) - Exercise 2 Solution
; Hard: Implement endian swaps for 16/32/64-bit values and validate by printing.
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
;   ./ex10

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Exercise 2: endian swap16/swap32/swap64 (verify in hex)", 10
msg_len    equ $-msg

val16      dw 0x1234
val32      dd 0x11223344
val64      dq 0x1122334455667788

section .bss
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

; swap16: input AX, output AX
swap16:
    rol ax, 8
    ret

; swap32: input EAX, output EAX
swap32:
    bswap eax
    ret

; swap64: input RAX, output RAX
swap64:
    bswap rax
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    ; 16-bit test: print before and after in 64-bit format for uniformity
    movzx eax, word [val16]
    movzx rax, eax
    call print_hex64

    mov ax, word [val16]
    call swap16
    movzx eax, ax
    movzx rax, eax
    call print_hex64

    ; 32-bit test
    mov eax, dword [val32]
    movzx rax, eax
    call print_hex64

    mov eax, dword [val32]
    call swap32
    movzx rax, eax
    call print_hex64

    ; 64-bit test
    mov rax, qword [val64]
    call print_hex64

    mov rax, qword [val64]
    call swap64
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
