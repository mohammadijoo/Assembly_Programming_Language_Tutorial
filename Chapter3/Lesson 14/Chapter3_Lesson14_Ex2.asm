; Chapter3_Lesson14_Ex2.asm
; Topic: Two implementations of strlen — scalar loop vs REPNE SCASB
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex2.asm -o Chapter3_Lesson14_Ex2.o
;   ld Chapter3_Lesson14_Ex2.o -o Chapter3_Lesson14_Ex2

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title  db "strlen implementations: loop vs repne scasb", 10, 0
  label_loop db "strlen_loop  = ", 0
  label_scas db "strlen_scasb = ", 0
  nl         db 10, 0

  ; NOTE: the trailing 0 is the terminator, not part of the payload.
  s db "microarchitecture matters (sometimes).", 0

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  lea rdi, [label_loop]
  call print_cstr
  lea rdi, [s]
  call strlen_loop
  mov rdi, rax
  call print_u64_dec
  call print_nl

  lea rdi, [label_scas]
  call print_cstr
  lea rdi, [s]
  call strlen_scasb
  mov rdi, rax
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; strlen_loop: byte-by-byte scalar loop
; in : rdi = cstr
; out: rax = length
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

; --------------------------------------------
; strlen_scasb: uses REPNE SCASB string instruction
; in : rdi = cstr
; out: rax = length
;
; Key semantics:
;   SCASB compares AL with byte [RDI], then increments RDI if DF=0.
;   REPNE repeats while ZF=0 and RCX != 0.
; --------------------------------------------
strlen_scasb:
  push rdi
  cld                  ; DF=0 so RDI increments
  mov rcx, -1          ; effectively "infinite" count
  xor eax, eax         ; AL=0, searching for terminator
  repne scasb
  ; RCX started at -1 and ran (len+1) iterations (including the 0 byte):
  ;   rcx_end = -1 - (len+1) = -len-2
  ; Transform to length:
  mov rax, rcx
  not rax              ; len+1
  dec rax              ; len
  pop rdi
  ret

; --------------------------------------------
; print helpers
; --------------------------------------------
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
