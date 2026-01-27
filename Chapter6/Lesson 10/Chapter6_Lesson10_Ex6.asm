; Chapter 6 - Lesson 10 (Ex6): Windows x64 - Calling a varargs function (printf) with a double
; Key rule (Windows x64): for vararg or unprototyped calls,
;   floating-point values must be duplicated in the corresponding GP register.
; Also: caller must reserve 32 bytes of shadow space.
;
; Build (Windows x64, one possible workflow):
;   nasm -f win64 Chapter6_Lesson10_Ex6.asm -o ex6.obj
;   link /subsystem:console ex6.obj msvcrt.lib kernel32.lib
;
; Note: This file is intended for Windows; it won't link on Linux.

default rel
bits 64

extern printf
extern ExitProcess
global main

section .rdata
fmt:  db "x=%f, y=%lld", 13,10,0
xval: dq 0x3ff4000000000000      ; 1.25

section .text
main:
    sub rsp, 28h                 ; 32 shadow + 8 for 16B alignment at call sites

    lea rcx, [fmt]               ; 1st arg: format string (RCX)
    movsd xmm1, [xval]           ; 2nd arg: double (XMM1 because position=2)
    movq rdx, xmm1               ; varargs rule: duplicate FP value in GP reg (RDX)
    mov r8, 42                   ; 3rd arg: long long in R8

    call printf

    xor ecx, ecx
    call ExitProcess
