BITS 64
default rel

; Module B: references symbols defined in another object (extern).
; Links with Chapter6_Lesson4_Ex7.asm (Module A).
; Build:
;   nasm -felf64 Chapter6_Lesson4_Ex7.asm -o a.o
;   nasm -felf64 Chapter6_Lesson4_Ex8.asm -o b.o
;   ld -o demo a.o b.o

global _start
extern g_shared
extern get_shared

section .text
_start:
    ; Overwrite the shared global, then call the getter.
    mov qword [rel g_shared], 200
    call get_shared

    ; Exit status = low 8 bits (200).
    mov edi, eax
    mov eax, 60
    syscall
