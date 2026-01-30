; Chapter7_Lesson7_Ex11.asm
; Exercise Solution 2:
; A reusable stack-reserve routine that:
;  - rounds size up to 16
;  - probes each 4096-byte page to avoid skipping a guard page
;  - returns the pointer to the reserved block (low address) in rax
;
; reserve_probe(rdi = bytes) -> rax = new_rsp (start of reserved block)
; Caller can later restore old RSP that it saved separately.

%define SYS_exit  60
%define SYS_write  1

global _start
global reserve_probe

section .rodata
ok: db "reserve_probe OK", 10
ok_len: equ $-ok

section .text

_start:
    mov     r15, rsp                 ; save old stack top

    mov     rdi, 5*4096 + 123
    call    reserve_probe            ; rax = new_rsp

    ; Touch the first and last qword to prove it's writable
    mov     qword [rax], 0x1111111122222222
    mov     qword [r15-8], 0x3333333344444444

    ; Print
    mov     rdi, 1
    mov     rsi, ok
    mov     rdx, ok_len
    mov     eax, SYS_write
    syscall

    mov     rsp, r15                 ; restore
    xor     edi, edi
    mov     eax, SYS_exit
    syscall

reserve_probe:
    ; size = align16(size)
    mov     rcx, rdi
    add     rcx, 15
    and     rcx, -16

    ; We'll walk down in 4096-byte steps; touch each new page.
    mov     r8, 4096

.pages:
    cmp     rcx, r8
    jb      .tail
    sub     rsp, r8
    mov     byte [rsp], 0
    sub     rcx, r8
    jmp     .pages

.tail:
    test    rcx, rcx
    jz      .done
    sub     rsp, rcx
    mov     byte [rsp], 0

.done:
    mov     rax, rsp
    ret
