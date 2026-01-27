; Chapter 6 - Lesson 2 - Exercise Solution 2
; File: Chapter6_Lesson2_Ex10.asm
; Topic: Horner polynomial evaluation with overflow detection + saturation
;
; Signature:
;   int64_t asm_horner_i64_sat(const int64_t* coeff, uint64_t n, int64_t x, uint64_t* overflowed)
;
; SysV args:
;   RDI = coeff (int64_t*)
;   RSI = n
;   RDX = x
;   RCX = overflowed (uint64_t*)
; Returns:
;   RAX = value (possibly saturated)
;   *overflowed = 0 or 1
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10 ; exit 0 if tests pass

default rel
%include "Chapter6_Lesson2_Ex8.asm"

section .data
coeff1: dq 1, 2, 3            ; p(x)=1 + 2x + 3x^2
ovf1:   dq 0

section .text
global _start
global asm_horner_i64_sat

; Helper: saturate based on sign bit in AL (0 => +MAX, 1 => -MIN)
; Output: RAX = sat value
sat_from_sign:
    test al, al
    jz .pos
    mov rax, 0x8000000000000000     ; INT64_MIN
    ret
.pos:
    mov rax, 0x7fffffffffffffff     ; INT64_MAX
    ret

asm_horner_i64_sat:
    ; Initialize overflowed=0
    mov qword [rcx], 0

    xor rax, rax             ; res = 0
    test rsi, rsi
    jz .done                 ; empty polynomial => 0

    mov r8, rdx              ; x in R8
    mov r9, rsi              ; n in R9
    dec r9                   ; i = n-1

.loop:
    ; res = res*x + coeff[i]
    ; Use signed 128-bit IMUL to detect overflow reliably.
    mov r10, rax             ; old res
    mov rax, r10
    imul r8                  ; RDX:RAX = RAX * R8 (signed)

    ; overflow if RDX != signext(RAX)
    mov r11, rax
    sar r11, 63
    cmp rdx, r11
    jne .mul_overflow

    ; add coeff[i]
    add rax, [rdi + r9*8]
    jo .add_overflow

.next:
    test r9, r9
    jz .done
    dec r9
    jmp .loop

.mul_overflow:
    ; Determine sign of product: sign(res) xor sign(x)
    ; old res in R10, x in R8
    mov r11, r10
    xor r11, r8
    shr r11, 63
    mov byte al, r11b
    call sat_from_sign
    mov qword [rcx], 1
    jmp .done

.add_overflow:
    ; For addition overflow, operands had same sign.
    ; Use sign of addend (coeff[i]) as the saturation direction.
    mov r11, [rdi + r9*8]
    shr r11, 63
    mov byte al, r11b
    call sat_from_sign
    mov qword [rcx], 1
    jmp .done

.done:
    ret

_start:
    ; Test p(10)=321
    lea rdi, [rel coeff1]
    mov esi, 3
    mov edx, 10
    lea rcx, [rel ovf1]
    call asm_horner_i64_sat
    cmp rax, 321
    jne .fail
    cmp qword [rel ovf1], 0
    jne .fail

    SYS_EXIT 0
.fail:
    SYS_EXIT 1
