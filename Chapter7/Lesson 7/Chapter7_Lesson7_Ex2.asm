; Chapter7_Lesson7_Ex2.asm
; Show what a normal callee sees after a CALL (SysV AMD64):
; - caller keeps RSP 16-byte aligned before CALL
; - CALL pushes 8-byte return address
; - callee observes (RSP mod 16) = 8 on entry

global _start
section .text

_start:
    call    callee_entry_rsp_mod16

    ; exit(status = rax)
    mov     rdi, rax
    mov     eax, 60
    syscall

callee_entry_rsp_mod16:
    mov     rax, rsp
    and     rax, 15
    ret
