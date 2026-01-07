bits 64
default rel

; Demonstrates row-major 2D indexing with LEA:
; element address for qword mat[ROWS][COLS]:
;   &mat[r][c] = base + ((r*COLS + c) * 8)
;
; Here COLS = 5.

global _start

%define COLS 5

section .data
; 3x5 matrix (ROWS=3, COLS=5), values 1..15
mat dq  1,  2,  3,  4,  5
    dq  6,  7,  8,  9, 10
    dq 11, 12, 13, 14, 15

section .text
_start:
    mov edi, 2              ; r = 2 (0-based)
    mov esi, 3              ; c = 3

    ; t = r*5 = r*4 + r
    lea eax, [edi + edi*4]  ; eax = r*5 (32-bit is enough here)
    add eax, esi            ; eax = r*5 + c

    ; rbx = &mat[0][0] + t*8
    lea rbx, [rel mat + rax*8]
    mov rax, [rbx]          ; rax = mat[2][3] = 14

    mov eax, 60
    mov edi, 14
    syscall
