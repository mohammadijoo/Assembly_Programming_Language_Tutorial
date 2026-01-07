; Chapter3_Lesson14_Ex1.asm
; Topic: Strings in memory — NUL-terminated vs length-prefixed
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex1.asm -o Chapter3_Lesson14_Ex1.o
;   ld Chapter3_Lesson14_Ex1.o -o Chapter3_Lesson14_Ex1
; Run:
;   ./Chapter3_Lesson14_Ex1

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title   db "Null-terminated vs length-prefixed demo", 10, 0

  label_c1    db "cstr1 length(bytes) = ", 0
  label_p1    db "pstr1 length(bytes) = ", 0
  label_c2    db "cstr2 length(bytes) = ", 0
  label_p2    db "pstr2 length(bytes) = ", 0

  ; NUL-terminated strings (C-style)
  cstr1 db "Hello", 0

  ; cstr2 contains an embedded 0 byte; strlen stops at the first 0.
  ; Memory bytes: 41 00 42 00 (ASCII 'A', 0, 'B', 0)
  cstr2 db "A", 0, "B", 0

  ; 8-bit length-prefixed strings (Pascal-style): [len][bytes...]
  pstr1 db 5, "Hello"

  ; pstr2 can contain 0 bytes in the payload, because its length is explicit.
  ; Memory bytes: 03 41 00 42 (len=3, 'A', 0, 'B')
  pstr2 db 3, "A", 0, "B"

  nl    db 10, 0

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; cstr1 length
  lea rdi, [label_c1]
  call print_cstr
  lea rdi, [cstr1]
  call strlen_nt
  mov rdi, rax
  call print_u64_dec
  call print_nl

  ; pstr1 length
  lea rdi, [label_p1]
  call print_cstr
  lea rdi, [pstr1]
  call pstr8_len
  mov rdi, rax
  call print_u64_dec
  call print_nl

  ; cstr2 length (stops at embedded 0)
  lea rdi, [label_c2]
  call print_cstr
  lea rdi, [cstr2]
  call strlen_nt
  mov rdi, rax
  call print_u64_dec
  call print_nl

  ; pstr2 length (counts embedded 0)
  lea rdi, [label_p2]
  call print_cstr
  lea rdi, [pstr2]
  call pstr8_len
  mov rdi, rax
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; strlen_nt: length of a NUL-terminated string
; in : rdi = pointer to bytes ending with 0
; out: rax = length in bytes (excluding 0)
; --------------------------------------------
strlen_nt:
  xor eax, eax
.len_loop:
  cmp byte [rdi+rax], 0
  je .done
  inc rax
  jmp .len_loop
.done:
  ret

; --------------------------------------------
; pstr8_len: length of an 8-bit length-prefixed string
; in : rdi points at length byte
; out: rax = length in bytes
; --------------------------------------------
pstr8_len:
  movzx eax, byte [rdi]
  ret

; --------------------------------------------
; print helpers (Linux x86-64 syscalls)
; NOTE: syscall clobbers RCX and R11.
; --------------------------------------------
print_cstr:
  ; write(STDOUT, rdi, strlen_nt(rdi))
  push rdi
  call strlen_nt
  mov rdx, rax
  pop rsi               ; rsi = ptr
  mov eax, SYS_write
  mov edi, STDOUT
  syscall
  ret

print_nl:
  lea rdi, [nl]
  jmp print_cstr

print_u64_dec:
  ; print unsigned integer in RDI
  lea rsi, [decbuf+31]
  mov byte [rsi], 0
  mov rax, rdi
  cmp rax, 0
  jne .conv
  mov byte [rsi-1], '0'
  lea rdi, [rsi-1]
  jmp print_cstr
.conv:
  mov rcx, 10
.loop:
  xor rdx, rdx
  div rcx               ; RAX = RAX/10, RDX = remainder
  add dl, '0'
  dec rsi
  mov [rsi], dl
  test rax, rax
  jne .loop
  mov rdi, rsi
  call print_cstr
  ret
