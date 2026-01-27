bits 64
default rel

global _start
section .text

; Ex3: Conditional jumps (Jcc) short vs near.
; In x86-64, Jcc has both rel8 and rel32 forms:
;   short: 70..7F cb
;   near : 0F 80..8F cd cd cd cd
; NASM will choose based on distance unless you force "short" or "near".

_start:
    ; Make ZF=1
    xor eax, eax
    test eax, eax

    ; Force a near Jcc by placing target far away.
    jz near .taken              ; will encode as 0F 84 rel32

    ; Not taken, but this padding demonstrates distance.
    times 200 nop

.not_taken:
    mov edi, 1                  ; exit(1)
    mov eax, 60
    syscall

    ; Far target (out of rel8 range from the JZ)
    times 200 nop

.taken:
    xor edi, edi                ; exit(0)
    mov eax, 60
    syscall
