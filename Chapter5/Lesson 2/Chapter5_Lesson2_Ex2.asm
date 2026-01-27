; Chapter5_Lesson2_Ex2.asm
; Topic demo: DO-WHILE (post-test) loop computing strlen (counts bytes until NUL)
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex2.asm -o Chapter5_Lesson2_Ex2.o
;   ld -o Chapter5_Lesson2_Ex2 Chapter5_Lesson2_Ex2.o
;
; Run:
;   ./Chapter5_Lesson2_Ex2
;   echo $?
;
; Exit status = (strlen(s) mod 256)

BITS 64
default rel

section .data
s: db "do-while loop: strlen", 0

section .text
global _start

_start:
    cld                 ; ensure DF=0 for string ops (forward)
    lea rsi, [s]        ; RSI = pointer to string
    xor ecx, ecx        ; ECX = length

.do_body:
    lodsb               ; AL = *RSI; RSI++
    test al, al         ; AL == 0 ?
    je .done            ; if yes, stop (post-test condition)
    inc ecx             ; len++
    jmp .do_body

.done:
    mov eax, ecx
    and eax, 255
    mov edi, eax
    mov eax, 60         ; SYS_exit
    syscall
