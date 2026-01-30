; Chapter7_Lesson8_Ex1.asm
; CPUID check for NX (No-Execute) support (hardware capability)
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
msg_noext: db "No extended CPUID leaf 0x80000001; NX feature unknown.", 10
len_noext: equ $-msg_noext

msg_nx_yes: db "CPU reports NX capability (CPUID.80000001h:EDX[20]=1).", 10
len_nx_yes: equ $-msg_nx_yes

msg_nx_no: db "CPU does NOT report NX capability (EDX[20]=0).", 10
len_nx_no: equ $-msg_nx_no

section .text
_start:
    ; Align stack (good hygiene; not strictly required here)
    and rsp, -16

    ; Check max extended CPUID leaf
    mov eax, 0x80000000
    xor ecx, ecx
    cpuid
    cmp eax, 0x80000001
    jb .no_ext

    mov eax, 0x80000001
    xor ecx, ecx
    cpuid
    bt edx, 20               ; NX bit
    jc .nx_yes

.nx_no:
    syscall3 SYS_write, 1, msg_nx_no, len_nx_no
    syscall1 SYS_exit, 0

.nx_yes:
    syscall3 SYS_write, 1, msg_nx_yes, len_nx_yes
    syscall1 SYS_exit, 0

.no_ext:
    syscall3 SYS_write, 1, msg_noext, len_noext
    syscall1 SYS_exit, 0
