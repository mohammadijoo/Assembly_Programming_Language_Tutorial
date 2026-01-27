; Chapter 5 - Lesson 4 — Programming Exercise 2 (Solution)
; Very hard: Sparse switch on 64-bit error codes using a table-driven binary search.
;
; Given a 64-bit signed code, print a human-readable message for known codes.
; Otherwise print "unknown code".
;
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o
;   ./ex13

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
msg_unknown: db "unknown code", 10
len_unknown: equ $-msg_unknown

; Sorted (ascending) list of signed 64-bit keys + message pointers/lengths.
; Keys are intentionally sparse / large.
msg_eio:     db "EIO (-5)", 10
len_eio:     equ $-msg_eio
msg_enoent:  db "ENOENT (-2)", 10
len_enoent:  equ $-msg_enoent
msg_eperm:   db "EPERM (-1)", 10
len_eperm:   equ $-msg_eperm
msg_custom:  db "CUSTOM (0x100000000)", 10
len_custom:  equ $-msg_custom
msg_big:     db "BIG (0x7FFFFFFFFFFFFFFF)", 10
len_big:     equ $-msg_big

align 8
keys:
    dq -5
    dq -2
    dq -1
    dq 0x100000000
    dq 0x7FFFFFFFFFFFFFFF
keys_n: equ ( ($-keys) / 8 )

align 8
vals_ptr:
    dq msg_eio
    dq msg_enoent
    dq msg_eperm
    dq msg_custom
    dq msg_big

align 4
vals_len:
    dd len_eio
    dd len_enoent
    dd len_eperm
    dd len_custom
    dd len_big

section .data
code: dq 0x100000000

section .text
_start:
    mov rax, qword [code]      ; target key (signed)

    ; Binary search indices: lo=0, hi=keys_n-1
    xor ecx, ecx              ; lo
    mov edx, keys_n-1         ; hi

.loop:
    cmp ecx, edx
    jg  .not_found

    ; mid = (lo + hi) >> 1
    mov esi, ecx
    add esi, edx
    shr esi, 1
    mov r9d, esi              ; keep mid index

    lea rbx, [keys]
    mov r8, qword [rbx + rsi*8]

    cmp rax, r8
    je  .found
    jl  .go_left              ; signed compare
    lea ecx, [rsi + 1]
    jmp .loop

.go_left:
    lea edx, [rsi - 1]
    jmp .loop

.found:
    lea rbx, [vals_ptr]
    mov rsi, qword [rbx + r9*8]

    lea rbx, [vals_len]
    mov edx, dword [rbx + r9*4]
    jmp .print_exit

.not_found:
    lea rsi, [msg_unknown]
    mov edx, len_unknown

.print_exit:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    xor edi, edi
    mov eax, SYS_exit
    syscall
