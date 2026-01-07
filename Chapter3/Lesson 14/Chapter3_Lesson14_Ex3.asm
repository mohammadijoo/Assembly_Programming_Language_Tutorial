; Chapter3_Lesson14_Ex3.asm
; Topic: 16-bit length-prefixed strings + conversion to NUL-terminated
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex3.asm -o Chapter3_Lesson14_Ex3.o
;   ld Chapter3_Lesson14_Ex3.o -o Chapter3_Lesson14_Ex3

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title  db "pstr16 (u16 length prefix) to cstr conversion", 10, 0
  label_in   db "pstr16 length(bytes) = ", 0
  label_out  db "converted cstr       = ", 0
  label_tr   db "truncated? (1/0)     = ", 0
  nl         db 10, 0

  ; Layout: [u16 len][payload bytes...]
  ; Little-endian length means DW 5 becomes bytes 05 00.
  pstr16 dw 11
        db "Hello", 0, "World"   ; payload includes a 0 byte

SECTION .bss
  outbuf resb 16                 ; intentionally small to demonstrate truncation
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; Print length from prefix
  lea rdi, [label_in]
  call print_cstr
  lea rdi, [pstr16]
  call pstr16_len
  mov rdi, rax
  call print_u64_dec
  call print_nl

  ; Convert to cstr into outbuf
  lea rdi, [pstr16]              ; src
  lea rsi, [outbuf]              ; dst
  mov edx, 16                    ; dst capacity in bytes
  call pstr16_to_cstr            ; rax=bytes copied, r8d=truncated flag

  ; Print converted output as cstr (will stop at embedded 0 in payload)
  lea rdi, [label_out]
  call print_cstr
  lea rdi, [outbuf]
  call print_cstr
  call print_nl

  ; Print truncation flag
  lea rdi, [label_tr]
  call print_cstr
  movzx rdi, r8b
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; pstr16_len
; in : rdi = pstr16 base
; out: rax = length (0..65535)
; --------------------------------------------
pstr16_len:
  movzx eax, word [rdi]
  ret

; --------------------------------------------
; pstr16_to_cstr
; Converts [u16 len][bytes...] to a NUL-terminated string in dst.
; This is a byte copy: it does not validate UTF-8 and does not stop on 0 bytes.
;
; in :
;   rdi = src pstr16 base
;   rsi = dst buffer
;   edx = dst capacity (bytes)
; out:
;   rax = bytes copied (excluding terminating 0)
;   r8b = 1 if truncated, else 0
; --------------------------------------------
pstr16_to_cstr:
  push rbx
  xor r8d, r8d                   ; truncated flag = 0

  movzx ebx, word [rdi]          ; EBX = src_len
  lea rdi, [rdi+2]               ; RDI = src payload pointer

  ; Need space for trailing 0
  cmp edx, 1
  ja .cap_ok
  ; capacity is 0 or 1: can only write terminator (if possible)
  mov byte [rsi], 0
  xor eax, eax
  mov r8b, 1
  pop rbx
  ret

.cap_ok:
  mov ecx, edx
  dec ecx                         ; max payload bytes we can copy
  cmp ebx, ecx
  jbe .len_ok
  mov ebx, ecx
  mov r8b, 1                       ; truncated
.len_ok:
  ; Copy EBX bytes from src payload (RDI) to dst (RSI)
  mov ecx, ebx
  cld
  rep movsb                        ; uses RDI/RSI/RCX

  ; Write terminator
  mov byte [rsi], 0

  mov eax, ebx
  pop rbx
  ret

; --------------------------------------------
; print helpers (uses strlen_loop)
; --------------------------------------------
strlen_loop:
  xor eax, eax
.loop:
  cmp byte [rdi+rax], 0
  je .done
  inc rax
  jmp .loop
.done:
  ret

print_cstr:
  push rdi
  call strlen_loop
  mov rdx, rax
  pop rsi
  mov eax, SYS_write
  mov edi, STDOUT
  syscall
  ret

print_nl:
  lea rdi, [nl]
  jmp print_cstr

print_u64_dec:
  lea rsi, [decbuf+31]
  mov byte [rsi], 0
  mov rax, rdi
  test rax, rax
  jne .conv
  mov byte [rsi-1], '0'
  lea rdi, [rsi-1]
  jmp print_cstr
.conv:
  mov rcx, 10
.loop:
  xor rdx, rdx
  div rcx
  add dl, '0'
  dec rsi
  mov [rsi], dl
  test rax, rax
  jne .loop
  mov rdi, rsi
  call print_cstr
  ret
