bits 64
default rel
global _start

section .text
_start:
    ; Tail-recursive factorial usually has signature fact(n, acc).
    ; Here we implement the tail-call optimized version directly as a loop.
    mov edi, 10               ; n
    mov esi, 1                ; acc
    call fact_tco

    mov rcx, 3628800
    cmp rax, rcx
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; uint64_t fact_tco(uint64_t n, uint64_t acc)
; Semantics:
;   if (n <= 1) return acc;
;   else return fact_tco(n-1, acc*n);
; Optimization:
;   tail-call eliminated into a jump (no stack growth).
fact_tco:
.loop:
    cmp rdi, 1
    jbe .done
    imul rsi, rdi             ; acc *= n
    dec rdi                   ; n -= 1
    jmp .loop                 ; tail call => jump
.done:
    mov rax, rsi
    ret
