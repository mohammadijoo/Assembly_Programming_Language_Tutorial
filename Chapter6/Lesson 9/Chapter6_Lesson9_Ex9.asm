; Chapter6_Lesson9_Ex9.asm
; Programming Exercise (Solution):
; Parse an unsigned 64-bit integer from a decimal ASCII buffer.
;
; Return two values:
;   RAX = ok (0/1)
;   RDX = value (only meaningful if ok==1)
;
; Signature (custom/internal, but maps cleanly to C via a tiny wrapper):
;   parse_u64_dec(const char* p, uint64 len) -> (ok, value)
;   p in RDI, len in RSI
;
; Rules:
;   - reject empty
;   - reject non-digits
;   - reject overflow beyond UINT64_MAX
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

global _start

section .data
s_ok:   db "18446744073709551615"   ; UINT64_MAX
s_bad:  db "18446744073709551616"   ; overflow
s_mix:  db "12x"                    ; non-digit

section .text

parse_u64_dec:
    ; if len==0 => fail
    test    rsi, rsi
    jz      .fail

    xor     rdx, rdx            ; accumulator in RDX

    ; constants: UINT64_MAX/10 and UINT64_MAX%10
    mov     r8, 1844674407370955161      ; max_div10
    mov     r9b, 5                       ; max_mod10

.loop:
    mov     al, [rdi]
    sub     al, '0'
    cmp     al, 9
    ja      .fail

    ; overflow check before: acc = acc*10 + digit
    cmp     rdx, r8
    ja      .fail
    jne     .safe_mul
    cmp     al, r9b
    ja      .fail

.safe_mul:
    ; acc *= 10
    lea     rcx, [rdx + rdx*4]   ; acc*5
    lea     rdx, [rcx*2]         ; acc*10

    ; acc += digit
    movzx   rcx, al
    add     rdx, rcx

    inc     rdi
    dec     rsi
    jnz     .loop

    mov     eax, 1              ; ok
    ret

.fail:
    xor     eax, eax            ; ok=0
    xor     edx, edx            ; value=0
    ret

_start:
    ; ok case
    lea     rdi, [rel s_ok]
    mov     rsi, 20
    call    parse_u64_dec
    test    eax, eax
    jz      .fail
    cmp     rdx, 0xffffffffffffffff
    jne     .fail

    ; overflow case
    lea     rdi, [rel s_bad]
    mov     rsi, 20
    call    parse_u64_dec
    test    eax, eax
    jnz     .fail

    ; non-digit case
    lea     rdi, [rel s_mix]
    mov     rsi, 3
    call    parse_u64_dec
    test    eax, eax
    jnz     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
