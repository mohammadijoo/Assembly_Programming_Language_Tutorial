; Chapter7_Lesson5_Ex13.asm
; Exercise Solution: cache-blocked transpose (64x64 bytes) (NASM, x86-64, Linux).
; Blocking reduces cache misses by working on small tiles that fit into L1.
;
; API:
;   void transpose64_block8(u8* dst, const u8* src)
;     rdi=dst, rsi=src
;
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex13.asm && ld -o ex13 Chapter7_Lesson5_Ex13.o

BITS 64
default rel

%define SYS_exit 60

%define N 64
%define B 8

section .bss
align 64
src: resb N*N
dst: resb N*N

section .text
global _start
global transpose64_block8

; dst[r][c] = src[c][r]
transpose64_block8:
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov rbx, rdi      ; dst base
  mov r12, rsi      ; src base

  xor r13d, r13d    ; i = 0..N step B (row block)
.ib:
  xor r14d, r14d    ; j = 0..N step B (col block)
.jb:
  xor r15d, r15d    ; ii = 0..B-1
.ii:
  xor r8d, r8d      ; jj = 0..B-1
.jj:
  ; src index: (i+ii)*N + (j+jj)
  mov eax, r13d
  add eax, r15d
  imul eax, N
  mov edx, r14d
  add edx, r8d
  add eax, edx
  movzx ecx, byte [r12 + rax]

  ; dst index: (j+jj)*N + (i+ii)
  mov eax, r14d
  add eax, r8d
  imul eax, N
  mov edx, r13d
  add edx, r15d
  add eax, edx
  mov [rbx + rax], cl

  inc r8d
  cmp r8d, B
  jb .jj

  inc r15d
  cmp r15d, B
  jb .ii

  add r14d, B
  cmp r14d, N
  jb .jb

  add r13d, B
  cmp r13d, N
  jb .ib

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  ret

_start:
  ; init src with pattern
  lea rdi, [src]
  xor ecx, ecx
.init:
  mov [rdi + rcx], cl
  inc ecx
  cmp ecx, N*N
  jb .init

  lea rdi, [dst]
  lea rsi, [src]
  call transpose64_block8

  mov eax, SYS_exit
  xor edi, edi
  syscall
