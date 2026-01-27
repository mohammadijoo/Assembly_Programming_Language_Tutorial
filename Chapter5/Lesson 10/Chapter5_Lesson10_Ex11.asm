; Chapter5_Lesson10_Ex11.asm
; Defensive Control Flow — Fail-Fast Assertions (UD2 as "should never happen")
; SysV AMD64 ABI
;
; void assert_nonzero_u64(uint64_t x);
;   rdi = x
; Behavior:
; - If x==0, triggers an invalid opcode exception (UD2).
; - Otherwise returns normally.
;
; Use this for internal invariants (debug builds, or always-on in critical systems).

BITS 64
default rel

global assert_nonzero_u64
section .text

assert_nonzero_u64:
    test rdi, rdi
    jnz  .ok
    ud2
.ok:
    ret
