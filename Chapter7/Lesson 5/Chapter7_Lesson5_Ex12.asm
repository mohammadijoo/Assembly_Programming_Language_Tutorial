; Chapter7_Lesson5_Ex12.asm
; Exercise Solution: tiny slab allocator with 3 size classes (16/32/64 bytes).
; Uses a 64-bit bitmap per class (1 bit per object, 1 = free).
; This is a teaching model: real allocators handle coalescing, multiple pages, metadata, etc.
;
; API:
;   void slab_init(void)
;   rax = slab_alloc(edi=size_bytes)      ; returns 0 on failure
;   void slab_free(rdi=ptr, esi=size_bytes)
;
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex12.asm && ld -o ex12 Chapter7_Lesson5_Ex12.o

BITS 64
default rel

%define SYS_exit 60
%define COUNT 64

section .bss
align 64
slab16_mem:  resb 16 * COUNT
slab16_free: resq 1

slab32_mem:  resb 32 * COUNT
slab32_free: resq 1

slab64_mem:  resb 64 * COUNT
slab64_free: resq 1

section .text
global _start
global slab_init
global slab_alloc
global slab_free

slab_init:
  mov qword [slab16_free], 0xFFFFFFFFFFFFFFFF
  mov qword [slab32_free], 0xFFFFFFFFFFFFFFFF
  mov qword [slab64_free], 0xFFFFFFFFFFFFFFFF
  ret

; rax = alloc_from_class(base=rdi, bitmap_ptr=rsi, shift=edx)
; (shift = log2(obj_size), obj_size is power of 2)
alloc_from_class:
  mov rbx, [rsi]
  test rbx, rbx
  jz .fail
  bsf rcx, rbx                 ; idx of first free bit
  btr qword [rsi], rcx         ; mark allocated (clear bit)
  shl rcx, dl                  ; idx * obj_size
  lea rax, [rdi + rcx]
  ret
.fail:
  xor eax, eax
  ret

; rax = slab_alloc(size_bytes in edi)
slab_alloc:
  cmp edi, 16
  jbe .c16
  cmp edi, 32
  jbe .c32
  cmp edi, 64
  jbe .c64
  xor eax, eax
  ret

.c16:
  lea rdi, [slab16_mem]
  lea rsi, [slab16_free]
  mov edx, 4                   ; 2^4 = 16
  jmp alloc_from_class
.c32:
  lea rdi, [slab32_mem]
  lea rsi, [slab32_free]
  mov edx, 5
  jmp alloc_from_class
.c64:
  lea rdi, [slab64_mem]
  lea rsi, [slab64_free]
  mov edx, 6
  jmp alloc_from_class

; void free_to_class(ptr=rdi, base=rsi, bitmap_ptr=rdx, shift=ecx)
free_to_class:
  ; range check: ptr in [base, base + obj_size*COUNT)
  mov r8, rsi
  mov rax, COUNT
  shl rax, cl                   ; COUNT * obj_size
  lea r10, [rsi + rax]           ; end
  cmp rdi, r8
  jb .done
  cmp rdi, r10
  jae .done

  mov rax, rdi
  sub rax, rsi                   ; offset
  shr rax, cl                    ; idx
  bts qword [rdx], rax           ; mark free (set bit)
.done:
  ret

; void slab_free(ptr=rdi, size_bytes in esi)
slab_free:
  cmp esi, 16
  jbe .f16
  cmp esi, 32
  jbe .f32
  cmp esi, 64
  jbe .f64
  ret
.f16:
  lea rsi, [slab16_mem]
  lea rdx, [slab16_free]
  mov ecx, 4
  jmp free_to_class
.f32:
  lea rsi, [slab32_mem]
  lea rdx, [slab32_free]
  mov ecx, 5
  jmp free_to_class
.f64:
  lea rsi, [slab64_mem]
  lea rdx, [slab64_free]
  mov ecx, 6
  jmp free_to_class

_start:
  call slab_init

  mov edi, 24
  call slab_alloc
  mov rbx, rax

  mov edi, 8
  call slab_alloc
  mov rcx, rax

  mov rdi, rbx
  mov esi, 24
  call slab_free

  mov rdi, rcx
  mov esi, 8
  call slab_free

  mov eax, SYS_exit
  xor edi, edi
  syscall
