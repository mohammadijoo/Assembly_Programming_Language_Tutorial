; Chapter3_Lesson5_Ex1.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'dd 0x12345678 stored in memory (x86 little-endian):',10
msg1_len equ $-msg1

msg2 db 'Explicit big-endian byte sequence for 0x12345678:',10
msg2_len equ $-msg2

le_val dd 0x12345678
be_val db 0x12, 0x34, 0x56, 0x78

section .bss
outbuf resb 128

section .text
_start:
  ; Print little-endian dword bytes as they appear in memory
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  lea rdi, [le_val]
  mov esi, 4
  call dump_bytes

  ; Print explicit big-endian byte sequence
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  lea rdi, [be_val]
  mov esi, 4
  call dump_bytes

  ; Exit(0)
  mov eax, 60
  xor edi, edi
  syscall

; dump_bytes(ptr=rdi, len=rsi): prints "XX XX ...\n"
dump_bytes:
  mov r8, rsi          ; r8 = len
  xor rcx, rcx         ; i = 0
.loop:
  cmp rcx, r8
  jae .done

  movzx eax, byte [rdi + rcx] ; byte value
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
  lea rdx, [rdx + rdx*2] ; len*3
  add rdx, 1             ; + newline
  syscall
  ret
