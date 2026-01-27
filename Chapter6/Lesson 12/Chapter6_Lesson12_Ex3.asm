; Chapter 6 - Lesson 12 (Example 3)
; Euclid's algorithm is naturally tail-recursive:
; gcd(a,b) = gcd(b, a mod b) with gcd(a,0)=a
; We implement it as a tail jump to itself (no extra stack growth).

BITS 64
DEFAULT REL

global _start

section .text

; uint64_t gcd_tail(uint64_t a, uint64_t b)
;   input : rdi=a, rsi=b
;   output: rax=gcd(a,b)
gcd_tail:
    test rsi, rsi
    jz .done
    mov rax, rdi
    xor rdx, rdx
    div rsi                 ; rdx = a mod b
    mov rdi, rsi            ; a = b
    mov rsi, rdx            ; b = a mod b
    jmp gcd_tail            ; tail call via jump
.done:
    mov rax, rdi
    ret

_start:
    mov rdi, 270
    mov rsi, 192
    call gcd_tail
    mov rdi, rax
    mov rax, 60
    syscall
