; linux_syscalls.inc (NASM include file)
; Demonstrates: %define constants, %macro wrappers

%define SYS_read   0
%define SYS_write  1
%define SYS_exit  60

%macro SYSCALL0 1
  mov eax, %1
  syscall
%endmacro

%macro SYSCALL1 2
  mov eax, %1
  mov edi, %2
  syscall
%endmacro

%macro SYSCALL3 4
  mov eax, %1
  mov edi, %2
  mov rsi, %3
  mov rdx, %4
  syscall
%endmacro
