; ex3_main_return.asm
; Build (hosted, uses CRT):
;   nasm -f elf64 ex3_main_return.asm -o ex3_main_return.o
;   gcc -no-pie -o ex3_main_return ex3_main_return.o
; Run:
;   ./ex3_main_return
;   echo $?

BITS 64
section .text
global main

; int main(void) { return 7*6; }
main:
    mov eax, 7
    imul eax, eax, 6
    ret
