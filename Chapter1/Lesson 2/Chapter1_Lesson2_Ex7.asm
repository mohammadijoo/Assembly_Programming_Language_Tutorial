
; GAS can switch syntaxes (illustrative). Many projects choose one and stay consistent.

; Intel-style view (conceptual):
;   mov rax, [rbp-8]
;   add rax, 5
;   mov [rbp-8], rax

; AT&T-style view (conceptual):
;   movq -8(%rbp), %rax
;   addq $5, %rax
;   movq %rax, -8(%rbp)
      