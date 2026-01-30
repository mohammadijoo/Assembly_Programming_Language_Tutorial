; Chapter 7 - Lesson 1
; Example 3: Locals on the stack + addressing via RBP (frame pointer)
;
; We implement:
;   uint64_t poly(uint64_t x) = 3*x*x + 5*x + 7
; using stack locals to hold intermediate values and show RBP-relative addressing.
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3

global _start

section .data
msg: db "poly(0x0000000000000009) = 0x",0
msg_len: equ $-msg-1
hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1

section .text

_start:
    mov rdi, msg
    mov rsi, msg_len
    call write_buf

    mov rdi, 9
    call poly

    ; result in RAX
    call print_hex64

    xor edi, edi
    mov eax, 60
    syscall

; uint64_t poly(uint64_t x)
; SysV AMD64: x in RDI, return in RAX
poly:
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; 4 locals (8 bytes each), keeps 16-byte alignment after CALL

    ; locals:
    ; [rbp-8]  = x
    ; [rbp-16] = x^2
    ; [rbp-24] = 3*x^2
    ; [rbp-32] = 5*x

    mov [rbp-8], rdi

    mov rax, [rbp-8]
    imul rax, rax           ; rax = x^2
    mov [rbp-16], rax

    mov rax, [rbp-16]
    lea rax, [rax + 2*rax]  ; rax = 3*x^2
    mov [rbp-24], rax

    mov rax, [rbp-8]
    lea rax, [rax + 4*rax]  ; rax = 5*x
    mov [rbp-32], rax

    ; rax = 3*x^2 + 5*x + 7
    mov rax, [rbp-24]
    add rax, [rbp-32]
    add rax, 7

    leave
    ret

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

print_hex64:
    lea rdi, [rel hexbuf]
    mov rcx, 16
    lea r8,  [rel hex_digits]
.loop:
    mov rdx, rax
    shr rdx, 60
    mov dl, [r8 + rdx]
    mov [rdi], dl
    inc rdi
    shl rax, 4
    dec rcx
    jnz .loop
    mov byte [rdi], 10
    lea rdi, [rel hexbuf]
    mov rsi, 17
    jmp write_buf
