; Chapter7_Lesson5_Ex5.asm
; Bulk memory operations: rep stos/movs and alignment (NASM, x86-64, Linux).
; Practical: fast zeroing and copying can dominate runtime and memory traffic.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex5.asm && ld -o ex5 Chapter7_Lesson5_Ex5.o

BITS 64
default rel

%define SYS_exit 60

section .bss
align 16
bufA: resb 4096
bufB: resb 4096

section .text
global _start

; ------------------------------------------
; void my_memset(void* dst, u8 v, u64 n)
;   rdi=dst, sil=v, rdx=n
; ------------------------------------------
my_memset:
  test rdx, rdx
  jz .done
  ; Expand byte value to 64-bit pattern in RAX
  movzx eax, sil
  mov rcx, 0x0101010101010101
  imul rax, rcx              ; rax = v repeated in all bytes
  mov rcx, rdx
  shr rcx, 3                 ; qword count
  rep stosq
  mov rcx, rdx
  and rcx, 7                 ; remaining bytes
  rep stosb
.done:
  ret

; ------------------------------------------
; void my_memcpy(void* dst, const void* src, u64 n)
;   rdi=dst, rsi=src, rdx=n
; ------------------------------------------
my_memcpy:
  test rdx, rdx
  jz .done
  mov rcx, rdx
  shr rcx, 3                 ; qword count
  rep movsq
  mov rcx, rdx
  and rcx, 7
  rep movsb
.done:
  ret

_start:
  ; Fill bufA with 0xAA, then copy to bufB
  lea rdi, [bufA]
  mov sil, 0xAA
  mov edx, 4096
  call my_memset

  lea rdi, [bufB]
  lea rsi, [bufA]
  mov edx, 4096
  call my_memcpy

  mov eax, SYS_exit
  xor edi, edi
  syscall
