; Chapter 7 - Lesson 1
; Example 5: Variable-size stack allocation with explicit alignment
;
; We build an aligned stack buffer of N bytes at runtime, write a pattern,
; compute a checksum, and print it. This is "alloca-like" but done manually.
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

global _start

section .data
intro: db "Checksum (hex) = 0x"
intro_len: equ $-intro
hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1

section .text

_start:
    mov rdi, intro
    mov rsi, intro_len
    call write_buf

    ; Choose N=200 bytes, align=32 bytes
    mov rdi, 200
    mov rsi, 32
    call alloca_aligned          ; returns pointer in RAX, saved restore token in RDX

    ; Fill buffer with deterministic pattern: buf[i] = i ^ 0x5a
    mov rbx, rax                 ; buf base
    xor rcx, rcx                 ; i=0
.fill:
    mov al, cl
    xor al, 0x5a
    mov [rbx + rcx], al
    inc rcx
    cmp rcx, 200
    jb .fill

    ; checksum = sum(buf[i]) mod 2^64
    xor rax, rax                 ; checksum
    xor rcx, rcx
.sum:
    movzx r8, byte [rbx + rcx]
    add rax, r8
    inc rcx
    cmp rcx, 200
    jb .sum

    ; restore stack (must happen before any RET in real functions)
    mov rsp, rdx                 ; restore token is the old RSP

    call print_hex64

    xor edi, edi
    mov eax, 60
    syscall

; ------------------------------------------------------------
; alloca_aligned(rdi=size, rsi=align_pow2) -> rax=ptr, rdx=old_rsp
;
; - Reserves size bytes on stack and returns an aligned pointer within it.
; - Returns old RSP in RDX so caller can restore quickly (like stack unwinding).
;
; NOTE: This is a teaching routine. In a real ABI-conformant function, you would
; also ensure that any calls maintain required alignment.
; ------------------------------------------------------------
alloca_aligned:
    mov rdx, rsp                 ; save old RSP (restore token)

    ; Reserve size + (align-1) bytes to ensure we can align within the block
    mov rax, rsi
    dec rax                      ; rax = align-1
    add rax, rdi                 ; total extra
    sub rsp, rax                 ; grow stack

    ; Align pointer up: aligned = (rsp + (align-1)) & ~(align-1)
    mov rax, rsp
    add rax, rsi
    dec rax
    mov rcx, rsi
    dec rcx
    not rcx
    and rax, rcx                 ; rax is aligned pointer
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
    mov r9, rax
    shr r9, 60
    mov r9b, [r8 + r9]
    mov [rdi], r9b
    inc rdi
    shl rax, 4
    dec rcx
    jnz .loop
    mov byte [rdi], 10
    lea rdi, [rel hexbuf]
    mov rsi, 17
    jmp write_buf
