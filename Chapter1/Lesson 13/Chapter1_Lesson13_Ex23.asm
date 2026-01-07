; include/print_macros.inc (NASM)
%ifndef PRINT_MACROS_INC
%define PRINT_MACROS_INC

%include "syscalls_linux_x86_64.inc"

%macro WRITE_LIT 2
    ; WRITE_LIT ptr, len  (writes exactly len bytes to stdout)
    mov eax, SYS_write
    mov edi, 1
    mov rsi, %1
    mov edx, %2
    syscall
%endmacro

%endif
