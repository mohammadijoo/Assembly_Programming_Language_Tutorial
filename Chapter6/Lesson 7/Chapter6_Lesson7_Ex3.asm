; Chapter 6 - Lesson 7 - Example 3
; Title: SysV red zone demonstration (leaf function uses [rsp - k] without touching RSP)
; IMPORTANT:
;   - SysV AMD64 ABI provides a 128-byte red zone below RSP (addresses [rsp-128 .. rsp-1])
;   - Leaf functions may use it without "sub rsp, N"
;   - Windows x64 has NO red zone: this style is NOT portable.

; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    ; Caller maintains call-site alignment. At _start, RSP is 16-aligned.
    call leaf_redzone_sysv

    ; Exit with low byte of RAX as status (just to have a visible result)
    mov edi, eax
    mov eax, 60
    syscall

; leaf_redzone_sysv:
;   Computes (7 + 11) and returns 18 in RAX using the red zone as scratch.
leaf_redzone_sysv:
    ; No prologue, no stack pointer adjustment.
    ; Use red zone for two 8-byte temporaries.
    mov qword [rsp - 8], 7
    mov qword [rsp - 16], 11

    mov rax, [rsp - 8]
    add rax, [rsp - 16]
    ret
