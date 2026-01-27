; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 4: Microsoft x64 - first 4 args in RCX/RDX/R8/R9 (Windows x64, NASM win64)
; Build idea (Windows, MSVC link):
;   nasm -f win64 Chapter6_Lesson6_Ex4.asm -o ex4.obj
;   link /subsystem:console ex4.obj kernel32.lib
; This example is primarily for studying the calling convention details.

BITS 64
DEFAULT REL
GLOBAL main
EXTERN ExitProcess

SECTION .text

; int64 ms_sum4(int64 a, int64 b, int64 c, int64 d)
; Microsoft x64: a=RCX, b=RDX, c=R8, d=R9, return=RAX
ms_sum4:
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    ret

main:
    ; Windows x64 requires 32 bytes of shadow space for any call.
    ; Also keep 16-byte alignment before CALL.
    sub rsp, 40             ; 32 shadow + 8 alignment adjustment

    mov rcx, 1
    mov rdx, 2
    mov r8,  3
    mov r9,  4
    call ms_sum4

    ; ExitProcess(UINT uExitCode) uses ECX
    mov ecx, eax
    call ExitProcess
