; Chapter3_Lesson5_Ex4.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
; Run:
;   ./ex4
;
; Demonstrates: byte swapping 16-bit values without BSWAP (which exists for 32/64).
; Methods: XCHG AL,AH and ROL AX,8.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'Start AX = 0x1234, swap bytes using XCHG AL,AH:',10
msg1_len equ $-msg1

msg2 db 'Start AX = 0x1234, swap bytes using ROL AX,8:',10
msg2_len equ $-msg2

msg3 db 'Note: for 16-bit, BSWAP is not available; use rotate or XCHG.',10
msg3_len equ $-msg3

section .bss
outbuf resb 32

section .text
_start:
  ; XCHG-based swap
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  mov ax, 0x1234
  xchg al, ah
  movzx eax, ax
  call print_u16_hex

  ; ROL-based swap
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  mov ax, 0x1234
  rol ax, 8
  movzx eax, ax
  call print_u16_hex

  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall

  mov eax, 60
  xor edi, edi
  syscall

; print_u16_hex: prints 4 hex digits from AX (in EAX) then newline
print_u16_hex:
  mov r9d, eax
  lea rdi, [outbuf]
  mov edx, 12
.loop:
  mov eax, r9d
  mov ecx, edx
  shr eax, cl
  and eax, 0x0F
  mov al, [hex + rax]
  mov [rdi], al
  inc rdi
  sub edx, 4
  jns .loop
  mov byte [rdi], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 5
  syscall
  ret
