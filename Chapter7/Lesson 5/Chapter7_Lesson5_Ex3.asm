; Chapter7_Lesson5_Ex3.asm
; Arena (bump) allocator with alignment (NASM, x86-64, Linux).
; Goal: amortize allocation overhead, improve locality, and simplify frees (bulk reset).
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex3.asm && ld -o ex3 Chapter7_Lesson5_Ex3.o

BITS 64
default rel

%define SYS_exit 60

; -----------------------------------
; Arena layout (3 pointers, 24 bytes)
;   [0]  base
;   [8]  cur
;   [16] end
; -----------------------------------
%define ARENA_base 0
%define ARENA_cur  8
%define ARENA_end 16
%define ARENA_size 24

section .bss
align 16
arena_mem: resb 4096
arena:     resb ARENA_size

section .text
global _start

; -------------------------------
; rax = align_up(value, align_pow2)
;   rdi=value, rsi=align
; precondition: align is power of 2
; -------------------------------
align_up:
  ; rax = (value + (a-1)) & ~(a-1)
  lea rax, [rdi + rsi - 1]
  mov rdx, rsi
  dec rdx
  not rdx
  and rax, rdx
  ret

; -------------------------------
; void arena_init(A*, base, size)
;   rdi=A*, rsi=base, rdx=size
; -------------------------------
arena_init:
  mov [rdi + ARENA_base], rsi
  mov [rdi + ARENA_cur],  rsi
  lea rcx, [rsi + rdx]
  mov [rdi + ARENA_end],  rcx
  ret

; ---------------------------------------------
; rax = arena_alloc(A*, size, align_pow2)
;   rdi=A*, rsi=size, rdx=align_pow2
; returns rax=ptr or 0 on OOM
; ---------------------------------------------
arena_alloc:
  push rbx
  push r12
  push r13

  mov rbx, rdi        ; A*
  mov r12, rsi        ; size
  mov r13, rdx        ; align

  mov rcx, [rbx + ARENA_cur]
  mov rdi, rcx
  mov rsi, r13
  call align_up
  mov r9, rax         ; aligned cur

  lea r10, [r9 + r12] ; new_cur
  mov r11, [rbx + ARENA_end]
  cmp r10, r11
  ja .oom

  mov [rbx + ARENA_cur], r10
  mov rax, r9
  jmp .done

.oom:
  xor eax, eax

.done:
  pop r13
  pop r12
  pop rbx
  ret

; -------------------------------
; void arena_reset(A*)
;   rdi=A*
; -------------------------------
arena_reset:
  mov rax, [rdi + ARENA_base]
  mov [rdi + ARENA_cur], rax
  ret

_start:
  ; Initialize arena over arena_mem
  lea rdi, [arena]
  lea rsi, [arena_mem]
  mov edx, 4096
  call arena_init

  ; Allocate 64 bytes aligned to 32 bytes
  lea rdi, [arena]
  mov esi, 64
  mov edx, 32
  call arena_alloc
  ; rax = ptr (or 0)

  ; Allocate 128 bytes aligned to 16 bytes
  lea rdi, [arena]
  mov esi, 128
  mov edx, 16
  call arena_alloc

  ; Bulk-free everything
  lea rdi, [arena]
  call arena_reset

  mov eax, SYS_exit
  xor edi, edi
  syscall
