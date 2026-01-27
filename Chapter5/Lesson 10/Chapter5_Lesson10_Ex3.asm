; Chapter5_Lesson10_Ex3.asm
; Defensive Control Flow — Overflow Flagging (ADD + carry)
; SysV AMD64 ABI
;
; uint64_t add_u64_overflow(uint64_t a, uint64_t b, uint64_t* overflow);
;   rdi = a
;   rsi = b
;   rdx = overflow (optional, can be NULL)
; Returns:
;   rax = a + b (mod 2^64)
; Side effect:
;   *overflow = 1 if carry occurred, else 0

BITS 64
default rel

global add_u64_overflow
section .text

add_u64_overflow:
    mov  rax, rdi
    add  rax, rsi
    setc cl                        ; cl = CF

    test rdx, rdx
    jz   .ret
    movzx ecx, cl
    mov  [rdx], rcx
.ret:
    ret
