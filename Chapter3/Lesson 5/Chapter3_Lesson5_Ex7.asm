; Chapter3_Lesson5_Ex7.asm
; Chapter3_Lesson5_Ex7.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
; Run:
;   ./ex7
;
; Demonstrates: parsing a "network order" (big-endian) header from a byte buffer.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

; Simple header:
;   version  : 1 byte
;   flags    : 1 byte
;   length   : 2 bytes (big-endian)
;   session  : 4 bytes (big-endian)
packet:
  db 0x01           ; version
  db 0xA5           ; flags
  db 0x00, 0x10     ; length = 16 (big-endian)
  db 0xDE, 0xAD, 0xBE, 0xEF ; session = 0xDEADBEEF (big-endian)

msg1 db 'Raw header bytes:',10
msg1_len equ $-msg1

msg2 db 'Parsed length (u16): 0x',0
msg2_len equ $-msg2

msg3 db 'Parsed session (u32): 0x',0
msg3_len equ $-msg3

section .bss
outbuf resb 128

section .text
_start:
  ; Print raw bytes
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  lea rdi, [packet]
  mov esi, 8
  call dump_bytes

  ; Parse length (offset 2), big-endian u16
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  lea rdi, [packet + 2]
  call load_be16_to_eax
  call print_u16_hex

  ; Parse session (offset 4), big-endian u32
  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall

  lea rdi, [packet + 4]
  call load_be32_to_eax
  call print_u32_hex

  mov eax, 60
  xor edi, edi
  syscall

; EAX = big-endian u16 at [RDI]
load_be16_to_eax:
  movzx eax, byte [rdi]
  shl eax, 8
  movzx edx, byte [rdi + 1]
  or eax, edx
  ret

; EAX = big-endian u32 at [RDI]
load_be32_to_eax:
  mov eax, dword [rdi] ; interpreted little-endian
  bswap eax            ; convert to host integer
  ret

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
