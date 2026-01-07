; Chapter4_Lesson3_Ex4.asm
; Topic: Bit scans (BSF/BSR) and integer log2 floor (Linux x86-64, NASM)
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex4.asm -o Chapter4_Lesson3_Ex4.o
;   ld -o Chapter4_Lesson3_Ex4 Chapter4_Lesson3_Ex4.o
; Run:
;   ./Chapter4_Lesson3_Ex4

BITS 64
default rel
global _start

section .data
msg_title  db "Bit scans: find index of lowest/highest set bit", 10, 0
msg_x      db "X = ", 0
msg_bsf    db "BSF index (low set bit) = ", 0
msg_bsr    db "BSR index (high set bit) = ", 0
msg_lg2    db "log2_floor(X) = ", 0
msg_zero   db "X is zero, indices invalid", 10, 0
nl         db 10, 0

X          dq 0x0000000000801400  ; bits 10, 12, 15 set

section .bss
hexbuf     resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    mov rax, [X]
    lea rdi, [msg_x]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    test rax, rax
    jz .x_zero

    ; BSF: index of lowest set bit
    mov rbx, rax
    bsf rcx, rbx          ; rcx = index, ZF=0 since x!=0
    lea rdi, [msg_bsf]
    call print_cstr
    mov rdi, rcx
    call print_hex64_nl

    ; BSR: index of highest set bit
    mov rbx, rax
    bsr rcx, rbx
    lea rdi, [msg_bsr]
    call print_cstr
    mov rdi, rcx
    call print_hex64_nl

    ; log2_floor(x) equals BSR index for x>0
    lea rdi, [msg_lg2]
    call print_cstr
    mov rdi, rcx
    call print_hex64_nl

    jmp .done

.x_zero:
    lea rdi, [msg_zero]
    call print_cstr

.done:
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
