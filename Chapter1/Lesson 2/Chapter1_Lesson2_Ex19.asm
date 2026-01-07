
; Intel syntax with AT&T equivalents in comments (conceptual)
BITS 64
global _start
section .text
_start:
  push rbp                 ; pushq %rbp
  mov rbp, rsp             ; movq %rsp, %rbp
  sub rsp, 16              ; subq $16, %rsp

  mov dword [rbp-4], 7     ; movl $7, -4(%rbp)
  mov dword [rbp-8], 9     ; movl $9, -8(%rbp)

  mov eax, [rbp-4]         ; movl -4(%rbp), %eax
  add eax, [rbp-8]         ; addl -8(%rbp), %eax
  imul eax, eax, 3         ; imull $3, %eax, %eax
  sub eax, 4               ; subl $4, %eax

  mov [rbp-12], eax        ; movl %eax, -12(%rbp)

  mov edi, eax             ; movl %eax, %edi
  and edi, 0xFF            ; andl $255, %edi
  mov eax, 60              ; movl $60, %eax
  syscall

  ; (No epilogue needed because we exit, but historically you'd restore rbp/rsp.)
      