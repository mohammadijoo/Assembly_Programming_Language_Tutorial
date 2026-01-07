; A small macro to reduce syscall boilerplate (NASM)
; Demonstrates: macros, parameterized code, consistent register setup

%macro SYSCALL3 4
  mov eax, %1        ; nr
  mov edi, %2        ; arg1
  mov rsi, %3        ; arg2
  mov rdx, %4        ; arg3
  syscall
%endmacro

; Example usage:
; SYSCALL3 1, 1, msg, len
