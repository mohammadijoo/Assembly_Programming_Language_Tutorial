; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 5: Microsoft x64 - stack arguments beyond 4, and shadow space (Windows x64)
; Build idea (Windows):
;   nasm -f win64 Chapter6_Lesson6_Ex5.asm -o ex5.obj
;   link /subsystem:console ex5.obj kernel32.lib
; This example is primarily for studying the stack layout of args 5..n.

BITS 64
DEFAULT REL
GLOBAL main
EXTERN ExitProcess

SECTION .text

; int64 ms_sum7(int64 a, int64 b, int64 c, int64 d, int64 e, int64 f, int64 g)
; Microsoft x64:
;   a=RCX, b=RDX, c=R8, d=R9
;   e,f,g are on stack.
; On entry (no prologue), stack args are at:
;   e = [RSP+40], f = [RSP+48], g = [RSP+56]
ms_sum7:
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    add rax, [rsp+40]
    add rax, [rsp+48]
    add rax, [rsp+56]
    ret

main:
    ; Reserve 32 shadow + 3 stack args (24) = 56 bytes.
    ; At main entry, RSP is typically 8 mod 16, so subtracting 56 makes it 0 mod 16.
    sub rsp, 56

    mov rcx, 1
    mov rdx, 2
    mov r8,  3
    mov r9,  4
    mov qword [rsp+32], 5
    mov qword [rsp+40], 6
    mov qword [rsp+48], 7
    call ms_sum7

    add rsp, 56

    sub rsp, 40
    mov ecx, eax
    call ExitProcess
