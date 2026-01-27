; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 9: Two-stage switch via classification table (byte -> class -> jump table)
; Classes:
;   0 = whitespace, 1 = digit, 2 = letter, 3 = other
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
mWS: db "class whitespace", 10
lWS: equ $-mWS
mDG: db "class digit", 10
lDG: equ $-mDG
mAZ: db "class letter", 10
lAZ: equ $-mAZ
mOT: db "class other", 10
lOT: equ $-mOT

section .data
ch: db '7'

section .text
_start:
    movzx eax, byte [ch]        ; byte value 0..255

    lea rbx, [class_tbl]
    movzx eax, byte [rbx + rax] ; class id 0..3

    lea rbx, [jt]
    jmp qword [rbx + rax*8]

.ws:
    lea rsi, [mWS]
    mov edx, lWS
    jmp .print_exit
.dg:
    lea rsi, [mDG]
    mov edx, lDG
    jmp .print_exit
.az:
    lea rsi, [mAZ]
    mov edx, lAZ
    jmp .print_exit
.ot:
    lea rsi, [mOT]
    mov edx, lOT
    jmp .print_exit

.print_exit:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    xor edi, edi
    mov eax, SYS_exit
    syscall

section .rodata
align 8
jt:
    dq .ws, .dg, .az, .ot

; 256-byte classification table generated at assembly time.
; Default=3 (other), with rules for whitespace, digits, letters.
align 16
class_tbl:
%assign b 0
%rep 256
    %if (b == 9) || (b == 10) || (b == 13) || (b == 32)
        db 0
    %elif (b >= '0') && (b <= '9')
        db 1
    %elif ((b >= 'A') && (b <= 'Z')) || ((b >= 'a') && (b <= 'z'))
        db 2
    %else
        db 3
    %endif
%assign b b+1
%endrep
