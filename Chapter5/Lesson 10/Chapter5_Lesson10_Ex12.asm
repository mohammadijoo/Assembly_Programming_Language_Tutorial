; Chapter5_Lesson10_Ex12.asm
; Defensive Control Flow — Structured Error Handling with Single Exit Label
; SysV AMD64 ABI
;
; int validate_then_xor_bytes(uint8_t* dst, const uint8_t* src, uint64_t n);
;   rdi = dst
;   rsi = src
;   rdx = n
; Returns:
;   rax = 0 success
;   rax = -1 invalid argument
;
; Effect:
; - For i in [0..n-1]: dst[i] ^= src[i]
;
; Pattern:
; - Validate all preconditions, then execute a tight loop.
; - Use one epilogue label to keep structured cleanup scalable.

BITS 64
default rel

global validate_then_xor_bytes
section .text

validate_then_xor_bytes:
    mov  eax, 0                    ; assume success
    test rdx, rdx
    jz   .out                      ; n=0 ok
    test rdi, rdi
    jz   .bad
    test rsi, rsi
    jz   .bad

    xor  rcx, rcx
.loop:
    cmp  rcx, rdx
    jae  .out
    mov  r8b, [rdi + rcx]
    xor  r8b, [rsi + rcx]
    mov  [rdi + rcx], r8b
    inc  rcx
    jmp  .loop

.bad:
    mov  eax, -1
.out:
    ret
