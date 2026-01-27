; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 8: x86 32-bit fastcall (MS-style): first two args in ECX/EDX, rest on stack
; Note: On Linux this is not the platform ABI, but you can use it for private APIs if both
; caller and callee agree.
; Build (Linux 32-bit environment):
;   nasm -felf32 Chapter6_Lesson6_Ex8.asm -o ex8.o
;   ld -m elf_i386 -o ex8 ex8.o
; Run:
;   ./ex8 ; exit status is 10+20+30 = 60

BITS 32
GLOBAL _start

SECTION .text

; int add3_fastcall(int a, int b, int c)
; fastcall (MS 32-bit style):
;   a=ECX, b=EDX, c=[ESP+4], callee cleans stack args (here only c).
add3_fastcall:
    mov eax, ecx
    add eax, edx
    add eax, [esp+4]
    ret 4                   ; pop c

_start:
    mov ecx, 10
    mov edx, 20
    push dword 30
    call add3_fastcall       ; callee pops 4 bytes

    mov ebx, eax
    mov eax, 1
    int 0x80
