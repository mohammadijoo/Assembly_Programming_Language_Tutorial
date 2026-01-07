; Chapter3_Lesson12_Ex14.asm
; Programming Exercise Solution:
;   Square root in Q16.16 using Newton iteration:
;     y_{n+1} = (y_n + x / y_n) / 2
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex14.asm -o Chapter3_Lesson12_Ex14.o
;   ld -o Chapter3_Lesson12_Ex14 Chapter3_Lesson12_Ex14.o
; run:
;   ./Chapter3_Lesson12_Ex14

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

%define FRAC_BITS 16
%define ROUND_BIAS (1 << (FRAC_BITS-1))

section .data
x_q dd 0x000A0000       ; x = 10.0 in Q16.16

section .bss
buf resb 64

section .text
global _start

; div_q16_16_round: EAX=num, EDX=den -> EAX=round((num*2^16)/den)
; If den is zero, returns 0.
div_q16_16_round:
    test edx, edx
    jnz .nonzero
    xor eax, eax
    ret
.nonzero:
    movsxd rax, eax
    shl rax, FRAC_BITS
    movsxd rbx, edx

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

; print_q16_16_4dp: prints EAX as signed Q16.16 with 4 decimals
print_q16_16_4dp:
    movsxd rax, eax
    mov r10, rax
    test rax, rax
    jns .abs_done
    neg rax
.abs_done:
    mov r8, rax
    shr r8, 16
    mov r9, rax
    and r9, 0xFFFF

    mov rax, r9
    imul rax, 10000
    add rax, 32768
    shr rax, 16
    mov r9, rax

    lea rdi, [buf + 63]
    mov byte [rdi], 10
    dec rdi

    mov rcx, 4
.frac_loop:
    mov eax, r9d
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    mov r9d, eax
    dec rcx
    jnz .frac_loop

    mov byte [rdi], '.'
    dec rdi

    mov r9, r8
    test r9, r9
    jnz .int_loop
    mov byte [rdi], '0'
    dec rdi
    jmp .int_done

.int_loop:
    mov rax, r9
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    mov r9, rax
    test r9, r9
    jnz .int_loop

.int_done:
    test r10, r10
    jns .sign_done
    mov byte [rdi], '-'
    dec rdi
.sign_done:
    lea rsi, [rdi + 1]
    lea rdx, [buf + 64]
    sub rdx, rsi
    mov edi, 1
    mov eax, SYS_write
    syscall
    ret

_start:
    ; Handle x <= 0 by printing 0.0000 (for this demo).
    mov eax, [x_q]
    test eax, eax
    jg .pos
    xor eax, eax
    call print_q16_16_4dp
    jmp .exit

.pos:
    ; Initial guess y0 = x (converges, but not minimal iterations)
    mov r12d, eax               ; y

    mov ecx, 10                 ; fixed iteration count
.iter:
    ; q = x / y
    mov eax, [x_q]
    mov edx, r12d
    call div_q16_16_round        ; q

    ; y = (y + q) / 2
    add eax, r12d                ; y+q in eax (both positive here)
    sar eax, 1                   ; divide by 2 in Q16.16
    mov r12d, eax

    dec ecx
    jnz .iter

    mov eax, r12d
    call print_q16_16_4dp

.exit:
    xor edi, edi
    mov eax, SYS_exit
    syscall
