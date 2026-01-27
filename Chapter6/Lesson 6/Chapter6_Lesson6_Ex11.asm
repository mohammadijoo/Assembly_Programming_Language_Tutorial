; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Exercise 2 (Solution): SysV wrapper that calls an MS-x64-style function pointer
; Signature (SysV caller view):
;   int64 call_ms_fn4(void* fn, int64 a, int64 b, int64 c, int64 d)
; SysV AMD64: fn=RDI, a=RSI, b=RDX, c=RCX, d=R8, return=RAX
; The function pointer is expected to use MS x64: a=RCX, b=RDX, c=R8, d=R9.
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson6_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11 ; exit status is (a*b + c*d)&255 with a=2,b=9,c=3,d=5 => 33

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .text

; MS-x64-style callee: returns (a*b + c*d)
ms_muladd4:
    mov rax, rcx
    imul rax, rdx           ; a*b
    mov r10, r8
    imul r10, r9            ; c*d
    add rax, r10
    ret

; SysV wrapper calling an MS-x64-style function pointer in RDI
call_ms_fn4:
    sub rsp, 40             ; shadow + alignment for MS callee
    mov r11, rdi            ; save fn pointer

    ; Map SysV args -> MS args
    mov r9,  r8             ; d
    mov r8,  rcx            ; c
    mov rcx, rsi            ; a
    ; RDX already holds b in SysV, so keep it

    call r11

    add rsp, 40
    ret

_start:
    lea rdi, [ms_muladd4]   ; fn pointer
    mov rsi, 2              ; a
    mov rdx, 9              ; b
    mov rcx, 3              ; c
    mov r8,  5              ; d
    call call_ms_fn4

    mov rdi, rax
    and rdi, 255
    mov eax, 60
    syscall
