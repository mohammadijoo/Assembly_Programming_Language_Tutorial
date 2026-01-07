bits 64
default rel

global main

; Chapter 3, Lesson 7, Example 7
; Printing Unicode via libc wide I/O (wprintf) on Linux/glibc.
;
; Build (typical):
;   nasm -felf64 Chapter3_Lesson7_Ex7.asm -o ex7.o
;   gcc -no-pie ex7.o -o ex7
;
; Notes:
; - On Linux/glibc, wchar_t is 4 bytes (UTF-32 code points).
; - You must set the process locale so that wide I/O uses UTF-8 encoding
;   for the terminal (commonly "C.UTF-8" or a UTF-8 locale).

extern setlocale
extern wprintf
extern exit

%define LC_ALL 6

section .data
    locale_name: db "", 0   ; "" means "use environment variables" (LANG, LC_ALL, ...)

    ; Wide format: L"%ls\n"
    fmt_w:
        dd 0x25, 0x6C, 0x73, 0x0A, 0x0000

    ; Wide string: L"Hello, 世界"
    wstr:
        dd 0x0048, 0x0065, 0x006C, 0x006C, 0x006F, 0x002C, 0x0020, 0x4E16, 0x754C, 0x0000

section .text
main:
    ; SysV ABI stack alignment: at entry, RSP is 16-byte aligned.
    ; After pushing RBP, subtract 8 to re-align before calls.
    push rbp
    mov rbp, rsp
    sub rsp, 8

    ; setlocale(LC_ALL, "")
    mov edi, LC_ALL
    lea rsi, [locale_name]
    call setlocale

    ; wprintf(L"%ls\n", wstr)
    lea rdi, [fmt_w]
    lea rsi, [wstr]
    xor eax, eax          ; required for variadic calls: number of vector registers used
    call wprintf

    ; exit(0)
    xor edi, edi
    call exit
