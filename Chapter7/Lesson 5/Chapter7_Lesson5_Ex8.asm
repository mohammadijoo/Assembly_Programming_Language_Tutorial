; Chapter7_Lesson5_Ex8.asm
; Tagged pointers and bit-packing (NASM, x86-64, Linux).
; If objects are 8-byte aligned, the low 3 bits of a pointer are always 0 and can store flags.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex8.asm && ld -o ex8 Chapter7_Lesson5_Ex8.o

BITS 64
default rel

%define SYS_exit 60

%define TAG_MASK 0x7

section .bss
align 8
obj: resb 64

section .text
global _start

; ------------------------------------------
; rax = tag_ptr(ptr, tag)  (tag in 0..7)
;   rdi=ptr, rsi=tag
; ------------------------------------------
tag_ptr:
  mov rax, rdi
  and rsi, TAG_MASK
  or  rax, rsi
  ret

; ------------------------------------------
; rax = untag_ptr(tagged_ptr)
;   rdi=tagged_ptr
; ------------------------------------------
untag_ptr:
  mov rax, rdi
  and rax, ~TAG_MASK
  ret

; ------------------------------------------
; eax = get_tag(tagged_ptr)
;   rdi=tagged_ptr
; ------------------------------------------
get_tag:
  mov eax, edi
  and eax, TAG_MASK
  ret

_start:
  lea rdi, [obj]
  mov esi, 5
  call tag_ptr             ; rax = tagged pointer
  mov rbx, rax

  mov rdi, rbx
  call get_tag             ; eax = 5

  mov rdi, rbx
  call untag_ptr           ; rax = original pointer

  mov eax, SYS_exit
  xor edi, edi
  syscall
