; Chapter3_Lesson5_Ex2.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2
;
; Demonstrates: (1) how MOV interprets multi-byte memory as little-endian,
; (2) how to decode big-endian bytes using BSWAP or shifts/OR.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

be_bytes db 0x12, 0x34, 0x56, 0x78
le_bytes db 0x78, 0x56, 0x34, 0x12

msg0 db 'Source bytes (big-endian encoding of 0x12345678):',10
msg0_len equ $-msg0

msg1 db 'MOV eax, [be_bytes] yields (interpreted little-endian): 0x',0
msg1_len equ $-msg1

msg2 db 'BSWAP eax after MOV yields (converted to host integer):   0x',0
msg2_len equ $-msg2

msg3 db 'Manual shift/OR decode yields:                            0x',0
msg3_len equ $-msg3

msg4 db 'MOV eax, [le_bytes] yields (already little-endian):       0x',0
msg4_len equ $-msg4

nl db 10
nl_len equ $-nl

section .bss
outbuf resb 32
bytebuf resb 64

section .text
_start:
  ; Print source bytes
  mov eax, 1
  mov edi, 1
  lea rsi, [msg0]
  mov edx, msg0_len
  syscall
  lea rdi, [be_bytes]
  mov esi, 4
  call dump_bytes

  ; MOV from big-endian byte sequence: eax becomes byte-reversed
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  mov eax, dword [be_bytes]
  call print_u32_hex

  ; Convert with BSWAP
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  mov eax, dword [be_bytes]
  bswap eax
  call print_u32_hex

  ; Manual shift/OR decode (big-endian bytes -> host integer)
  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall

  xor eax, eax
  movzx eax, byte [be_bytes]
  shl eax, 24
  movzx edx, byte [be_bytes + 1]
  shl edx, 16
  or eax, edx
  movzx edx, byte [be_bytes + 2]
  shl edx, 8
  or eax, edx
  movzx edx, byte [be_bytes + 3]
  or eax, edx
  call print_u32_hex

  ; MOV from little-endian byte sequence: eax is "human order" 0x12345678
  mov eax, 1
  mov edi, 1
  lea rsi, [msg4]
  mov edx, msg4_len
  syscall

  mov eax, dword [le_bytes]
  call print_u32_hex

  ; Exit(0)
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
  mov [bytebuf + rcx*3], al
  mov bl, [hex + rbx]
  mov [bytebuf + rcx*3 + 1], bl
  mov byte [bytebuf + rcx*3 + 2], ' '
  inc rcx
  jmp .loop
.done:
  mov byte [bytebuf + r8*3], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [bytebuf]
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
  mov edx, 9
  syscall
  ret
