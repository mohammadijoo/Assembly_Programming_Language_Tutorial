; Chapter5_Lesson10_Ex9.asm
; Defensive Control Flow — Checked Accumulation with Early Exit (overflow-aware sum)
; SysV AMD64 ABI
;
; int sum_u32_checked(const uint32_t* a, uint64_t n, uint32_t* out);
;   rdi = a
;   rsi = n
;   rdx = out
; Returns:
;   rax = 0 success
;   rax = -1 invalid
;   rax = -2 overflow
;
; Behavior:
; - Sums n uint32 values into a uint32 result.
; - Aborts immediately on pointer/param invalidity or on carry/overflow.

BITS 64
default rel

global sum_u32_checked
section .text

sum_u32_checked:
    test rdx, rdx
    jz   .invalid
    test rsi, rsi
    jz   .zero_ok                 ; n=0 => sum=0
    test rdi, rdi
    jz   .invalid

    xor  eax, eax                 ; acc in eax
    xor  rcx, rcx                 ; i = 0
.loop:
    cmp  rcx, rsi
    jae  .done
    add  eax, dword [rdi + rcx*4]
    jc   .overflow
    inc  rcx
    jmp  .loop

.done:
    mov  [rdx], eax
    xor  eax, eax
    ret

.zero_ok:
    mov  dword [rdx], 0
    xor  eax, eax
    ret

.invalid:
    mov  eax, -1
    ret

.overflow:
    mov  eax, -2
    ret
