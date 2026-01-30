; Chapter7_Lesson5_Ex4.asm
; Fixed-size pool allocator (free list) (NASM, x86-64, Linux).
; Use when you allocate many same-size objects: O(1) alloc/free and great locality.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex4.asm && ld -o ex4 Chapter7_Lesson5_Ex4.o

BITS 64
default rel

%define SYS_exit 60

; Pool parameters
%define OBJ_SIZE  32
%define OBJ_COUNT 64

; Pool header:
;   [0]  head (pointer to first free object, 0 if none)
%define POOL_head 0
%define POOL_size 8

section .bss
align 16
pool:      resb POOL_size
pool_mem:  resb OBJ_SIZE * OBJ_COUNT

section .text
global _start

; -------------------------------------------
; void pool_init(pool*, mem_base)
;   rdi=pool*, rsi=mem_base
; Builds a singly-linked free list inside the objects themselves:
;   *(obj) = next_free
; -------------------------------------------
pool_init:
  ; head = mem_base
  mov [rdi + POOL_head], rsi

  xor ecx, ecx
.loop:
  lea rax, [rsi + rcx*OBJ_SIZE]       ; obj = base + i*size
  lea rdx, [rax + OBJ_SIZE]           ; next = obj + size
  inc rcx
  cmp rcx, OBJ_COUNT
  jb .store_next
  xor edx, edx                        ; last -> null
.store_next:
  mov [rax], rdx                      ; *(obj) = next
  cmp rcx, OBJ_COUNT
  jb .loop
  ret

; -------------------------------------------
; rax = pool_alloc(pool*)
;   rdi=pool*
; returns rax = obj or 0 if empty
; -------------------------------------------
pool_alloc:
  mov rax, [rdi + POOL_head]
  test rax, rax
  jz .empty
  mov rdx, [rax]                      ; next = *(obj)
  mov [rdi + POOL_head], rdx
  ret
.empty:
  xor eax, eax
  ret

; -------------------------------------------
; void pool_free(pool*, obj)
;   rdi=pool*, rsi=obj
; pushes obj back to front of free list
; -------------------------------------------
pool_free:
  mov rax, [rdi + POOL_head]
  mov [rsi], rax
  mov [rdi + POOL_head], rsi
  ret

_start:
  lea rdi, [pool]
  lea rsi, [pool_mem]
  call pool_init

  ; Allocate two objects
  lea rdi, [pool]
  call pool_alloc
  mov rbx, rax

  lea rdi, [pool]
  call pool_alloc
  mov rcx, rax

  ; Free them (LIFO order)
  lea rdi, [pool]
  mov rsi, rcx
  call pool_free

  lea rdi, [pool]
  mov rsi, rbx
  call pool_free

  mov eax, SYS_exit
  xor edi, edi
  syscall
