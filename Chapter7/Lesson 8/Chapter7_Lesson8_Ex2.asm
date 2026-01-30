; Chapter7_Lesson8_Ex2.asm
; Dump /proc/self/maps to stdout to observe page permissions (rwxp)
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
path: db "/proc/self/maps", 0

msg_open_fail: db "open(/proc/self/maps) failed.", 10
len_open_fail: equ $-msg_open_fail

section .bss
buf: resb 4096

section .text
_start:
    and rsp, -16

    ; fd = open(path, O_RDONLY, 0)
    syscall3 SYS_open, path, O_RDONLY, 0
    test rax, rax
    js .open_fail
    mov r12, rax             ; fd

.read_loop:
    syscall3 SYS_read, r12, buf, 4096
    test rax, rax
    js .done                 ; read error -> stop
    jz .done                 ; EOF
    mov rdx, rax
    syscall3 SYS_write, 1, buf, rdx
    jmp .read_loop

.done:
    syscall1 SYS_close, r12
    syscall1 SYS_exit, 0

.open_fail:
    syscall3 SYS_write, 1, msg_open_fail, len_open_fail
    syscall1 SYS_exit, 1
