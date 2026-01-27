; Chapter5_Lesson10_Ex1.asm
; Defensive Control Flow — Bounds Checks (array indexing)
; SysV AMD64 ABI
;
; int array_get_u64_checked(const uint64_t* base, uint64_t len, uint64_t idx, uint64_t* out);
;   rdi = base
;   rsi = len
;   rdx = idx
;   rcx = out
; Returns:
;   rax = 0 on success, -1 on error
;
; Notes:
; - Uses unsigned compare for idx vs len (jae).
; - Minimal surface area: validate pointers and bounds before any load.

BITS 64
default rel

global array_get_u64_checked
section .text

array_get_u64_checked:
    test rdi, rdi
    jz   .err
    test rcx, rcx
    jz   .err
    cmp  rdx, rsi
    jae  .err

    mov  rax, [rdi + rdx*8]
    mov  [rcx], rax
    xor  eax, eax
    ret

.err:
    mov  eax, -1
    ret
