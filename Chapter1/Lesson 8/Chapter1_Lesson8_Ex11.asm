; file: linux_sys.inc (NASM include)

%ifndef LINUX_SYS_INC
%define LINUX_SYS_INC

%define SYS_write  1
%define SYS_exit   60
%define STDOUT_FD  1

; Macro: sys_exit status
%macro sys_exit 1
    mov rax, SYS_exit
    mov rdi, %1
    syscall
%endmacro

%endif
