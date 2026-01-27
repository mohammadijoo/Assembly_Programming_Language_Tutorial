; Chapter 6 - Lesson 10 (Ex8): SysV AMD64 - HARD: variadic sum of doubles (dot-free sum)
; Signature (C view): double sum_doubles(long n, ...);
; Varargs are doubles; first up to 8 are in XMM0..XMM7, the rest on the stack.
; Caller must set AL to an upper bound on the number of vector regs used (0..8).
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex8.asm -o ex8.o
;   gcc -no-pie ex8.o -o ex8
; Run:
;   ./ex8

default rel
bits 64

extern printf
global main
global sum_doubles

section .rodata
fmt: db "sum_doubles(%ld, ...) = %.6f", 10, 0
d1:  dq 0x3ff0000000000000      ; 1.0
d2:  dq 0x4000000000000000      ; 2.0
d3:  dq 0x4008000000000000      ; 3.0
d4:  dq 0x4010000000000000      ; 4.0
d5:  dq 0x4014000000000000      ; 5.0
d6:  dq 0x4018000000000000      ; 6.0
d7:  dq 0x401c000000000000      ; 7.0
d8:  dq 0x4020000000000000      ; 8.0
d9:  dq 0x4022000000000000      ; 9.0
d10: dq 0x4024000000000000      ; 10.0

section .text
; double sum_doubles(long n, ...);
sum_doubles:
    push rbp
    mov rbp, rsp
    sub rsp, 80                  ; spill area for XMM0..XMM7 (8*8=64) + padding

    ; Save low 64-bit lanes (doubles) of XMM0..XMM7
    movsd [rbp-64], xmm0
    movsd [rbp-56], xmm1
    movsd [rbp-48], xmm2
    movsd [rbp-40], xmm3
    movsd [rbp-32], xmm4
    movsd [rbp-24], xmm5
    movsd [rbp-16], xmm6
    movsd [rbp-8],  xmm7

    pxor xmm0, xmm0              ; sum = 0.0
    xor r10d, r10d               ; i = 0

.loop:
    cmp r10, rdi
    jae .done

    cmp r10, 8
    jb .from_xmm

    ; stack doubles: first one is vararg[8] at [rbp+16]
    mov r11, r10
    sub r11, 8
    movsd xmm1, [rbp + 16 + r11*8]
    jmp .acc

.from_xmm:
    ; load saved XMM vararg[i] from [rbp-64 + i*8]
    movsd xmm1, [rbp - 64 + r10*8]

.acc:
    addsd xmm0, xmm1
    inc r10
    jmp .loop

.done:
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 96                  ; stack space for extra args + alignment

    ; Prepare stack-passed doubles for positions beyond XMM0..XMM7 (here: 9th and 10th)
    mov rax, [d9]
    mov [rsp + 0], rax
    mov rax, [d10]
    mov [rsp + 8], rax

    mov rdi, 10                  ; n
    movsd xmm0, [d1]
    movsd xmm1, [d2]
    movsd xmm2, [d3]
    movsd xmm3, [d4]
    movsd xmm4, [d5]
    movsd xmm5, [d6]
    movsd xmm6, [d7]
    movsd xmm7, [d8]

    mov eax, 8                   ; AL=8 vector regs used
    call sum_doubles             ; result in XMM0

    ; printf(fmt, n, result)
    mov rdi, fmt
    mov rsi, 10
    ; result double already in XMM0 (1st FP arg position after fmt/n)
    mov eax, 1                   ; for printf: we use XMM0 => AL=1
    call printf

    xor eax, eax
    leave
    ret
