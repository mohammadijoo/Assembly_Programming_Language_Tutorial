; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 7: x86 32-bit stdcall basics (callee cleans via ret imm) (Linux i386)
; Build (Linux 32-bit environment):
;   nasm -felf32 Chapter6_Lesson6_Ex7.asm -o ex7.o
;   ld -m elf_i386 -o ex7 ex7.o
; Run:
;   ./ex7 ; exit status is 1+2+3 = 6

BITS 32
GLOBAL _start

SECTION .text

; int add3_stdcall(int a, int b, int c)
; stdcall: args on stack, callee cleans.
add3_stdcall:
    mov eax, [esp+4]
    add eax, [esp+8]
    add eax, [esp+12]
    ret 12                  ; pop 3 args (12 bytes)

_start:
    push dword 3
    push dword 2
    push dword 1
    call add3_stdcall        ; callee cleaned, do not adjust ESP

    mov ebx, eax
    mov eax, 1
    int 0x80
