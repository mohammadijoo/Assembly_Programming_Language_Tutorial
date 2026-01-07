; Chapter3_Lesson5_Ex9.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
; Run:
;   ./ex9
;
; Demonstrates: a small "header-like" macro pack for endian loads/stores (extractable to an .inc),
; and shows their use on a buffer.

bits 64
default rel
global _start

%macro BSWAP16 1
  ; Swap bytes in the low 16 bits of %1 (works on reg16)
  rol %1, 8
%endmacro

%macro LOAD_BE16 3
  ; %1 = destination register (32/64)
  ; %2 = memory base (register or symbol)
  ; %3 = scratch register (32/64)
  movzx %1, byte [%2]
  shl %1, 8
  movzx %3, byte [%2 + 1]
  or %1, %3
%endmacro

%macro LOAD_BE32 2
  ; %1 = destination reg32
  ; %2 = memory base
  mov %1, dword [%2]
  bswap %1
%endmacro

%macro STORE_BE32 2
  ; Store reg32 %2 to memory %1 in big-endian byte order
  mov eax, %2
  bswap eax
  mov dword [%1], eax
%endmacro

section .data
hex db '0123456789ABCDEF'

buf db 0xCA, 0xFE, 0xBA, 0xBE,  0x00, 0x2A
; Layout:
;   [0..3] = magic (big-endian) 0xCAFEBABE
;   [4..5] = code  (big-endian) 0x002A (42)

msg1 db 'Raw bytes:',10
msg1_len equ $-msg1

msg2 db 'magic (u32): 0x',0
msg2_len equ $-msg2

msg3 db 'code (u16):  0x',0
msg3_len equ $-msg3

msg4 db 'Rewrite magic as 0x11223344 in big-endian; new bytes:',10
msg4_len equ $-msg4

section .bss
outbuf  resb 128
scratch resd 1

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

  ; Parse magic (u32 big-endian) using BSWAP
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall
  LOAD_BE32 eax, buf
  call print_u32_hex

  ; Parse code (u16 big-endian) using shift/OR macro
  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall
  LOAD_BE16 r8d, buf + 4, r9d
  mov eax, r8d
  call print_u16_hex

  ; Store new magic in big-endian
  mov eax, 0x11223344
  STORE_BE32 buf, eax

  mov eax, 1
  mov edi, 1
  lea rsi, [msg4]
  mov edx, msg4_len
  syscall
  lea rdi, [buf]
  mov esi, 6
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

; print_u16_hex: prints 4 hex digits from AX (in EAX) then newline
print_u16_hex:
  mov r9d, eax
  lea rdi, [outbuf]
  mov edx, 12
.loop16:
  mov eax, r9d
  mov ecx, edx
  shr eax, cl
  and eax, 0x0F
  mov al, [hex + rax]
  mov [rdi], al
  inc rdi
  sub edx, 4
  jns .loop16
  mov byte [rdi], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 5
  syscall
  ret

; print_u32_hex: prints 8 hex digits from EAX then newline
print_u32_hex:
  mov r9d, eax
  lea rdi, [outbuf]
  mov edx, 28
.loop32:
  mov eax, r9d
  mov ecx, edx
  shr eax, cl
  and eax, 0x0F
  mov al, [hex + rax]
  mov [rdi], al
  inc rdi
  sub edx, 4
  jns .loop32
  mov byte [rdi], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 9
  syscall
  ret
