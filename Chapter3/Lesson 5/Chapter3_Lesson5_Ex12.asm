; Chapter3_Lesson5_Ex12.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
; Run:
;   ./ex12
;
; Exercise solution:
; Parse a TLV stream with layout:
;   type: 1 byte
;   len : 2 bytes (big-endian)
;   val : len bytes
;
; Task: Sum all bytes in VALUE fields where type == 0x42, with strict bounds checks.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

; TLV stream:
;   0x01, len=3, val = [10 20 30]
;   0x42, len=4, val = [01 02 03 04]
;   0x42, len=2, val = [AA BB]
; Expected sum for type 0x42: (1+2+3+4) + (0xAA+0xBB) = 10 + 0x165 = 0x16F
stream:
  db 0x01,  0x00, 0x03,  0x10, 0x20, 0x30
  db 0x42,  0x00, 0x04,  0x01, 0x02, 0x03, 0x04
  db 0x42,  0x00, 0x02,  0xAA, 0xBB

stream_len equ $-stream

msg1 db 'TLV parse complete. Sum(type=0x42) = 0x',0
msg1_len equ $-msg1

msg_err db 'Parse error: malformed TLV (bounds violation)',10
msg_err_len equ $-msg_err

section .bss
outbuf resb 64

section .text
_start:
  lea rsi, [stream]            ; cursor
  lea rdi, [stream + stream_len] ; end
  xor rbx, rbx                 ; sum in RBX (64-bit)

.parse_loop:
  ; Need at least 3 bytes for (type + len16)
  mov rax, rdi
  sub rax, rsi
  cmp rax, 3
  jb .done_ok

  ; Read type
  movzx eax, byte [rsi]
  mov r8d, eax                 ; r8d = type
  inc rsi

  ; Read len (big-endian u16)
  ; Bounds check: we already know at least 2 bytes remain
  movzx eax, byte [rsi]
  shl eax, 8
  movzx edx, byte [rsi + 1]
  or eax, edx
  mov r9d, eax                 ; r9d = len
  add rsi, 2

  ; Check that value fits in remaining buffer: (end - cursor) >= len
  mov rax, rdi
  sub rax, rsi
  cmp rax, r9
  jb .err

  ; If type == 0x42, sum len bytes
  cmp r8b, 0x42
  jne .skip_value

  xor rcx, rcx
.sum_loop:
  cmp rcx, r9
  jae .after_sum
  movzx eax, byte [rsi + rcx]
  add rbx, rax
  inc rcx
  jmp .sum_loop
.after_sum:

.skip_value:
  add rsi, r9
  jmp .parse_loop

.err:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg_err]
  mov edx, msg_err_len
  syscall
  mov eax, 60
  mov edi, 1
  syscall

.done_ok:
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  mov rax, rbx
  call print_u64_hex

  mov eax, 60
  xor edi, edi
  syscall

; print_u64_hex: prints 16 hex digits from RAX then newline
print_u64_hex:
  mov r9, rax
  lea rdi, [outbuf]
  mov edx, 60
.loop:
  mov rax, r9
  mov ecx, edx
  shr rax, cl
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
  mov edx, 17
  syscall
  ret
