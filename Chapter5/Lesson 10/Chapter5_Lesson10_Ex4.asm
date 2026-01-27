; Chapter5_Lesson10_Ex4.asm
; Defensive Control Flow — Multiplication Overflow (MUL high half)
; SysV AMD64 ABI
;
; uint64_t mul_u64_overflow(uint64_t a, uint64_t b, uint64_t* overflow);
;   rdi = a
;   rsi = b
;   rdx = overflow (optional, can be NULL)
; Returns:
;   rax = low 64 bits of product
; Side effect:
;   *overflow = 1 if high 64 bits are non-zero, else 0
;
; Note: MUL uses RAX as input and clobbers RDX with the high half, so we must
; preserve the overflow pointer before MUL.

BITS 64
default rel

global mul_u64_overflow
section .text

mul_u64_overflow:
    mov  r8, rdx                    ; save overflow pointer
    mov  rax, rdi
    mul  rsi                        ; RDX:RAX = RAX * RSI

    test rdx, rdx
    setnz cl                        ; cl = (RDX != 0)

    test r8, r8
    jz   .ret
    movzx ecx, cl
    mov  [r8], rcx
.ret:
    ret
