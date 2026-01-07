; Chapter3_Lesson5_Ex11.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11
;
; Exercise solution:
; Detect MOVBE support via CPUID and use it to load a big-endian u32 efficiently.
; If MOVBE is not supported, fall back to MOV + BSWAP.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

be32 db 0x12, 0x34, 0x56, 0x78

msg1 db 'CPU MOVBE support: ',0
msg1_len equ $-msg1

msg_yes db 'YES',10
msg_yes_len equ $-msg_yes

msg_no db 'NO',10
msg_no_len equ $-msg_no

msg2 db 'Loaded big-endian u32 -> host integer: 0x',0
msg2_len equ $-msg2

section .bss
outbuf resb 64
has_movbe resb 1

section .text
_start:
  ; CPUID leaf 1: ECX bit 22 indicates MOVBE
  mov eax, 1
  cpuid
  bt ecx, 22
  setc byte [has_movbe]

  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  cmp byte [has_movbe], 0
  je .no
.yes:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg_yes]
  mov edx, msg_yes_len
  syscall
  jmp .load
.no:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg_no]
  mov edx, msg_no_len
  syscall

.load:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  cmp byte [has_movbe], 0
  je .fallback

  ; MOVBE loads big-endian memory into little-endian register value
  movbe eax, dword [be32]
  call print_u32_hex
  jmp .exit

.fallback:
  mov eax, dword [be32]
  bswap eax
  call print_u32_hex

.exit:
  mov eax, 60
  xor edi, edi
  syscall

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
