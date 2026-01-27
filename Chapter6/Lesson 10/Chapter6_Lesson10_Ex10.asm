; Chapter 6 - Lesson 10 (Ex10): Windows x64 - VERY HARD: variadic sum of doubles
; Signature (C view): double sum_doubles_win(long long n, ...);
; For Windows varargs, floating-point values must be duplicated in GP regs by the caller.
; The callee typically reads varargs from the homed integer slots / stack as raw 8-byte values.
;
; Build (Windows x64, one possible workflow):
;   nasm -f win64 Chapter6_Lesson10_Ex10.asm -o ex10.obj
;   link /subsystem:console ex10.obj msvcrt.lib kernel32.lib
;
; Note: This file is intended for Windows; it won't link on Linux.

default rel
bits 64

extern printf
extern ExitProcess
global main
global sum_doubles_win

section .rdata
fmt: db "sum_doubles_win(%lld, ...) = %.6f", 13,10,0

; double constants (bit patterns)
d1:  dq 0x3ff0000000000000      ; 1.0
d2:  dq 0x4000000000000000      ; 2.0
d3:  dq 0x4008000000000000      ; 3.0
d4:  dq 0x4010000000000000      ; 4.0
d5:  dq 0x4014000000000000      ; 5.0

section .text
; double sum_doubles_win(long long n, ...);
; RCX=n, varargs occupy 8-byte slots corresponding to parameter positions 2.. in RDX/R8/R9 then stack.
; Caller duplicates doubles into RDX/R8/R9 (and stack) so we can read raw bits and movq into XMM.
sum_doubles_win:
    push rbp
    mov rbp, rsp

    ; Home the three register varargs (positions 2..4) into shadow space
    mov [rbp+24], rdx
    mov [rbp+32], r8
    mov [rbp+40], r9

    pxor xmm0, xmm0              ; sum = 0.0
    xor r10d, r10d               ; i = 0

.loop:
    cmp r10, rcx
    jae .done

    cmp r10, 3
    jb .from_home

    ; stack doubles beyond first 3 register varargs:
    ; param5 starts at [rbp+48]
    mov r11, r10
    sub r11, 3
    mov rax, [rbp + 48 + r11*8]
    movq xmm1, rax
    jmp .acc

.from_home:
    mov rax, [rbp + 24 + r10*8]
    movq xmm1, rax

.acc:
    addsd xmm0, xmm1
    inc r10
    jmp .loop

.done:
    pop rbp
    ret

main:
    sub rsp, 28h                 ; shadow + alignment

    ; Call sum_doubles_win(5, 1.0,2.0,3.0,4.0,5.0)
    mov rcx, 5

    ; 1st double vararg (position 2): duplicate into RDX and XMM1
    mov rdx, [d1]
    movq xmm1, rdx

    ; 2nd double vararg (position 3): duplicate into R8 and XMM2
    mov r8, [d2]
    movq xmm2, r8

    ; 3rd double vararg (position 4): duplicate into R9 and XMM3
    mov r9, [d3]
    movq xmm3, r9

    ; Remaining doubles (positions 5..): on stack after shadow space
    mov rax, [d4]
    mov [rsp + 20h], rax
    mov rax, [d5]
    mov [rsp + 28h], rax

    call sum_doubles_win          ; result in XMM0

    ; printf(fmt, n, result)
    lea rcx, [fmt]
    mov rdx, 5
    ; result is the 3rd parameter => position 3 => XMM2, and for varargs also in R8
    movapd xmm2, xmm0
    movq r8, xmm2                 ; duplicate for printf varargs
    call printf

    xor ecx, ecx
    call ExitProcess
