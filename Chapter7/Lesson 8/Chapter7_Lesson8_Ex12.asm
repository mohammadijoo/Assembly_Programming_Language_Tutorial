; Chapter7_Lesson8_Ex12.asm
; Exercise Solution: Compute 4-level page-table indices for a virtual address (x86-64).
; This is purely arithmetic: indices = (va >> shift) & 0x1FF, offset = va & 0xFFF.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
msg_va:    db "VA: 0x00007fff12345678", 10
len_va:    equ $-msg_va

msg_pml4:  db "PML4 index: "
len_pml4:  equ $-msg_pml4
msg_pdpt:  db "PDPT index: "
len_pdpt:  equ $-msg_pdpt
msg_pd:    db "PD index:   "
len_pd:    equ $-msg_pd
msg_pt:    db "PT index:   "
len_pt:    equ $-msg_pt
msg_off:   db "Offset:     "
len_off:   equ $-msg_off
nl: db 10

section .bss
numbuf: resb 32

section .text
_start:
    and rsp, -16

    syscall3 SYS_write, 1, msg_va, len_va

    mov rax, 0x00007fff12345678

    ; PML4 = (va >> 39) & 0x1FF
    mov rbx, rax
    shr rbx, 39
    and rbx, 0x1FF
    syscall3 SYS_write, 1, msg_pml4, len_pml4
    mov rax, rbx
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    ; PDPT = (va >> 30) & 0x1FF
    mov rbx, 0x00007fff12345678
    shr rbx, 30
    and rbx, 0x1FF
    syscall3 SYS_write, 1, msg_pdpt, len_pdpt
    mov rax, rbx
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    ; PD = (va >> 21) & 0x1FF
    mov rbx, 0x00007fff12345678
    shr rbx, 21
    and rbx, 0x1FF
    syscall3 SYS_write, 1, msg_pd, len_pd
    mov rax, rbx
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    ; PT = (va >> 12) & 0x1FF
    mov rbx, 0x00007fff12345678
    shr rbx, 12
    and rbx, 0x1FF
    syscall3 SYS_write, 1, msg_pt, len_pt
    mov rax, rbx
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    ; offset = va & 0xFFF
    mov rbx, 0x00007fff12345678
    and rbx, 0xFFF
    syscall3 SYS_write, 1, msg_off, len_off
    mov rax, rbx
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1

    syscall1 SYS_exit, 0

; Convert unsigned rax to decimal ASCII (no newline)
; Output: rsi=ptr, rdx=len
u64_to_dec_nolf:
    push rbx
    lea rbx, [rel numbuf + 31]
    mov byte [rbx], 0
    dec rbx

    cmp rax, 0
    jne .loop

    mov byte [rbx], '0'
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret

.loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rbx], dl
    dec rbx
    test rax, rax
    jne .loop

    inc rbx
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret
