; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 9: ABI "thunk" - call a Microsoft-x64-style callee from a SysV AMD64 caller
; This is purely a register/stack contract. It can run on Linux because both functions
; are written in assembly with explicitly chosen conventions.
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson6_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
; Run:
;   ./ex9 ; exit status is (1+2+3+4)&255 = 10

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .text

; "MS-style" callee: expects args in RCX/RDX/R8/R9, returns RAX.
ms_add4:
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    ret

; SysV wrapper:
; int64 call_ms_add4_from_sysv(int64 a, int64 b, int64 c, int64 d)
; SysV args: a=RDI, b=RSI, c=RDX, d=RCX
call_ms_add4_from_sysv:
    ; Reserve "shadow space" and align for the MS-style callee.
    sub rsp, 40             ; 32 bytes shadow + 8 alignment
    mov r8,  rdx            ; c
    mov r9,  rcx            ; d
    mov rcx, rdi            ; a
    mov rdx, rsi            ; b
    call ms_add4
    add rsp, 40
    ret

_start:
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    call call_ms_add4_from_sysv

    mov rdi, rax
    and rdi, 255
    mov eax, 60
    syscall
