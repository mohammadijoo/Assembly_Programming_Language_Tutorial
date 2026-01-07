; Chapter3_Lesson12_Ex9.asm
; Print a signed Q16.16 value to stdout with 4 decimal digits.
; This is a debugging aid: it trades speed for clarity.
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex9.asm -o Chapter3_Lesson12_Ex9.o
;   ld -o Chapter3_Lesson12_Ex9 Chapter3_Lesson12_Ex9.o
; run:
;   ./Chapter3_Lesson12_Ex9

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
value_q16_16  dd 0xFFFF4000     ; -0.75

section .bss
buf resb 64

section .text
global _start

; print_q16_16_4dp:
;   input: EAX = signed Q16.16
;   clobbers: rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10
print_q16_16_4dp:
    ; Use 64-bit absolute value to safely handle 0x80000000
    movsxd rax, eax
    mov r10, rax                ; keep signed for sign test
    test rax, rax
    jns .abs_done
    neg rax
.abs_done:
    ; rax = abs(value)

    ; integer part and fractional part
    mov r8, rax
    shr r8, 16                  ; integer = abs >> 16
    mov r9, rax
    and r9, 0xFFFF              ; frac = abs & 0xFFFF

    ; frac4 = round(frac * 10000 / 65536)
    mov rax, r9
    imul rax, 10000
    add rax, 32768              ; rounding for /65536
    shr rax, 16
    mov r9, rax                 ; r9 = frac4 (0..10000)

    ; build output backwards into buf
    lea rdi, [buf + 63]
    mov byte [rdi], 10          ; newline
    dec rdi

    ; write 4 fractional digits, zero-padded
    mov rcx, 4
.frac_loop:
    mov eax, r9d
    xor edx, edx
    mov ebx, 10
    div ebx                     ; eax=quot, edx=rem
    add dl, '0'
    mov [rdi], dl
    dec rdi
    mov r9d, eax
    dec rcx
    jnz .frac_loop

    ; decimal point
    mov byte [rdi], '.'
    dec rdi

    ; write integer digits (at least one digit)
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
    ; sign
    test r10, r10
    jns .sign_done
    mov byte [rdi], '-'
    dec rdi
.sign_done:

    ; write buffer to stdout
    lea rsi, [rdi + 1]
    lea rdx, [buf + 64]
    sub rdx, rsi                ; length
    mov edi, 1                  ; fd=stdout
    mov eax, SYS_write
    syscall
    ret

_start:
    mov eax, [value_q16_16]
    call print_q16_16_4dp

    xor edi, edi
    mov eax, SYS_exit
    syscall
