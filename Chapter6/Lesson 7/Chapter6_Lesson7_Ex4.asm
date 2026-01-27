; Chapter 6 - Lesson 7 - Example 4
; Title: Windows x64 shadow space + alignment (calls ExitProcess)
; Build (Windows x64, MinGW-w64 example):
;   nasm -fwin64 Chapter6_Lesson7_Ex4.asm -o ex4.obj
;   x86_64-w64-mingw32-gcc ex4.obj -o ex4.exe
;
; Notes:
;   - Windows x64 requires the caller to reserve 32 bytes of "shadow space" for callees.
;   - Stack must be 16-byte aligned at call-sites (before CALL).
;   - On entry to a function, RSP % 16 == 8 (because return address is pushed).

BITS 64
DEFAULT REL

GLOBAL main
EXTERN ExitProcess

SECTION .text

main:
    ; Allocate 0x28 bytes:
    ;   0x20 shadow space + 0x08 padding to make RSP 16-aligned for the CALL.
    sub rsp, 0x28

    xor ecx, ecx          ; RCX = exit code (Windows first arg)
    call ExitProcess

    ; Not reached, but keep structured epilogue:
    add rsp, 0x28
    ret
