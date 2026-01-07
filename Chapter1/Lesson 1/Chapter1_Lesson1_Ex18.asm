; sys_linux_x64.inc
%define SYS_write 1
%define SYS_exit  60

%define FD_STDIN  0
%define FD_STDOUT 1
%define FD_STDERR 2

; SYSCALL3 num, a1, a2, a3
; Clobbers: rax, rdi, rsi, rdx, rcx, r11 (rcx/r11 clobbered by syscall)
%macro SYSCALL3 4
  mov eax, %1
  mov rdi, %2
  mov rsi, %3
  mov rdx, %4
  syscall
%endmacro