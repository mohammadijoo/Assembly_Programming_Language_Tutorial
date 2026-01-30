; Chapter7_Lesson5_Ex2.asm
; Stack scratch buffers + explicit alignment (NASM, x86-64, Linux).
; This pattern avoids heap allocation for temporary work buffers.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex2.asm && ld -o ex2 Chapter7_Lesson5_Ex2.o

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
msg: db "sum = 0x", 0
msg_len: equ $-msg
hex: db "0000000000000000", 10
hex_len: equ $-hex

section .text
global _start

; --------------------------------------
; u64 sum_qwords(const u64* p, u64 n)
;   rdi = p, rsi = n
; returns rax = sum
; --------------------------------------
sum_qwords:
  xor eax, eax
  test rsi, rsi
  jz .done
.loop:
  add rax, [rdi]
  add rdi, 8
  dec rsi
  jnz .loop
.done:
  ret

; --------------------------------------
; void u64_to_hex16(u64 x, char* out16)
;   rdi = x, rsi = out16 (16 chars, no 0-terminator)
; --------------------------------------
u64_to_hex16:
  mov rcx, 16
  lea rdx, [rsi + 15]
.hex_loop:
  mov rax, rdi
  and eax, 0xF
  cmp al, 9
  jbe .digit
  add al, ('a' - 10)
  jmp .store
.digit:
  add al, '0'
.store:
  mov [rdx], al
  shr rdi, 4
  dec rdx
  dec rcx
  jnz .hex_loop
  ret

_start:
  ; Align RSP to 16 bytes (good hygiene before calls / SIMD)
  and rsp, -16

  ; Allocate a 64-byte scratch buffer on stack
  sub rsp, 64
  lea rbx, [rsp]        ; rbx -> scratch
  ; Fill 8 qwords with a simple pattern (no heap, no malloc)
  xor ecx, ecx
.fill:
  mov rax, rcx
  imul rax, rax, 0x1111111111111111
  mov [rbx + rcx*8], rax
  inc rcx
  cmp rcx, 8
  jb .fill

  ; Sum them
  mov rdi, rbx
  mov rsi, 8
  call sum_qwords

  ; Convert to hex string
  lea rsi, [hex]
  mov rdi, rax
  call u64_to_hex16

  ; Print "sum = 0x"
  mov eax, SYS_write
  mov edi, 1
  lea rsi, [msg]
  mov edx, msg_len
  syscall

  ; Print hex digits + newline
  mov eax, SYS_write
  mov edi, 1
  lea rsi, [hex]
  mov edx, hex_len
  syscall

  ; Release stack (optional in _start, but keeps structure clear)
  add rsp, 64

  mov eax, SYS_exit
  xor edi, edi
  syscall
