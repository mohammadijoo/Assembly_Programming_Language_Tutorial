BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Hard exercise solution:
; Convert a full 128-bit unsigned integer (hi:lo) into a decimal ASCII string.

section .rodata
hdr db "u128 -> decimal demo (hi:lo -> base-10 string)",10,0
lbl db "Input (hex hi, hex lo):",10,0
out db "Output (decimal): ",0

; Example value: 0x0123456789ABCDEF_FEDCBA9876543210
u128_hi dq 0x0123456789ABCDEF
u128_lo dq 0xFEDCBA9876543210

section .bss
decbuf resb 128

section .text
global _start

; -----------------------------------------------------------------------------
; div128_u10
;   inputs:  rdi = hi, rsi = lo   (N = hi*2^64 + lo)
;   outputs: rdi = q_hi, rsi = q_lo, rax = remainder (0..9)
; -----------------------------------------------------------------------------
div128_u10:
    mov rax, rdi
    xor rdx, rdx
    mov rcx, 10
    div rcx                 ; q_hi in rax, rem in rdx

    mov r8, rax             ; q_hi

    mov rax, rsi            ; lo
    ; rdx is remainder from high division; numerator is rdx:rax
    div rcx                 ; q_lo in rax, rem in rdx

    mov rdi, r8
    mov rsi, rax
    mov rax, rdx            ; remainder
    ret

; -----------------------------------------------------------------------------
; u128_to_dec
;   inputs:  rdi = hi, rsi = lo, rbx = dest buffer
;   outputs: rax = length (bytes), dest buffer filled with digits (no NUL)
; -----------------------------------------------------------------------------
u128_to_dec:
    push r12
    push r13

    lea r12, [decbuf+127]   ; write digits backwards
    mov byte [r12], 0

    mov r13d, 0             ; digit count

    ; Special case for 0
    test rdi, rdi
    jnz .loop
    test rsi, rsi
    jnz .loop
    dec r12
    mov byte [r12], '0'
    mov r13d, 1
    jmp .emit

.loop:
    ; (hi,lo) /= 10; remainder is digit
    call div128_u10
    dec r12
    add al, '0'
    mov [r12], al
    inc r13d

    ; update hi/lo
    ; (div128_u10 already returned quotient in rdi/rsi)
    test rdi, rdi
    jnz .loop
    test rsi, rsi
    jnz .loop

.emit:
    ; copy to caller buffer (RBX) from r12 for r13 bytes
    mov rcx, r13
    mov rsi, r12
    mov rdi, rbx
    rep movsb
    mov rax, r13

    pop r13
    pop r12
    ret

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    mov rdi, STDOUT
    lea rsi, [lbl]
    call print_cstr

    mov rdi, [u128_hi]
    call print_hex64
    call print_nl
    mov rdi, [u128_lo]
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [out]
    call print_cstr

    mov rdi, [u128_hi]
    mov rsi, [u128_lo]
    lea rbx, [decbuf]
    call u128_to_dec

    mov rdx, rax
    mov rdi, STDOUT
    lea rsi, [decbuf]
    call write_buf
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall
