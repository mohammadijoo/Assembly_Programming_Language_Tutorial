; Chapter3_Lesson5_Ex10.asm
; NASM (Linux x86-64)
; Build:
;   nasm -felf64 Chapter3_Lesson5_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10
;
; Exercise solution:
; Implement a generic byte-swap routine swap_any(rax=value, cl=size) where size in {1,2,4,8}.
; Return swapped value in RAX. Use a jump table to select implementation.

bits 64
default rel
global _start

section .data
hex db '0123456789ABCDEF'

msg1 db 'swap_any(0x1122334455667788, size=8) -> 0x',0
msg1_len equ $-msg1

msg2 db 'swap_any(0xA1B2C3D4, size=4) -> 0x',0
msg2_len equ $-msg2

msg3 db 'swap_any(0x1234, size=2) -> 0x',0
msg3_len equ $-msg3

msg4 db 'swap_any(0x7F, size=1) -> 0x',0
msg4_len equ $-msg4

section .bss
outbuf resb 64

section .text
_start:
  ; 8 bytes
  mov eax, 1
  mov edi, 1
  lea rsi, [msg1]
  mov edx, msg1_len
  syscall

  mov rax, 0x1122334455667788
  mov cl, 8
  call swap_any
  call print_u64_hex

  ; 4 bytes
  mov eax, 1
  mov edi, 1
  lea rsi, [msg2]
  mov edx, msg2_len
  syscall

  mov eax, 0xA1B2C3D4
  mov cl, 4
  call swap_any
  call print_u32_hex_from_rax

  ; 2 bytes
  mov eax, 1
  mov edi, 1
  lea rsi, [msg3]
  mov edx, msg3_len
  syscall

  mov ax, 0x1234
  movzx eax, ax
  mov cl, 2
  call swap_any
  call print_u16_hex_from_rax

  ; 1 byte
  mov eax, 1
  mov edi, 1
  lea rsi, [msg4]
  mov edx, msg4_len
  syscall

  mov al, 0x7F
  movzx eax, al
  mov cl, 1
  call swap_any
  call print_u8_hex_from_rax

  mov eax, 60
  xor edi, edi
  syscall

; swap_any(rax=value, cl=size) -> rax=swapped
swap_any:
  ; Map size to an index:
  ;   1 -> 0, 2 -> 1, 4 -> 2, 8 -> 3
  movzx edx, cl
  cmp edx, 1
  je .idx0
  cmp edx, 2
  je .idx1
  cmp edx, 4
  je .idx2
  cmp edx, 8
  je .idx3
  ; unsupported size: return unchanged
  ret

.idx0:
  lea r11, [rel jt]
  jmp qword [r11 + 0*8]
.idx1:
  lea r11, [rel jt]
  jmp qword [r11 + 1*8]
.idx2:
  lea r11, [rel jt]
  jmp qword [r11 + 2*8]
.idx3:
  lea r11, [rel jt]
  jmp qword [r11 + 3*8]

jt:
  dq .case1
  dq .case2
  dq .case4
  dq .case8

.case1:
  ; no-op
  ret
.case2:
  ; swap low 16 bits: rol ax,8
  rol ax, 8
  movzx eax, ax
  ret
.case4:
  ; swap low 32 bits: bswap eax
  bswap eax
  movzx rax, eax
  ret
.case8:
  bswap rax
  ret

; Hex print helpers
print_u64_hex:
  mov r9, rax
  lea rdi, [outbuf]
  mov edx, 60            ; highest nibble shift for 64-bit (15*4)
.loop64:
  mov rax, r9
  mov ecx, edx
  shr rax, cl
  and eax, 0x0F
  mov al, [hex + rax]
  mov [rdi], al
  inc rdi
  sub edx, 4
  jns .loop64
  mov byte [rdi], 10
  mov eax, 1
  mov edi, 1
  lea rsi, [outbuf]
  mov edx, 17
  syscall
  ret

print_u32_hex_from_rax:
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

print_u16_hex_from_rax:
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

print_u8_hex_from_rax:
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
