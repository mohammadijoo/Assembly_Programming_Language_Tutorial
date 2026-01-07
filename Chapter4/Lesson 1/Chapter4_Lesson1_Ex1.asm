;
; Chapter 4 - Lesson 1 (Arithmetic): Example 1
; Topic: ADD operand forms, size specifiers, and register-width side effects (NASM, x86-64, Linux)
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; exit code is (some_value & 255)
;
; Debug tip:
;   gdb -q ./ex1
;   (gdb) starti
;   (gdb) si / ni and inspect registers, memory, and flags (info registers, x/gx, info reg eflags)

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
xq      dq  10
yq      dq  0xFFFFFFFFFFFFFFFF
xb      db  250
yb      db  10

SECTION .text
_start:
    ; 1) reg + reg
    mov rax, 5
    mov rbx, 7
    add rax, rbx              ; rax = 12

    ; 2) reg + imm
    add rax, 100              ; rax = 112

    ; 3) reg + mem (RIP-relative because DEFAULT REL)
    add rax, [xq]             ; rax = 122

    ; 4) mem + imm (needs explicit size when ambiguous)
    add qword [xq], 3         ; xq becomes 13

    ; 5) byte arithmetic and wrap-around (mod 256)
    mov al, [xb]              ; al = 250
    add al, [yb]              ; al = 250 + 10 = 4, CF=1 (unsigned carry)

    ; 6) Using a 32-bit destination implicitly zero-extends in x86-64
    mov rax, 0x1122334455667788
    add eax, 1                ; eax = 0x55667789, rax becomes 0x0000000055667789

    ; Place an INT3 for inspection after different forms above
    int3

    ; Return an exit status that depends on a few computed bytes.
    ; Linux exit code uses low 8 bits only.
    xor edi, edi
    mov dil, al               ; from the byte add
    add dil, byte [xb]        ; add original 250 (wrap again)
    mov eax, 60
    syscall
