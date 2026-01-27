; Chapter5_Lesson10_Ex13.asm
; Programming Exercise Solution — memmove_checked (overlap-safe copy with validation)
; SysV AMD64 ABI
;
; void* memmove_checked(void* dst, const void* src, uint64_t n);
;   rdi = dst
;   rsi = src
;   rdx = n
; Returns:
;   rax = dst on success
;   rax = 0 on invalid arguments (dst==NULL or src==NULL when n>0)
;
; Notes:
; - Correctly handles overlap (like C memmove).
; - Preserves the System V requirement that DF is clear on return.

BITS 64
default rel

global memmove_checked
section .text

memmove_checked:
    mov  r8, rdi                   ; save dst for return
    test rdx, rdx
    jz   .ok_return                 ; n=0: allowed even for NULL pointers

    test rdi, rdi
    jz   .err
    test rsi, rsi
    jz   .err

    cmp  rdi, rsi
    je   .ok_return                 ; same pointer

    ; if dst < src -> forward copy
    jb   .forward

    ; dst >= src: check if dst >= src + n (no overlap) -> forward
    lea  r9, [rsi + rdx]            ; src_end
    cmp  rdi, r9
    jae  .forward

    ; overlap with dst inside source range -> backward
.backward:
    lea  rsi, [rsi + rdx - 1]
    lea  rdi, [rdi + rdx - 1]
    mov  rcx, rdx
    std
    rep  movsb
    cld
    jmp  .ok_return

.forward:
    cld
    mov  rcx, rdx
    rep  movsb
    jmp  .ok_return

.err:
    xor  eax, eax
    ret

.ok_return:
    mov  rax, r8
    ret
