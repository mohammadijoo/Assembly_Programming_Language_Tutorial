%macro CLEAR_GPRS 0
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
%endmacro

section .text
global _start
_start:
  CLEAR_GPRS
  ; ...