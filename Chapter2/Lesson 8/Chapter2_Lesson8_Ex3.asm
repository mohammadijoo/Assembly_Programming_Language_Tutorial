;
; Chapter 2 - Lesson 8 - Example 3
; Distinguishing CF vs OF with carefully chosen additions/subtractions.
;
; Build:
;   nasm -felf64 Chapter2_Lesson8_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

%include "Chapter2_Lesson8_Ex1.asm"

BITS 64
default rel
global _start

section .rodata
h: db "CF vs OF demonstrations (observe dump)",10
h_len: equ $-h

c1: db "1) Unsigned wrap: 0xFFFF..FF + 1",10
c1_len: equ $-c1

c2: db "2) Signed overflow: 0x7FFF..FF + 1",10
c2_len: equ $-c2

c3: db "3) Unsigned borrow: 0 - 1",10
c3_len: equ $-c3

c4: db "4) Signed overflow on SUB: 0x8000..00 - 1",10
c4_len: equ $-c4

lab_res: db "Result  = ",0
lab_res_len: equ 9
lab_rfl: db "RFLAGS  = ",0
lab_rfl_len: equ 9

section .text
_start:
    SYS_WRITE h, h_len
    call print_nl

    ; 1) CF=1, ZF=1, OF=0
    SYS_WRITE c1, c1_len
    mov rax, 0xFFFFFFFFFFFFFFFF
    add rax, 1
    SYS_WRITE lab_res, lab_res_len
    call print_hex64_rax
    pushfq
    pop rbx
    SYS_WRITE lab_rfl, lab_rfl_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; 2) OF=1, CF=0
    SYS_WRITE c2, c2_len
    mov rax, 0x7FFFFFFFFFFFFFFF
    add rax, 1
    SYS_WRITE lab_res, lab_res_len
    call print_hex64_rax
    pushfq
    pop rbx
    SYS_WRITE lab_rfl, lab_rfl_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; 3) CF=1 indicates borrow (unsigned underflow)
    SYS_WRITE c3, c3_len
    xor rax, rax
    sub rax, 1
    SYS_WRITE lab_res, lab_res_len
    call print_hex64_rax
    pushfq
    pop rbx
    SYS_WRITE lab_rfl, lab_rfl_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic
    call print_nl

    ; 4) Signed overflow on SUB: INT64_MIN - 1 wraps to INT64_MAX (OF=1)
    SYS_WRITE c4, c4_len
    mov rax, 0x8000000000000000
    sub rax, 1
    SYS_WRITE lab_res, lab_res_len
    call print_hex64_rax
    pushfq
    pop rbx
    SYS_WRITE lab_rfl, lab_rfl_len
    mov rax, rbx
    call print_hex64_rax
    mov rax, rbx
    call dump_flags_basic

    SYS_EXIT 0
