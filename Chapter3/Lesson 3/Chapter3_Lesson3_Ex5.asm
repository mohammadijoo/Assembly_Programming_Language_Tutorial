; Chapter 3 - Lesson 3 (Ex5)
; Arrays with DB/DW/DD/DQ and scaled indexing
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Arrays: sum elements with correct element sizes", 10
msg_len    equ $-msg

arr8       db 1,2,3,4,5,6,7,8
arr8_n     equ 8

arr16      dw 1000,2000,3000,4000
arr16_n    equ 4

arr32      dd 0x01020304, 0x05060708, 0x0A0B0C0D
arr32_n    equ 3

arr64      dq 10, 20, 30, 40, 50
arr64_n    equ 5

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

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    ; Sum arr8 (unsigned bytes)
    xor rax, rax
    xor ecx, ecx
.sum8:
    cmp ecx, arr8_n
    je .done8
    movzx edx, byte [arr8 + rcx]
    add rax, rdx
    inc ecx
    jmp .sum8
.done8:
    call print_hex64

    ; Sum arr16 (unsigned words) using scaled index (rcx*2)
    xor rax, rax
    xor ecx, ecx
.sum16:
    cmp ecx, arr16_n
    je .done16
    movzx edx, word [arr16 + rcx*2]
    add rax, rdx
    inc ecx
    jmp .sum16
.done16:
    call print_hex64

    ; Sum arr32 (unsigned dwords) using scaled index (rcx*4)
    xor rax, rax
    xor ecx, ecx
.sum32:
    cmp ecx, arr32_n
    je .done32
    mov edx, dword [arr32 + rcx*4]
    movzx rdx, edx
    add rax, rdx
    inc ecx
    jmp .sum32
.done32:
    call print_hex64

    ; Sum arr64 (qwords) using scaled index (rcx*8)
    xor rax, rax
    xor ecx, ecx
.sum64:
    cmp ecx, arr64_n
    je .done64
    add rax, qword [arr64 + rcx*8]
    inc ecx
    jmp .sum64
.done64:
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
