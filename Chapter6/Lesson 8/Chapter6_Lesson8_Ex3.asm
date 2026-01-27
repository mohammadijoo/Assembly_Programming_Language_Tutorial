; Chapter 6 - Lesson 8 (Example 3)
; Caller-saved vs callee-saved in practice: RAX is caller-saved.
; Shows a buggy caller and a fixed caller that saves/restores RAX.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3

BITS 64
default rel
global _start

section .rodata
msg_bug  db "BUG: caller assumed RAX survives a call", 10
len_bug  equ $-msg_bug
msg_fix  db "OK: caller saved RAX across the call", 10
len_fix  equ $-msg_fix

section .text
write_msg:
    ; rsi=ptr, edx=len (caller-saved: rax, rcx, rdx, rsi, rdi, r8-r11)
    mov eax, 1      ; sys_write
    mov edi, 1      ; stdout
    syscall
    ret

clobber_rax_rcx:
    ; This is allowed: RAX, RCX are caller-saved in SysV AMD64.
    mov rax, 0xDEADBEEFDEADBEEF
    mov rcx, 0xCAFEBABECAFEBABE
    ret

caller_bug:
    mov rax, 0x1111222233334444  ; value we wish to keep
    call clobber_rax_rcx
    cmp rax, 0x1111222233334444
    sete al                      ; al=1 if preserved, 0 otherwise
    movzx eax, al
    ret

caller_fixed:
    mov rax, 0x1111222233334444
    push rax                     ; caller saves caller-saved reg if needed
    call clobber_rax_rcx
    pop rax
    cmp rax, 0x1111222233334444
    sete al
    movzx eax, al
    ret

_start:
    call caller_bug
    test eax, eax
    jnz .bug_unexpected_ok

    lea rsi, [rel msg_bug]
    mov edx, len_bug
    call write_msg

    call caller_fixed
    test eax, eax
    jz .fix_failed

    lea rsi, [rel msg_fix]
    mov edx, len_fix
    call write_msg

    mov eax, 60
    xor edi, edi
    syscall

.bug_unexpected_ok:
.fix_failed:
    mov eax, 60
    mov edi, 1
    syscall
