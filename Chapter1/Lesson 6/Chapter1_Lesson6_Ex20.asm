; include/macros_sysv.inc
%macro EXIT 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro
