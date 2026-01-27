; Chapter5_Lesson10_Ex15.asm
; Programming Exercise Solution — constant_time_memeq (defensive against early-exit leakage)
; SysV AMD64 ABI
;
; int constant_time_memeq(const void* a, const void* b, uint64_t n);
;   rdi = a
;   rsi = b
;   rdx = n
; Returns:
;   eax = 1 if equal, 0 otherwise
;
; Notes:
; - Runs in O(n) without data-dependent early return.
; - Returns 1 for n=0 (empty buffers equal).
; - For n>0, NULL pointers are treated as not equal.

BITS 64
default rel

global constant_time_memeq
section .text

constant_time_memeq:
    test rdx, rdx
    jz   .eq

    test rdi, rdi
    jz   .neq
    test rsi, rsi
    jz   .neq

    xor  rcx, rcx
    xor  r8d, r8d                  ; diff accumulator in low byte
.loop:
    cmp  rcx, rdx
    jae  .done
    mov  al, [rdi + rcx]
    xor  al, [rsi + rcx]
    or   r8b, al
    inc  rcx
    jmp  .loop

.done:
    test r8b, r8b
    setz al
    movzx eax, al
    ret

.eq:
    mov  eax, 1
    ret

.neq:
    xor  eax, eax
    ret
