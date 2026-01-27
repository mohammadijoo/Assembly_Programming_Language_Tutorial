; Chapter5_Lesson10_Ex16.asm
; Programming Exercise Solution — atoi_i32_checked (signed decimal with range checks)
; SysV AMD64 ABI
;
; int atoi_i32_checked(const char* s, uint64_t len, int32_t* out);
;   rdi = s
;   rsi = len
;   rdx = out
; Returns:
;   rax = 0  success
;   rax = -1 invalid (null/empty/non-digit)
;   rax = -2 range (outside int32)
;
; Accepted format:
; - Optional leading '+' or '-'
; - Then at least one digit
; - Exactly 'len' bytes are consumed (no trailing junk)

BITS 64
default rel

global atoi_i32_checked
section .text

atoi_i32_checked:
    test rdi, rdi
    jz   .invalid
    test rdx, rdx
    jz   .invalid
    test rsi, rsi
    jz   .invalid

    mov  r11, rdx                  ; out pointer
    xor  rcx, rcx                  ; i = 0
    mov  r9d, 1                    ; sign = +1

    ; optional sign
    movzx eax, byte [rdi]
    cmp  al, '-'
    jne  .chk_plus
    mov  r9d, -1
    inc  rcx
    jmp  .after_sign
.chk_plus:
    cmp  al, '+'
    jne  .after_sign
    inc  rcx

.after_sign:
    cmp  rcx, rsi
    jae  .invalid                  ; sign only, no digits

    ; limit based on sign:
    ;  +: 2147483647
    ;  -: 2147483648 (absolute of INT_MIN)
    mov  r10, 2147483647
    cmp  r9d, 1
    je   .limit_ok
    mov  r10, 2147483648
.limit_ok:

    xor  r8, r8                    ; acc = 0 (uint64)

.loop:
    cmp  rcx, rsi
    jae  .finish

    movzx eax, byte [rdi + rcx]
    sub  eax, '0'
    cmp  eax, 9
    ja   .invalid
    mov  r13d, eax                 ; digit in r13d (volatile in SysV)

    ; acc = acc*10 + digit with overflow/range check against r10 (limit)
    mov  rax, r8
    mov  r14, 10
    mul  r14                       ; RDX:RAX = acc*10
    test rdx, rdx
    jnz  .range

    add  rax, r13
    jc   .range
    cmp  rax, r10
    ja   .range

    mov  r8, rax
    inc  rcx
    jmp  .loop

.finish:
    ; apply sign and store
    cmp  r9d, 1
    je   .store_pos

    ; negative
    cmp  r8, 2147483648
    jne  .neg_normal
    mov  eax, 0x80000000           ; INT_MIN
    jmp  .store

.neg_normal:
    mov  eax, r8d
    neg  eax
    jmp  .store

.store_pos:
    mov  eax, r8d

.store:
    mov  [r11], eax
    xor  eax, eax
    ret

.invalid:
    mov  eax, -1
    ret

.range:
    mov  eax, -2
    ret
