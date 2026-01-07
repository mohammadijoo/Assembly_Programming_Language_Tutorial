BITS 64
default rel
global _start

; Ex8: Two's-complement negation of an N-limb integer:
; OUT = -X  (mod 2^(64*N))  ==  (~X) + 1
; Pattern: NOT each limb, then add 1 via ADD/ADC chain.

%define N 6

section .data
    X   dq 0x0000000000000001, 0x0, 0x0, 0x0, 0x0, 0x0
    OUT times N dq 0
    carry_out db 0              ; carry from (~X)+1 beyond top limb (should be 0 unless X=0)

section .text
_start:
    ; OUT = ~X
    xor rcx, rcx
.not_loop:
    mov rax, [X + rcx*8]
    not rax
    mov [OUT + rcx*8], rax
    inc rcx
    cmp rcx, N
    jne .not_loop

    ; OUT = OUT + 1
    add qword [OUT + 0], 1
    jnc .finish                 ; no carry -> done

    mov rcx, 1
.add1:
    adc qword [OUT + rcx*8], 0
    jnc .finish
    inc rcx
    cmp rcx, N
    jne .add1

.finish:
    setc byte [carry_out]

    mov eax, 60
    xor edi, edi
    syscall
