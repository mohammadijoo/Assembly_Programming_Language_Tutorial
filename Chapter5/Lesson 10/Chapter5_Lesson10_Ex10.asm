; Chapter5_Lesson10_Ex10.asm
; Defensive Control Flow — Branchless Clamp (CMOV) for safe indexing
; SysV AMD64 ABI
;
; uint64_t clamp_index_u64(uint64_t idx, uint64_t len);
;   rdi = idx
;   rsi = len
; Returns:
;   rax = clamped index in [0 .. len-1] when len>0
;   rax = 0 when len==0
;
; Notes:
; - Use this when you prefer to avoid a hard branch for a predictable clamp.
; - Still validate len==0 before computing len-1.

BITS 64
default rel

global clamp_index_u64
section .text

clamp_index_u64:
    test rsi, rsi
    jz   .zero

    mov  rax, rdi
    lea  rcx, [rsi - 1]           ; max valid index
    cmp  rax, rsi                 ; idx >= len ?
    cmovae rax, rcx               ; clamp to len-1
    ret

.zero:
    xor  eax, eax
    ret
