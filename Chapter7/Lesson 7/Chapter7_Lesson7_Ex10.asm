; Chapter7_Lesson7_Ex10.asm
; Exercise Solution 1:
; Implement a generic wrapper that calls a function pointer with one argument
; while guaranteeing SysV AMD64 16-byte stack alignment at the call boundary.
;
; call1_aligned(rdi = fn_ptr, rsi = arg) -> rax = fn(arg)

%define SYS_exit 60

global _start
global call1_aligned

section .text

_start:
    lea     rdi, [rel square]
    mov     rsi, 13
    call    call1_aligned

    ; exit(status = (rax & 255))
    mov     rdi, rax
    and     rdi, 255
    mov     eax, SYS_exit
    syscall

; rdi=function pointer, rsi=argument
call1_aligned:
    push    rbp
    mov     rbp, rsp

    ; Save RBX (callee-saved), we'll use it for the function pointer.
    push    rbx

    ; After 'call', entry RSP mod 16 = 8.
    ; push rbp => 0
    ; push rbx => 8  (misaligned for a call)
    ; Fix by subtracting 8 to restore 16-byte alignment before calling fn.
    sub     rsp, 8

    mov     rbx, rdi         ; fn_ptr
    mov     rdi, rsi         ; move arg into rdi (SysV first arg)
    call    rbx

    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

square:
    ; rdi=x -> rax=x*x
    mov     rax, rdi
    imul    rax, rdi
    ret
