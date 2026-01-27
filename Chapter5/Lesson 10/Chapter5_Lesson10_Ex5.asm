; Chapter5_Lesson10_Ex5.asm
; Defensive Control Flow — Robust Parsing with Range Checks (uint32)
; SysV AMD64 ABI
;
; int parse_u32_checked(const char* s, uint64_t len, uint32_t* out);
;   rdi = s
;   rsi = len
;   rdx = out
; Returns:
;   rax = 0  success
;   rax = -1 invalid (null / non-digit / empty)
;   rax = -2 overflow (value exceeds uint32 range)
;
; Policy:
; - Requires exactly 'len' digits (no whitespace, no sign).
; - Fails fast on first invalid byte.

BITS 64
default rel

global parse_u32_checked
section .text

parse_u32_checked:
    test rdi, rdi
    jz   .invalid
    test rdx, rdx
    jz   .invalid
    test rsi, rsi
    jz   .invalid

    mov  r11, rdx                   ; save out pointer
    xor  r8,  r8                    ; acc = 0
    xor  rcx, rcx                   ; i = 0

.loop:
    cmp  rcx, rsi
    jae  .done

    movzx eax, byte [rdi + rcx]
    sub  eax, '0'
    cmp  eax, 9
    ja   .invalid
    mov  r9d, eax                   ; digit in r9d

    ; acc = acc*10 + digit with overflow checks
    mov  rax, r8
    mov  r10, 10
    mul  r10                        ; RDX:RAX = acc*10
    test rdx, rdx
    jnz  .overflow

    add  rax, r9
    jc   .overflow
    cmp  rax, 0FFFFFFFFh
    ja   .overflow

    mov  r8, rax
    inc  rcx
    jmp  .loop

.done:
    mov  [r11], r8d                 ; store as uint32
    xor  eax, eax
    ret

.invalid:
    mov  eax, -1
    ret

.overflow:
    mov  eax, -2
    ret
