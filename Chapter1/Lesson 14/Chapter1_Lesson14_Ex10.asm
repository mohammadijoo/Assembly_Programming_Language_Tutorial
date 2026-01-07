; Example normalization: return -1 on error, and store errno in a global
; int last_errno;  (not thread-safe; just instructional)

global sys_write_libcstyle
global last_errno
section .bss
last_errno: resd 1

section .text
sys_write_libcstyle:
    mov eax, 1              ; __NR_write
    syscall
    test rax, rax
    jns .ok                 ; if RAX >= 0, success
    ; error: RAX is negative. Store (-RAX) as errno and return -1
    neg eax                 ; EAX = -EAX (low 32 bits)
    mov [rel last_errno], eax
    mov rax, -1
.ok:
    ret
