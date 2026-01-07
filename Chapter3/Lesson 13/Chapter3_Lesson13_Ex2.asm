; Chapter 3 - Lesson 13 (Include-style): IEEE-754 field extraction + classification helpers
; File: Chapter3_Lesson13_Ex2.asm
; Use: %include "Chapter3_Lesson13_Ex2.asm" from other examples in this lesson.
;
; Provides:
;   fp32_get_fields:  eax=bits  -> ecx=sign(0/1), edx=exp(0..255), r8d=frac(0..2^23-1)
;   fp64_get_fields:  rax=bits  -> rcx=sign(0/1), rdx=exp(0..2047), r8=frac(0..2^52-1)
;   fp32_unbias_exp:  edx=exp   -> edx=unbiased exponent (normal: e-127, sub/zero: -126)
;   fp64_unbias_exp:  edx=exp   -> edx=unbiased exponent (normal: e-1023, sub/zero: -1022)
;   fp32_is_nan:      eax=bits  -> al=1 if NaN else 0
;   fp64_is_nan:      rax=bits  -> al=1 if NaN else 0
;   fp32_classify:    eax=bits  -> rax=ptr to 0-terminated classification string
;   fp64_classify:    rax=bits  -> rax=ptr to 0-terminated classification string
;
; Classification strings:
;   "zero", "subnormal", "normal", "infinity", "qNaN", "sNaN"

%ifndef CH3_L13_FP754_INCLUDED
%define CH3_L13_FP754_INCLUDED 1

%define FP32_BIAS 127
%define FP64_BIAS 1023

section .rodata
fp_str_zero:      db "zero", 0
fp_str_subnormal: db "subnormal", 0
fp_str_normal:    db "normal", 0
fp_str_infinity:  db "infinity", 0
fp_str_qnan:      db "qNaN", 0
fp_str_snan:      db "sNaN", 0

section .text

; fp32_get_fields(eax=bits) -> ecx=sign, edx=exp, r8d=frac
fp32_get_fields:
    mov ecx, eax
    shr ecx, 31

    mov edx, eax
    shr edx, 23
    and edx, 0xFF

    mov r8d, eax
    and r8d, 0x7FFFFF
    ret

; fp64_get_fields(rax=bits) -> rcx=sign, rdx=exp, r8=frac
fp64_get_fields:
    mov rcx, rax
    shr rcx, 63

    mov rdx, rax
    shr rdx, 52
    and edx, 0x7FF

    mov r8, rax
    and r8, 0x000FFFFFFFFFFFFF
    ret

; fp32_unbias_exp(edx=exp) -> edx=unbiased exponent for decoding
; exp==0 represents subnormal/zero exponent of (1-bias) = -126 for binary32
fp32_unbias_exp:
    cmp edx, 0
    jne .normal
    mov edx, -126
    ret
.normal:
    sub edx, FP32_BIAS
    ret

; fp64_unbias_exp(edx=exp) -> edx=unbiased exponent for decoding
; exp==0 represents subnormal/zero exponent of (1-bias) = -1022 for binary64
fp64_unbias_exp:
    cmp edx, 0
    jne .normal
    mov edx, -1022
    ret
.normal:
    sub edx, FP64_BIAS
    ret

; fp32_is_nan(eax=bits) -> al=1 if NaN else 0
fp32_is_nan:
    mov edx, eax
    shr edx, 23
    and edx, 0xFF
    cmp edx, 0xFF
    jne .no
    test eax, 0x007FFFFF
    setnz al
    ret
.no:
    xor eax, eax
    ret

; fp64_is_nan(rax=bits) -> al=1 if NaN else 0
fp64_is_nan:
    mov rdx, rax
    shr rdx, 52
    and edx, 0x7FF
    cmp edx, 0x7FF
    jne .no
    test rax, 0x000FFFFFFFFFFFFF
    setnz al
    ret
.no:
    xor eax, eax
    ret

; fp32_classify(eax=bits) -> rax=ptr to classification string
fp32_classify:
    push rbx
    mov ebx, eax
    shr ebx, 23
    and ebx, 0xFF            ; exp

    mov ecx, eax
    and ecx, 0x7FFFFF        ; frac

    test ebx, ebx
    jz .zero_or_sub

    cmp ebx, 0xFF
    je .inf_or_nan

    lea rax, [rel fp_str_normal]
    pop rbx
    ret

.zero_or_sub:
    test ecx, ecx
    jz .zero
    lea rax, [rel fp_str_subnormal]
    pop rbx
    ret
.zero:
    lea rax, [rel fp_str_zero]
    pop rbx
    ret

.inf_or_nan:
    test ecx, ecx
    jz .inf
    ; NaN: quiet vs signaling differs by top fraction bit (bit 22)
    bt ecx, 22
    jc .qnan
    lea rax, [rel fp_str_snan]
    pop rbx
    ret
.qnan:
    lea rax, [rel fp_str_qnan]
    pop rbx
    ret
.inf:
    lea rax, [rel fp_str_infinity]
    pop rbx
    ret

; fp64_classify(rax=bits) -> rax=ptr to classification string
fp64_classify:
    push rbx
    mov rbx, rax

    mov edx, ebx             ; lower bits (for quick tests)
    ; Extract exp into ecx (11 bits)
    mov rcx, rbx
    shr rcx, 52
    and ecx, 0x7FF

    mov r8, rbx
    and r8, 0x000FFFFFFFFFFFFF  ; frac (52 bits)

    test ecx, ecx
    jz .zero_or_sub

    cmp ecx, 0x7FF
    je .inf_or_nan

    lea rax, [rel fp_str_normal]
    pop rbx
    ret

.zero_or_sub:
    test r8, r8
    jz .zero
    lea rax, [rel fp_str_subnormal]
    pop rbx
    ret
.zero:
    lea rax, [rel fp_str_zero]
    pop rbx
    ret

.inf_or_nan:
    test r8, r8
    jz .inf
    ; quiet vs signaling: top fraction bit (bit 51 of frac)
    bt r8, 51
    jc .qnan
    lea rax, [rel fp_str_snan]
    pop rbx
    ret
.qnan:
    lea rax, [rel fp_str_qnan]
    pop rbx
    ret
.inf:
    lea rax, [rel fp_str_infinity]
    pop rbx
    ret

%endif
