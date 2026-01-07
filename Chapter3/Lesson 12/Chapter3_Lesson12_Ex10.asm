; Chapter3_Lesson12_Ex10.asm
; Reusable fixed-point building blocks (intended to be included via %include).
; This file deliberately has no entry point.
;
; Suggested usage:
;   %include "Chapter3_Lesson12_Ex10.asm"
;
; The routines here target signed Q16.16 stored in 32-bit registers.

%ifndef FIXEDPOINT_Q16_16_INCLUDED
%define FIXEDPOINT_Q16_16_INCLUDED 1

%define FP_FRAC_BITS 16
%define FP_ROUND_BIAS (1 << (FP_FRAC_BITS-1))
%define FP_Q16_MAX 0x7FFFFFFF
%define FP_Q16_MIN 0x80000000

; Compile-time constant helper: integer literal to Q16.16 raw
%define FP_INT(k) ((k) << FP_FRAC_BITS)

; sat_add_q16_16: EAX=a, EDX=b -> EAX=saturated (wrap-free) sum
sat_add_q16_16:
    mov ecx, eax
    add ecx, edx
    jno .ok
    test eax, eax
    js .neg
    mov ecx, FP_Q16_MAX
    jmp .ok
.neg:
    mov ecx, FP_Q16_MIN
.ok:
    mov eax, ecx
    ret

; sat_sub_q16_16: EAX=a, EDX=b -> EAX=saturated difference
sat_sub_q16_16:
    mov ecx, eax
    sub ecx, edx
    jno .ok
    test eax, eax
    js .neg
    mov ecx, FP_Q16_MAX
    jmp .ok
.neg:
    mov ecx, FP_Q16_MIN
.ok:
    mov eax, ecx
    ret

; mul_q16_16_round_sat: EAX=x, EDX=y -> EAX=round((x*y)/2^16), saturated
mul_q16_16_round_sat:
    movsxd rax, eax
    movsxd rdx, edx
    imul rax, rdx
    test rax, rax
    js .neg
    add rax, FP_ROUND_BIAS
    jmp .shift
.neg:
    sub rax, FP_ROUND_BIAS
.shift:
    sar rax, FP_FRAC_BITS

    cmp rax, FP_Q16_MAX
    jle .chk_min
    mov eax, FP_Q16_MAX
    ret
.chk_min:
    cmp rax, 0xFFFFFFFF80000000
    jge .in_range
    mov eax, FP_Q16_MIN
    ret
.in_range:
    mov eax, eax
    ret

; div_q16_16_round: EAX=num, EDX=den -> EAX=round((num*2^16)/den)
; If den is zero, returns 0.
div_q16_16_round:
    test edx, edx
    jnz .nonzero
    xor eax, eax
    ret

.nonzero:
    movsxd rax, eax
    shl rax, FP_FRAC_BITS
    movsxd rbx, edx

    ; abs(den) into R8
    mov r8, rbx
    mov r9, r8
    sar r9, 63
    xor r8, r9
    sub r8, r9
    shr r8, 1

    mov r10, rax
    xor r10, rbx
    test r10, r10
    js .opp_sign
    add rax, r8
    jmp .do_div
.opp_sign:
    sub rax, r8

.do_div:
    cqo
    idiv rbx
    mov eax, eax
    ret

%endif
