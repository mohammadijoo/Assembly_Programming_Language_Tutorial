; Chapter3_Lesson5_Ex5.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
; Run:
;   ./ex5
;
; Demonstrates: storing integers to memory in big-endian order on a little-endian CPU.
; Two methods:
;   (A) BSWAP + MOV
;   (B) Manual byte stores

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'Method A (BSWAP + MOV) storing 0x0102030405060708 as big-endian bytes:',10
msg1_len equ $-msg1

msg2 db 'Method B (manual byte stores) storing the same value:',10
msg2_len equ $-msg2

value dq 0x0102030405060708

section .bss
dstA  resb 8
dstB  resb 8
outbuf resb 128

section .text
_start:
  ; Method A: bswap then store
  mov rax, [value]
  bswap rax
  mov [dstA], rax

  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall
  lea rdi, [dstA]
  mov esi, 8
  call dump_bytes

  ; Method B: manual stores from MSB to LSB
  mov rax, [value]
  lea rdi, [dstB]

  mov rcx, 8
  mov rdx, 56
.manual_loop:
  mov r8, rax
  mov cl, dl
  shr r8, cl
  and r8, 0xFF
  mov [rdi], r8b
  inc rdi
  sub rdx, 8
  jns .manual_loop

  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall
  lea rdi, [dstB]
  mov esi, 8
  call dump_bytes

  mov eax, 60
  xor edi, edi
  syscall

; dump_bytes(ptr=rdi, len=rsi): prints "XX XX ...\n"
dump_bytes:
  mov r8, rsi
  xor rcx, rcx
.loop:
  cmp rcx, r8
  jae .done
  movzx eax, byte [rdi + rcx]
  mov ebx, eax
  shr eax, 4
  and ebx, 0x0F
  mov al, [hex + rax]
  mov [outbuf + rcx*3], al
  mov bl, [hex + rbx]
  mov [outbuf + rcx*3 + 1], bl
  mov byte [outbuf + rcx*3 + 2], ' '
  inc rcx
  jmp .loop
.done:
  mov byte [outbuf + r8*3], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov rdx, r8
  lea rdx, [rdx + rdx*2]
  add rdx, 1
  syscall
  ret
