; Chapter7_Lesson5_Ex6.asm
; Locality demonstration: row-major vs column-major traversal (NASM, x86-64, Linux).
; Assumes a row-major 2D array of 32-bit ints: A[row][col].
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex6.asm && ld -o ex6 Chapter7_Lesson5_Ex6.o

BITS 64
default rel

%define SYS_exit 60

%define ROWS 128
%define COLS 128

section .bss
align 64
A: resd ROWS * COLS

section .text
global _start

; ----------------------------------------
; u64 sum_row_major(int* base)
;   rdi=base
; returns rax=sum
; ----------------------------------------
sum_row_major:
  xor eax, eax
  xor r8d, r8d              ; row
.row_loop:
  xor r9d, r9d              ; col
.col_loop:
  ; idx = row*COLS + col
  mov edx, r8d
  imul edx, COLS
  add edx, r9d
  add eax, [rdi + rdx*4]
  inc r9d
  cmp r9d, COLS
  jb .col_loop
  inc r8d
  cmp r8d, ROWS
  jb .row_loop
  movzx rax, eax
  ret

; ----------------------------------------
; u64 sum_col_major(int* base)
;   rdi=base
; returns rax=sum
; ----------------------------------------
sum_col_major:
  xor eax, eax
  xor r9d, r9d              ; col
.col_loop2:
  xor r8d, r8d              ; row
.row_loop2:
  ; idx = row*COLS + col
  mov edx, r8d
  imul edx, COLS
  add edx, r9d
  add eax, [rdi + rdx*4]
  inc r8d
  cmp r8d, ROWS
  jb .row_loop2
  inc r9d
  cmp r9d, COLS
  jb .col_loop2
  movzx rax, eax
  ret

_start:
  ; Initialize A with a simple pattern so the loops do real loads
  lea rdi, [A]
  xor ecx, ecx
.init:
  mov [rdi + rcx*4], ecx
  inc ecx
  cmp ecx, ROWS*COLS
  jb .init

  ; Row-major sum (cache-friendly)
  lea rdi, [A]
  call sum_row_major

  ; Column-major sum (more cache/TLB stress for large matrices)
  lea rdi, [A]
  call sum_col_major

  mov eax, SYS_exit
  xor edi, edi
  syscall
