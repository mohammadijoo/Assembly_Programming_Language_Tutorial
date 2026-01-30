; Chapter7_Lesson5_Ex7.asm
; Pointer compression: store 32-bit offsets relative to a base (NASM, x86-64, Linux).
; Useful when the referenced region is &lt;= 4GiB and pointer-heavy structures dominate memory.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex7.asm && ld -o ex7 Chapter7_Lesson5_Ex7.o

BITS 64
default rel

%define SYS_exit 60
%define COUNT 16
%define ELEM_SIZE 24

section .bss
align 16
region:  resb ELEM_SIZE * COUNT
offsets: resd COUNT

section .text
global _start

; -------------------------------------------
; rax = decode(base, off32)
;   rdi=base, esi=off32
;   returns rax = base + zero_extend(off32)
; -------------------------------------------
decode:
  mov eax, esi
  add rax, rdi
  ret

; -------------------------------------------
; esi = encode(base, ptr)
;   rdi=base, rsi=ptr
;   returns esi = (ptr - base) (low 32 bits)
; precondition: ptr in [base, base+4GiB)
; -------------------------------------------
encode:
  mov rax, rsi
  sub rax, rdi
  mov esi, eax
  ret

_start:
  lea rbx, [region]            ; base

  ; Encode pointers to elements into 32-bit offsets
  xor ecx, ecx
.enc_loop:
  lea rsi, [rbx + rcx*ELEM_SIZE]
  mov rdi, rbx
  call encode
  mov [offsets + rcx*4], esi
  inc ecx
  cmp ecx, COUNT
  jb .enc_loop

  ; Decode back and write a value into each element
  xor ecx, ecx
.dec_loop:
  mov esi, [offsets + rcx*4]
  mov rdi, rbx
  call decode                 ; rax = ptr
  mov dword [rax + 8], ecx    ; arbitrary field write
  inc ecx
  cmp ecx, COUNT
  jb .dec_loop

  mov eax, SYS_exit
  xor edi, edi
  syscall
