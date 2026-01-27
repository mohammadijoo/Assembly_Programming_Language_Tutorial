; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Exercise 1 (Solution): SysV AMD64 dot product of int32 arrays (Linux ELF64)
; Signature:
;   int64 dot_i32(const int32* a, const int32* b, uint64 n)
; SysV AMD64: a=RDI, b=RSI, n=RDX, return=RAX
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson6_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10 ; exit status is dot&255

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
; a = [  3, -2,  7,  1]
; b = [ -5,  4,  6, -3]
a dd 3, -2, 7, 1
b dd -5, 4, 6, -3
n dq 4

SECTION .text

dot_i32:
    xor rax, rax            ; accumulator (int64)
    test rdx, rdx
    jz .done

.loop:
    movsxd r8, dword [rdi]  ; load a[i] -> sign-extend to 64
    movsxd r9, dword [rsi]  ; load b[i]
    imul r8, r9             ; r8 = a[i]*b[i] (64-bit)
    add rax, r8             ; acc += product

    add rdi, 4
    add rsi, 4
    dec rdx
    jnz .loop

.done:
    ret

_start:
    lea rdi, [a]
    lea rsi, [b]
    mov rdx, [n]
    call dot_i32

    mov rdi, rax
    and rdi, 255
    mov eax, 60
    syscall
