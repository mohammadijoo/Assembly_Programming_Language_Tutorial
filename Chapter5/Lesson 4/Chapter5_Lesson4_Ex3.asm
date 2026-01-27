; Chapter 5 - Lesson 4 (NASM, x86-64 Linux)
; Example 3: Handling "fall-through" and shared cases using a jump table
; Build:
;   nasm -felf64 Chapter5_Lesson4_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3

default rel
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .rodata
m1: db "case 1 or 2: shared handler", 10
l1: equ $-m1
m3: db "case 3: prints then falls through to case 4", 10
l3: equ $-m3
m4: db "case 4: reached by direct jump OR fall-through", 10
l4: equ $-m4
mD: db "default", 10
lD: equ $-mD

section .data
x: dd 3

section .text
_start:
    mov eax, dword [x]
    cmp eax, 4
    ja  .default
    lea rbx, [jt]
    jmp qword [rbx + rax*8]

.case0:
    ; Intentionally treat case 0 as default for demonstration
    jmp .default

.case12:
    lea rsi, [m1]
    mov edx, l1
    jmp .print_exit

.case3:
    lea rsi, [m3]
    mov edx, l3
    call .write
    ; No "break" here: we continue into case4 (fall-through).
.case4:
    lea rsi, [m4]
    mov edx, l4
    jmp .print_exit

.default:
    lea rsi, [mD]
    mov edx, lD
    jmp .print_exit

.write:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

.print_exit:
    call .write
    xor edi, edi
    mov eax, SYS_exit
    syscall

section .rodata
align 8
jt:
    dq .case0, .case12, .case12, .case3, .case4
