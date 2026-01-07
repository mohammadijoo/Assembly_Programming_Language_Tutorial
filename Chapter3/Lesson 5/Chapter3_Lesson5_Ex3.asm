; Chapter3_Lesson5_Ex3.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
; Run:
;   ./ex3
;
; Demonstrates: byte extraction and the "least significant byte at lowest address"
; rule for little-endian memory layouts on x86.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'Store eax = 0x11223344 into memory, then dump bytes:',10
msg1_len equ $-msg1

msg2 db 'Reading individual bytes [p+0..p+3] yields:',10
msg2_len equ $-msg2

msg3 db 'Interpretation note: [p+0] is least-significant byte on little-endian.',10
msg3_len equ $-msg3

section .bss
buf   resb 4
outbuf resb 64

section .text
_start:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  mov eax, 0x11223344
  mov dword [buf], eax

  lea rdi, [buf]
  mov esi, 4
  call dump_bytes

  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  ; Print each byte as hex on its own line: p+0, p+1, p+2, p+3
  lea rbx, [buf]
  mov ecx, 4
.byte_loop:
  movzx eax, byte [rbx]
  call print_u8_hex
  inc rbx
  loop .byte_loop

  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall

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

; print_u8_hex: prints 2 hex digits from AL then newline
print_u8_hex:
  movzx eax, al
  mov ebx, eax
  shr eax, 4
  and ebx, 0x0F
  mov al, [hex + rax]
  mov [outbuf], al
  mov bl, [hex + rbx]
  mov [outbuf + 1], bl
  mov byte [outbuf + 2], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 3
  syscall
  ret
