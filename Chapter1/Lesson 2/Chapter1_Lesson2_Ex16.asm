
; NASM structured macros (zero-check variant)
; Usage:
;   IFZ rax
;     ...
;   ELSE
;     ...
;   ENDIF

%macro IFZ 1
  test %1, %1
  jnz %$else
%endmacro

%macro ELSE 0
  jmp %$endif
%$else:
%endmacro

%macro ENDIF 0
%$endif:
%endmacro

BITS 64
global _start
section .text
_start:
  xor eax, eax      ; rax = 0

  IFZ rax
    ; then-branch
    mov edi, 11
  ELSE
    ; else-branch
    mov edi, 22
  ENDIF

  mov eax, 60
  syscall
      