; Chapter4_Lesson3_Ex9.asm
; Solution: Exercise 3 (Very Hard) - Popcount for 128-bit integer with CPUID gating
; API:
;   popcount_u128(ptr=rdi) -> rax (count in [0..128])
; where *ptr is 16 bytes little-endian: [low_qword][high_qword].
; - If POPCNT available: use it for both qwords
; - Otherwise: use SW Hamming weight fallback for both qwords
;
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex9.asm -o Chapter4_Lesson3_Ex9.o
;   ld -o Chapter4_Lesson3_Ex9 Chapter4_Lesson3_Ex9.o
; Run:
;   ./Chapter4_Lesson3_Ex9

BITS 64
default rel
global _start

section .data
msg_title db "popcount_u128 demo (HW POPCNT when available)", 10, 0
msg_x     db "X(low) = ", 0
msg_y     db "X(high)= ", 0
msg_pc    db "popcount_u128 = ", 0
nl        db 10, 0

X128      dq 0x0123456789ABCDEF, 0xF0F0F0F00F0F0F0F

section .bss
hexbuf    resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    lea rbx, [X128]
    lea rdi, [msg_x]
    call print_cstr
    mov rdi, [rbx]
    call print_hex64_nl

    lea rdi, [msg_y]
    call print_cstr
    mov rdi, [rbx+8]
    call print_hex64_nl

    mov rdi, rbx
    call popcount_u128
    lea rdi, [msg_pc]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

popcount_u128:
    push rbx
    mov rbx, rdi
    call has_popcnt
    test eax, eax
    jz .sw

    mov rax, [rbx]
    popcnt rax, rax
    mov rcx, [rbx+8]
    popcnt rcx, rcx
    add rax, rcx
    pop rbx
    ret

.sw:
    mov rdi, [rbx]
    call popcount_u64_sw
    mov r8, rax
    mov rdi, [rbx+8]
    call popcount_u64_sw
    add rax, r8
    pop rbx
    ret

has_popcnt:
    push rbx
    mov eax, 1
    cpuid
    bt ecx, 23
    setc al
    movzx eax, al
    pop rbx
    ret

popcount_u64_sw:
    mov rax, rdi
    mov rcx, rax
    shr rcx, 1
    and rcx, 0x5555555555555555
    sub rax, rcx

    mov rcx, rax
    and rax, 0x3333333333333333
    shr rcx, 2
    and rcx, 0x3333333333333333
    add rax, rcx

    mov rcx, rax
    shr rcx, 4
    add rax, rcx
    and rax, 0x0F0F0F0F0F0F0F0F

    mov rcx, rax
    shr rcx, 8
    add rax, rcx
    mov rcx, rax
    shr rcx, 16
    add rax, rcx
    mov rcx, rax
    shr rcx, 32
    add rax, rcx
    and rax, 0x7F
    ret

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
