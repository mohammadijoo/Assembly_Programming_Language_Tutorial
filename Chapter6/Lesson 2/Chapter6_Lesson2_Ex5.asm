; Chapter 6 - Lesson 2 - Example 5
; File: Chapter6_Lesson2_Ex5.asm
; Topic: Local labels (scoped) in NASM procedures
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
; Run:
;   ./ex5 ; exit 0 on success

default rel

section .data
s1: db "abc", 0
s2: db "abcd", 0

section .text
global _start

; strlen_u8(const char* s) -> RAX length
strlen_u8:
    xor eax, eax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; count_char(const char* s, uint8_t c) -> RAX count
; Demonstrates another procedure using .loop/.done without collision:
count_char:
    xor eax, eax
    xor ecx, ecx
.loop:
    mov dl, [rdi + rcx]
    test dl, dl
    je .done
    cmp dl, sil             ; SIL = low 8 bits of RSI (c)
    jne .skip
    inc rax
.skip:
    inc rcx
    jmp .loop
.done:
    ret

_start:
    lea rdi, [rel s1]
    call strlen_u8           ; 3
    cmp rax, 3
    jne .fail

    lea rdi, [rel s2]
    mov esi, 'a'
    call count_char          ; 1
    cmp rax, 1
    jne .fail

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 60
    mov edi, 1
    syscall
