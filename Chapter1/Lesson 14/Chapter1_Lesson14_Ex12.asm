; Intel-style (NASM): destination, source
; mov rax, [rbx+8]

; AT&T-style (GAS): source, destination and percent-registers
; movq 8(%rbx), %rax

; Intel uses [ ... ] for memory. AT&T uses ( ... ) and explicit suffixes like b/w/l/q.
