; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 6: x86 32-bit cdecl basics (Linux i386, NASM elf32)
; Build (Linux 32-bit environment):
;   nasm -felf32 Chapter6_Lesson6_Ex6.asm -o ex6.o
;   ld -m elf_i386 -o ex6 ex6.o
; Run:
;   ./ex6 ; exit status is 10+20+30 = 60

BITS 32
GLOBAL _start

SECTION .text

; int add3_cdecl(int a, int b, int c)
; cdecl (typical): args on stack right-to-left, caller cleans.
; Stack at entry:
;   [ESP+4]=a, [ESP+8]=b, [ESP+12]=c
add3_cdecl:
    mov eax, [esp+4]
    add eax, [esp+8]
    add eax, [esp+12]
    ret

_start:
    push dword 30
    push dword 20
    push dword 10
    call add3_cdecl
    add esp, 12             ; caller cleanup

    ; Linux i386 exit(status)
    mov ebx, eax
    mov eax, 1
    int 0x80
