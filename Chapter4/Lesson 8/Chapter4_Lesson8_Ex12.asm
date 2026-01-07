BITS 64
default rel

; Ex12 (Exercise Solution 2): SysV AMD64 callable multi-precision subtract + unsigned compare.
; uint8_t mp_sub_qwords(uint64_t* out, const uint64_t* a, const uint64_t* b, size_t n);
;   returns borrow_out in al (CF after final SBB).
;
; int mp_cmp_qwords(const uint64_t* a, const uint64_t* b, size_t n);
;   returns: -1 if a<b, 0 if equal, +1 if a>b (unsigned), scanning from MS limb.
;
; Includes a minimal harness _start.

global mp_sub_qwords
global mp_cmp_qwords
global _start

%define N 4

section .data
    A dq 0,0,0,2
    B dq 1,0,0,1
    OUT times N dq 0
    borrow db 0
    cmp_res dq 0

section .text
mp_sub_qwords:
    test rcx, rcx
    jz .done0

    clc
.loop:
    mov r8, [rsi]
    sbb r8, [rdx]
    mov [rdi], r8

    add rsi, 8
    add rdx, 8
    add rdi, 8
    dec rcx
    jnz .loop

    setc al
    ret
.done0:
    xor eax, eax
    ret

mp_cmp_qwords:
    ; rdi=a, rsi=b, rdx=n
    test rdx, rdx
    jz .eq

    ; start at most significant limb: index = n-1
    lea rcx, [rdx - 1]
.loop_cmp:
    mov r8, [rdi + rcx*8]
    mov r9, [rsi + rcx*8]
    cmp r8, r9
    jb .lt
    ja .gt
    dec rcx
    jns .loop_cmp

.eq:
    xor eax, eax
    ret
.lt:
    mov eax, -1
    ret
.gt:
    mov eax, 1
    ret

_start:
    ; OUT = A - B
    lea rdi, [OUT]
    lea rsi, [A]
    lea rdx, [B]
    mov rcx, N
    call mp_sub_qwords
    mov [borrow], al

    ; cmp(A,B)
    lea rdi, [A]
    lea rsi, [B]
    mov rdx, N
    call mp_cmp_qwords
    movsx rax, eax
    mov [cmp_res], rax

    mov eax, 60
    xor edi, edi
    syscall
