; Chapter3_Lesson5_Ex6.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
; Run:
;   ./ex6
;
; Demonstrates: unaligned loads and how endianness interacts with a shifted address.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'Bytes in buffer (starting at buf):',10
msg1_len equ $-msg1

msg2 db 'Load dword from buf+1 using MOV eax, [buf+1] gives 0x',0
msg2_len equ $-msg2

buf db 0x00, 0x11, 0x22, 0x33, 0x44, 0x55

section .bss
outbuf resb 128

section .text
_start:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  lea rdi, [buf]
  mov esi, 6
  call dump_bytes

  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  mov eax, dword [buf + 1] ; reads 11 22 33 44 as little-endian integer 0x44332211
  call print_u32_hex

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

; print_u32_hex: prints 8 hex digits from EAX then newline
print_u32_hex:
  mov r9d, eax
  lea rdi, [outbuf]
  mov edx, 28
.loop2:
  mov eax, r9d
  mov ecx, edx
  shr eax, cl
  and eax, 0x0F
  mov al, [hex + rax]
  mov [rdi], al
  inc rdi
  sub edx, 4
  jns .loop2
  mov byte [rdi], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 9
  syscall
  ret
