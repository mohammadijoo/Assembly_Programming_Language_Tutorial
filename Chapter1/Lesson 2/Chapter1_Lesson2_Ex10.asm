
; NASM-flavored structural directives (common modern style)
BITS 64
global func

section .text
func:
  push rbp
  mov rbp, rsp
  sub rsp, 32

  ; ... function body ...

  leave
  ret
      