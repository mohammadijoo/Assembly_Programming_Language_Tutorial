; Chapter3_Lesson1_Ex4.asm
; Lesson goal: Effective addresses and array indexing (base + index*scale + disp).
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex4.asm -o ex4.o
;   ld ex4.o -o ex4
; Run:
;   ./ex4

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
msg db "arr[i] address and value (i=3):", 10, 0
msg_addr db "  &arr[i] = 0x", 0
msg_val  db "  arr[i]  = 0x", 0

section .data
align 8
arr dq 10, 20, 30, 40, 50, 60, 70, 80

section .text
global _start
_start:
    lea rdi, [msg]
    call write_z

    mov rbx, 3                ; i = 3
    lea rax, [arr + rbx*8]    ; address computation, no memory read
    lea rdi, [msg_addr]
    call write_str_and_hex64

    mov rax, [arr + rbx*8]    ; actual memory load from computed EA
    lea rdi, [msg_val]
    call write_str_and_hex64

    ; A common idiom: treat the computed address as a pointer.
    lea rsi, [arr]
    lea rdx, [rsi + rbx*8]    ; rdx = &arr[i]
    mov rax, [rdx]            ; rax = arr[i]
    ; Print again to show equivalence.
    lea rdi, [msg_val]
    call write_str_and_hex64

    sys_exit 0
