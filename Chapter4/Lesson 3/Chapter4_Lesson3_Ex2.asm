; Chapter4_Lesson3_Ex2.asm
; Topic: Bit test / set / clear / complement using BT/BTS/BTR/BTC (Linux x86-64, NASM)
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex2.asm -o Chapter4_Lesson3_Ex2.o
;   ld -o Chapter4_Lesson3_Ex2 Chapter4_Lesson3_Ex2.o
; Run:
;   ./Chapter4_Lesson3_Ex2

BITS 64
default rel
global _start

section .data
msg_title   db "BT/BTS/BTR/BTC on a 64-bit bitmap", 10, 0
msg_init    db "initial bitmap = ", 0
msg_set     db "after set bit 5 (BTS) = ", 0
msg_clr     db "after clear bit 3 (BTR) = ", 0
msg_tgl     db "after toggle bit 63 (BTC) = ", 0
msg_cf      db "CF (old bit) = ", 0
nl          db 10, 0

bitmap      dq 0x0000000000000009  ; bits 0 and 3 set

section .bss
hexbuf      resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    ; print initial bitmap
    lea rdi, [msg_init]
    call print_cstr
    mov rdi, [bitmap]
    call print_hex64_nl

    ; BTS: set bit 5, CF gets old bit 5
    mov rax, [bitmap]
    bts rax, 5
    mov [bitmap], rax

    lea rdi, [msg_set]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    lea rdi, [msg_cf]
    call print_cstr
    xor edi, edi
    adc edi, 0                ; edi = CF
    mov rdi, rdi              ; keep as 64-bit value
    call print_hex64_nl

    ; BTR: clear bit 3, CF gets old bit 3
    mov rax, [bitmap]
    btr rax, 3
    mov [bitmap], rax

    lea rdi, [msg_clr]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    lea rdi, [msg_cf]
    call print_cstr
    xor edi, edi
    adc edi, 0
    call print_hex64_nl

    ; BTC: toggle bit 63, CF gets old bit 63
    mov rax, [bitmap]
    btc rax, 63
    mov [bitmap], rax

    lea rdi, [msg_tgl]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    lea rdi, [msg_cf]
    call print_cstr
    xor edi, edi
    adc edi, 0
    call print_hex64_nl

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

; -----------------------
; I/O helpers (same as Ex1)
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
