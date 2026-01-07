; Chapter3_Lesson5_Ex8.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
; Run:
;   ./ex8
;
; Demonstrates: runtime endianness detection by storing a known word and inspecting the first byte.

bits 64
default rel
global _start

section .data
msg_le db 'Detected host endianness: little-endian',10
msg_le_len equ $-msg_le

msg_be db 'Detected host endianness: big-endian',10
msg_be_len equ $-msg_be

section .bss
tmp resd 1

section .text
_start:
  mov eax, 0x01020304
  mov dword [tmp], eax

  cmp byte [tmp], 0x04
  je .little
  jmp .big

.little:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg_le]
  mov edx, msg_le_len
  syscall
  jmp .exit

.big:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg_be]
  mov edx, msg_be_len
  syscall

.exit:
  mov eax, 60
  xor edi, edi
  syscall
