; Chapter7_Lesson5_Ex14.asm
; Exercise Solution: compact string table using (offsets + arena) (NASM, x86-64, Linux).
; Memory idea:
;   - store many variable-length strings back-to-back in a single arena
;   - store 32-bit offsets in an index table
; Benefits: fewer mallocs, better locality, smaller pointers.
;
; API:
;   void strtab_init(void)
;   eax = strtab_push(rdi=src_cstr)   ; returns index (>=0) or -1 on failure
;   rax = strtab_get(edi=index)       ; returns ptr or 0 on bad index
;
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex14.asm && ld -o ex14 Chapter7_Lesson5_Ex14.o

BITS 64
default rel

%define SYS_exit 60

%define MAX_STR   64
%define ARENA_CAP 2048

section .data
s1: db "alpha", 0
s2: db "beta-gamma-delta", 0

section .bss
align 16
offsets: resd MAX_STR
count:   resd 1
arena:   resb ARENA_CAP
cur:     resd 1

section .text
global _start
global strtab_init
global strtab_push
global strtab_get

strtab_init:
  mov dword [count], 0
  mov dword [cur],   0
  ret

; eax = strtab_push(src=rdi)
strtab_push:
  push rbx
  push r12
  push r13

  mov rbx, rdi               ; src
  mov eax, [count]
  cmp eax, MAX_STR
  jae .fail

  mov r12d, [cur]            ; current offset in arena
  mov r13d, r12d             ; start offset to record

.copy:
  cmp r12d, ARENA_CAP
  jae .fail
  mov dl, [rbx]
  inc rbx
  mov [arena + r12], dl
  inc r12d
  test dl, dl
  jnz .copy

  ; Store offset and update cur/count
  mov [offsets + rax*4], r13d
  mov [cur], r12d
  inc eax
  mov [count], eax
  dec eax                     ; return index = old count

  pop r13
  pop r12
  pop rbx
  ret

.fail:
  mov eax, -1
  pop r13
  pop r12
  pop rbx
  ret

; rax = strtab_get(index=edi)
strtab_get:
  mov eax, [count]
  cmp edi, eax
  jae .bad
  mov eax, [offsets + rdi*4]
  lea rax, [arena + rax]
  ret
.bad:
  xor eax, eax
  ret

_start:
  call strtab_init

  lea rdi, [s1]
  call strtab_push

  lea rdi, [s2]
  call strtab_push

  mov edi, 1
  call strtab_get             ; rax points to "beta-gamma-delta"

  mov eax, SYS_exit
  xor edi, edi
  syscall
