; Chapter 6 - Lesson 7 - Exercise 4 (Solution)
; Title: ABI alignment checker helper (returns status codes instead of printing)
;
; Functions:
;   int abi_entry_ok_sysv(void)
;     - returns 0 if (rsp % 16 == 8) at entry, else returns 1
;
;   int callsite_ok_now(void)
;     - returns 0 if (rsp % 16 == 0) at this point, else returns 1
;
; Build (Linux, as object):
;   nasm -felf64 Chapter6_Lesson7_Ex11.asm -o ex11.o

BITS 64
DEFAULT REL

GLOBAL abi_entry_ok_sysv
GLOBAL callsite_ok_now

SECTION .text

abi_entry_ok_sysv:
    ; On entry (after CALL), SysV expects rsp%16 == 8
    mov rax, rsp
    and rax, 15
    cmp rax, 8
    sete al
    ; al=1 if equal (OK). We want return 0 on OK, 1 on bad.
    xor eax, 1
    movzx eax, al
    ret

callsite_ok_now:
    ; At a call-site, we want rsp%16 == 0
    mov rax, rsp
    and rax, 15
    sete al         ; 1 if rsp%16==0
    xor eax, 1
    movzx eax, al
    ret
