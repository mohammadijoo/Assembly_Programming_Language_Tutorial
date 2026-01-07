; Chapter 4 - Lesson 11 (Exercise Solution 4)
; Branch-minimized decimal parser: parse an ASCII unsigned decimal string to u64.
; Requirements (core idea):
;   - Use SETcc + CMOV to update value only if character is a valid digit
;   - Detect overflow without data-dependent branches (sticky error flag)
;   - Loop/termination is branch-based (as it must be for variable length)
;
; Output:
;   line1: parsed value in hex
;   line2: error flag in hex (0x...0000 or 0x...0001)

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .rodata
; Change this test string to experiment.
; - Contains an invalid character 'x'
; - Also includes a long suffix that would overflow u64 if interpreted fully
test_str db "18446744073709551615x99", 0

section .text
global _start

; ------------------------------------------------------------
; parse_u64_decimal
;   Input : RSI -> NUL-terminated ASCII string
;   Output: RAX=value (partial if error), EDX=err (0/1, sticky)
;   Clobbers: RCX, R8-R15, RDI
; ------------------------------------------------------------
parse_u64_decimal:
    xor eax, eax        ; value = 0
    xor edx, edx        ; err = 0

.loop:
    movzx ecx, byte [rsi]
    test ecx, ecx
    jz .done

    ; is_digit = (ch >= '0') & (ch <= '9')
    mov r8b, cl
    cmp r8b, '0'
    setae r9b
    cmp r8b, '9'
    setbe r10b
    and r9b, r10b               ; r9b = is_digit (0/1)

    ; digit = ch - '0' (0..9, only meaningful if is_digit=1)
    mov r11d, ecx
    sub r11d, '0'               ; digit in r11d

    ; overflow detection for: new = value*10 + digit
    ; Overflow iff value > UINT64_MAX/10 OR (value==UINT64_MAX/10 AND digit > UINT64_MAX%10)
    ; UINT64_MAX/10 = 1844674407370955161, rem = 5
    mov r12, 1844674407370955161
    cmp rax, r12
    seta r13b                    ; value > threshold
    sete r14b                    ; value == threshold
    cmp r11d, 5
    seta r15b                    ; digit > 5
    and r14b, r15b
    or  r13b, r14b               ; r13b = overflow (0/1)

    ; ok = is_digit & ~overflow
    mov r8b, 1
    sub r8b, r13b                ; r8b = ~overflow (1 if no overflow else 0)
    and r8b, r9b                 ; r8b = ok (0/1)

    ; candidate = value*10 + digit
    lea r10, [rax*4 + rax]       ; value*5
    lea r10, [r10*2 + r11]       ; value*10 + digit

    ; if ok -> value = candidate
    test r8b, r8b
    cmovne rax, r10

    ; err |= (1 - ok)
    mov r9b, 1
    sub r9b, r8b
    or  edx, r9d

    inc rsi
    jmp .loop

.done:
    ret

_start:
    lea rsi, [rel test_str]
    call parse_u64_decimal

    mov rdi, rax
    call print_hex_u64

    movzx rdi, dl
    call print_hex_u64

    EXIT 0
