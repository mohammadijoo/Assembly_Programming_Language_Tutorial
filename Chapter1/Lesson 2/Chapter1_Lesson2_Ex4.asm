
; Conditional assembly example (NASM):
; Choose an exit mechanism based on a build-time define.

%ifdef LINUX_X86_64
  %define EXIT_SYSCALL 60
  %macro DO_EXIT 1
    mov eax, EXIT_SYSCALL
    mov edi, %1
    syscall
  %endmacro
%else
  ; "Fallback" placeholder for other environments (illustrative)
  %macro DO_EXIT 1
    ; In a real non-Linux target, you would invoke its ABI/OS service here.
    hlt
  %endmacro
%endif

global _start
section .text
_start:
  DO_EXIT 0
      