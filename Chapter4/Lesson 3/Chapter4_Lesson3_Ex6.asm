; Chapter4_Lesson3_Ex6.asm
; Topic: Packing/unpacking bitfields (RGBA example) and masked updates (Linux x86-64, NASM)
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex6.asm -o Chapter4_Lesson3_Ex6.o
;   ld -o Chapter4_Lesson3_Ex6 Chapter4_Lesson3_Ex6.o
; Run:
;   ./Chapter4_Lesson3_Ex6

BITS 64
default rel
global _start

section .data
msg_title db "Packing/unpacking: RGBA into a 32-bit word", 10, 0
msg_rgba  db "packed RGBA = ", 0
msg_r     db "R = ", 0
msg_g     db "G = ", 0
msg_b     db "B = ", 0
msg_a     db "A = ", 0
nl        db 10, 0

; Components (8-bit each)
Rval      db 0x12
Gval      db 0xA4
Bval      db 0x5D
Aval      db 0xFF

section .bss
hexbuf    resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    ; Pack: [31..24]=A, [23..16]=B, [15..8]=G, [7..0]=R
    movzx eax, byte [Rval]
    movzx ebx, byte [Gval]
    movzx ecx, byte [Bval]
    movzx edx, byte [Aval]

    shl ebx, 8
    shl ecx, 16
    shl edx, 24
    or eax, ebx
    or eax, ecx
    or eax, edx            ; eax now holds RGBA packed

    lea rdi, [msg_rgba]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; Unpack with shifts + masks (keep each in 8 bits)
    ; R
    lea rdi, [msg_r]
    call print_cstr
    mov ebx, eax
    and ebx, 0xFF
    mov rdi, rbx
    call print_hex64_nl

    ; G
    lea rdi, [msg_g]
    call print_cstr
    mov ebx, eax
    shr ebx, 8
    and ebx, 0xFF
    mov rdi, rbx
    call print_hex64_nl

    ; B
    lea rdi, [msg_b]
    call print_cstr
    mov ebx, eax
    shr ebx, 16
    and ebx, 0xFF
    mov rdi, rbx
    call print_hex64_nl

    ; A
    lea rdi, [msg_a]
    call print_cstr
    mov ebx, eax
    shr ebx, 24
    and ebx, 0xFF
    mov rdi, rbx
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

; -----------------------
; I/O helpers
; -----------------------
print_cstr:
    push rdi
    call cstr_len
    pop rsi
    mov rdx, rax
    mov edi, 1
    mov eax, 1
    syscall
    ret

cstr_len:
    xor eax, eax
.len_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    ret

print_hex64_nl:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rsi, [hexbuf]
    mov byte [rsi + 0], '0'
    mov byte [rsi + 1], 'x'

    mov rax, rdi
    mov rcx, 16
    lea rbx, [rsi + 2 + 15]

.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    cmp dl, 9
    jbe .digit
    add dl, 7
.digit:
    add dl, '0'
    mov [rbx], dl
    shr rax, 4
    dec rbx
    loop .hex_loop

    mov edi, 1
    lea rsi, [hexbuf]
    mov edx, 18
    mov eax, 1
    syscall

    mov edi, 1
    lea rsi, [nl]
    mov edx, 1
    mov eax, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
