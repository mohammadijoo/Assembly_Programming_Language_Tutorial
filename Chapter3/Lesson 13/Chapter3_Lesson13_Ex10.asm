; Chapter 3 - Lesson 13 Exercise Solution 2 (Very Hard):
; Convert binary32 bits to signed Q16.16 fixed-point with saturation and round-to-nearest-even.
; File: Chapter3_Lesson13_Ex10.asm
;
; Output is a signed 32-bit integer representing value * 2^16 (Q16.16).
; Saturation clamps to int32 range on overflow.
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
;   ./ex10

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"
%include "Chapter3_Lesson13_Ex2.asm"

%define INT32_MAX 0x7FFFFFFF
%define INT32_MIN 0x80000000

section .rodata
msg_title: db "Exercise Solution 2: fp32 bits -> Q16.16 (sat, round-to-nearest-even)", 0
msg_hdr:   db "format: fp_bits  class  q16.16_hex  q16.16_dec", 0
msg_spc:   db "  ", 0

tests:
    dd 0x3F800000         ; +1.0
    dd 0xBF800000         ; -1.0
    dd 0x3FC00000         ; +1.5
    dd 0xBFC00000         ; -1.5
    dd 0x3F666666         ; ~0.9
    dd 0xC1FF0000         ; -31.875
    dd 0x47000000         ; +32768.0 (just over Q16.16 integer limit)
    dd 0x7F800000         ; +inf
    dd 0x7FC00001         ; qNaN
    dd 0x00000001         ; tiny subnormal
tests_end:

section .text
global _start

; fp32_to_q16_16_sat(eax=bits) -> eax = signed Q16.16 (sat)
; Strategy (integer decode):
;   - Extract sign s, exponent e, fraction f.
;   - If e==255: saturate (NaN/Inf)
;   - Build mantissa M:
;       if e==0: M=f,        shift_total = -133  (because value*2^16 = f * 2^-133)
;       else:    M=(1<<23)|f, shift_total = e - 134 (because value*2^16 = M * 2^(e-134))
;   - If shift_total >= 0: left shift (may overflow) -> saturate
;   - If shift_total < 0 : right shift with round-to-nearest-even
;   - Apply sign with saturation
fp32_to_q16_16_sat:
    push rbx
    push r12

    mov ebx, eax               ; keep original bits
    call fp32_get_fields        ; eax=bits -> ecx sign, edx exp, r8d frac

    ; NaN/Inf -> saturate based on sign (arbitrary policy: + -> INT32_MAX, - -> INT32_MIN)
    cmp edx, 0xFF
    jne .not_special
    test r8d, r8d
    jz .inf
    ; NaN
    cmp cl, 0
    jne .sat_min
    mov eax, INT32_MAX
    jmp .done
.inf:
    cmp cl, 0
    jne .sat_min
    mov eax, INT32_MAX
    jmp .done

.not_special:
    ; Compute mantissa M in rax (<= 24 bits for normal, <= 23 for subnormal)
    ; Compute signed shift_total in r12d
    cmp edx, 0
    jne .normal

    ; subnormal/zero: M = frac, shift_total = -133
    mov eax, r8d
    mov r12d, -133
    jmp .scale

.normal:
    mov eax, r8d
    or eax, 0x00800000          ; implicit leading 1
    ; shift_total = e - 134
    mov r12d, edx
    sub r12d, 134

.scale:
    ; If M==0 then result is 0 (preserve sign? Q16.16 has signed zero; we keep 0)
    test eax, eax
    jz .zero

    ; Work in 64-bit
    movzx rax, eax

    ; shift_total >= 0 => left shift (risk overflow)
    cmp r12d, 0
    jl .right_shift

.left_shift:
    cmp r12d, 63
    jae .overflow
    mov ecx, r12d
    shl rax, cl

    ; Saturate if exceeds signed 32-bit magnitude
    ; We'll check against INT32_MAX in unsigned form.
    cmp rax, INT32_MAX
    ja .overflow

    mov eax, eax                ; low 32 bits are the result
    jmp .apply_sign

.right_shift:
    ; Right shift by k = -shift_total with round-to-nearest-even
    mov ecx, r12d
    neg ecx                     ; k
    cmp ecx, 63
    jae .underflow

    ; Compute:
    ;   shifted = M >> k
    ;   remainder = M & ((1<<k)-1)
    ; tie = 1<<(k-1)
    mov rdx, rax
    mov rbx, 1
    shl rbx, cl                 ; rbx = 1<<k
    dec rbx                     ; rbx = (1<<k)-1
    and rdx, rbx                ; remainder

    mov rbx, 1
    mov r9d, ecx
    dec r9d
    shl rbx, r9b                ; rbx = 1<<(k-1)  (tie value)

    shr rax, cl                 ; shifted

    ; Compare remainder with tie
    cmp rdx, rbx
    jb .no_round
    ja .round_up
    ; remainder == tie -> round to even: increment if LSB is 1
    test al, 1
    jz .no_round
.round_up:
    inc rax
.no_round:
    ; Saturate if shifted does not fit int32
    cmp rax, INT32_MAX
    ja .overflow
    mov eax, eax
    jmp .apply_sign

.underflow:
    xor eax, eax
    jmp .done

.zero:
    xor eax, eax
    jmp .done

.apply_sign:
    cmp cl, 0
    je .done
    ; negate with saturation
    cmp eax, INT32_MIN
    je .sat_min                ; -(INT32_MIN) would overflow
    neg eax
    jmp .done

.overflow:
    cmp cl, 0
    jne .sat_min
    mov eax, INT32_MAX
    jmp .done

.sat_min:
    mov eax, INT32_MIN

.done:
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    lea rdi, [msg_hdr]
    call print_cstr
    call print_nl

    lea rbx, [tests]
.loop:
    cmp rbx, tests_end
    jae .exit

    mov eax, dword [rbx]       ; fp bits

    ; print fp bits
    mov edi, eax
    call print_hex32
    lea rdi, [msg_spc]
    call print_cstr

    ; class
    push rbx
    call fp32_classify
    mov rdi, rax
    call print_cstr
    lea rdi, [msg_spc]
    call print_cstr

    ; convert
    mov eax, dword [rbx]
    call fp32_to_q16_16_sat

    ; q16.16 hex
    mov edi, eax
    call print_hex32
    lea rdi, [msg_spc]
    call print_cstr

    ; q16.16 decimal (signed)
    movsxd rdi, eax
    call print_i64

    call print_nl
    pop rbx

    add rbx, 4
    jmp .loop

.exit:
    mov eax, SYS_exit
    xor edi, edi
    syscall
