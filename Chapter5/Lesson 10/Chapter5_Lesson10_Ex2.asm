; Chapter5_Lesson10_Ex2.asm
; Defensive Control Flow — Bounded Scan (stop conditions and error path)
; SysV AMD64 ABI
;
; int64_t strlen_bounded(const char* s, uint64_t max);
;   rdi = s
;   rsi = max
; Returns:
;   rax = length on success
;   rax = -1 on error (null pointer OR no NUL within max)
;
; This is a defensive alternative to unbounded strlen-style scans.

BITS 64
default rel

global strlen_bounded
section .text

strlen_bounded:
    test rdi, rdi
    jz   .err

    xor  rcx, rcx                 ; i = 0
.loop:
    cmp  rcx, rsi                 ; reached max?
    jae  .toolong
    mov  al, [rdi + rcx]
    test al, al
    je   .done
    inc  rcx
    jmp  .loop

.done:
    mov  rax, rcx
    ret

.toolong:
    mov  rax, -1
    ret

.err:
    mov  rax, -1
    ret
