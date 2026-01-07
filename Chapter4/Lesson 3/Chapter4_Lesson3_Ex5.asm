; Chapter4_Lesson3_Ex5.asm
; Topic: Popcount with CPUID feature detection (POPCNT) + software fallback
; Environment: Linux x86-64, NASM
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex5.asm -o Chapter4_Lesson3_Ex5.o
;   ld -o Chapter4_Lesson3_Ex5 Chapter4_Lesson3_Ex5.o
; Run:
;   ./Chapter4_Lesson3_Ex5

BITS 64
default rel
global _start

section .data
msg_title   db "Population count (ones) demo", 10, 0
msg_x       db "X = ", 0
msg_hw      db "popcount via POPCNT = ", 0
msg_sw      db "popcount via SW fallback = ", 0
msg_note    db "Note: POPCNT availability is checked via CPUID.(EAX=1):ECX[23].", 10, 0
nl          db 10, 0

X           dq 0xF0F0F0F00F0F0F0F

section .bss
hexbuf      resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    mov rax, [X]
    lea rdi, [msg_x]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    lea rdi, [msg_note]
    call print_cstr

    ; software popcount always available
    mov rdi, [X]
    call popcount_u64_sw
    lea rdi, [msg_sw]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; hardware popcount if supported
    call has_popcnt
    test eax, eax
    jz .done

    mov rax, [X]
    popcnt rax, rax
    lea rdi, [msg_hw]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

.done:
    mov eax, 60
    xor edi, edi
    syscall

; ---------------------------------------
; has_popcnt() -> eax = 1 if POPCNT exists
; CPUID leaf 1: ECX bit 23 indicates POPCNT
; ---------------------------------------
has_popcnt:
    push rbx
    mov eax, 1
    cpuid
    bt ecx, 23
    setc al
    movzx eax, al
    pop rbx
    ret

; ---------------------------------------------------
; popcount_u64_sw(rdi=x) -> rax=count
; Uses a branchless Hamming weight algorithm.
; ---------------------------------------------------
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
