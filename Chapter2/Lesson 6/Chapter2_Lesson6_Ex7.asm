\
; Chapter2_Lesson6_Ex7.asm
; NASM include file: constants + shared data.
; In real projects, keep such definitions in a dedicated include directory.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
msg:     db "Definitions came from a NASM include file.", 10
msg_len: equ $ - msg
