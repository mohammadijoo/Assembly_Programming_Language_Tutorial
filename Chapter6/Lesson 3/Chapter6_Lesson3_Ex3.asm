; Chapter6_Lesson3_Ex3.asm
; Example 3 (Microsoft x64 / Windows): register args + shadow space.
;
; Windows x64 integer/pointer args:
;   a1=RCX, a2=RDX, a3=R8, a4=R9, a5.. on stack
; Caller MUST reserve 32 bytes of "shadow space" before every call.
;
; This example uses ExitProcess to terminate with an exit code.
;
; Build (Windows with MSVC toolchain style linking):
;   nasm -f win64 Chapter6_Lesson3_Ex3.asm -o ex3.obj
;   link /SUBSYSTEM:CONSOLE ex3.obj kernel32.lib
;
; Or with MinGW-w64 (paths vary):
;   nasm -f win64 Chapter6_Lesson3_Ex3.asm -o ex3.obj
;   gcc ex3.obj -o ex3.exe -lkernel32

default rel
global  main
extern  ExitProcess

section .text

; uint64 sum5(uint64 a,b,c,d,e)
; Windows x64: a=RCX,b=RDX,c=R8,d=R9,e=[rsp+40] at entry (because of return addr + shadow)
sum5:
    push    rbp
    mov     rbp, rsp

    mov     rax, rcx
    add     rax, rdx
    add     rax, r8
    add     rax, r9

    ; With a frame pointer:
    ; [rbp+48] = 5th arg (return addr at [rbp+8], shadow 32 bytes, then arg5)
    add     rax, [rbp + 48]

    pop     rbp
    ret

main:
    ; At function entry, RSP is typically 8 (mod 16).
    ; Sub 40 = 32 shadow + 8 alignment => RSP becomes 0 (mod 16) for calls.
    sub     rsp, 40

    mov     rcx, 1
    mov     rdx, 2
    mov     r8,  3
    mov     r9,  4
    mov     qword [rsp + 32], 5     ; 5th arg goes above shadow space
    call    sum5

    mov     ecx, eax               ; exit code in ECX
    call    ExitProcess
