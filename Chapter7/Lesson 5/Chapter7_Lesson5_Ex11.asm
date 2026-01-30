; Chapter7_Lesson5_Ex11.asm
; Exercise Solution: realloc-like growth using mmap + copy + munmap (NASM, x86-64, Linux).
; Interface:
;   rax = realloc_mmap(old_ptr, old_len, new_len)
;     rdi=old_ptr (0 allowed), rsi=old_len, rdx=new_len
; Returns:
;   rax = new_ptr or 0 on failure
;
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex11.asm && ld -o ex11 Chapter7_Lesson5_Ex11.o

BITS 64
default rel

%define SYS_mmap   9
%define SYS_munmap 11
%define SYS_exit   60

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE   2
%define MAP_ANONYMOUS 32

%define PAGE 4096

section .text
global _start

; rax = round_up_pages(rdi = nbytes)
round_up_pages:
  lea rax, [rdi + PAGE - 1]
  and rax, -PAGE
  ret

; void copy_bytes(dst=rdi, src=rsi, n=rdx)
copy_bytes:
  test rdx, rdx
  jz .done
  mov rcx, rdx
  rep movsb
.done:
  ret

; rax = realloc_mmap(old_ptr=rdi, old_len=rsi, new_len=rdx)
realloc_mmap:
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov rbx, rdi          ; old_ptr
  mov r12, rsi          ; old_len
  mov r13, rdx          ; new_len

  ; new_map_len = round_up_pages(new_len)
  mov rdi, r13
  call round_up_pages
  mov r15, rax          ; new_map_len

  ; mmap(0, new_map_len, RW, PRIVATE|ANON, -1, 0)
  xor edi, edi
  mov rsi, r15
  mov edx, PROT_READ | PROT_WRITE
  mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
  mov r8d, -1
  xor r9d, r9d
  mov eax, SYS_mmap
  syscall
  test rax, rax
  js .fail
  mov r14, rax          ; new_ptr

  ; If old_ptr == 0: skip copy and free
  test rbx, rbx
  jz .success_new

  ; copy_len = min(old_len, new_len)
  mov rcx, r12
  cmp rcx, r13
  cmova rcx, r13

  ; copy_bytes(new_ptr, old_ptr, copy_len)
  mov rdi, r14
  mov rsi, rbx
  mov rdx, rcx
  call copy_bytes

  ; munmap(old_ptr, round_up_pages(old_len))
  mov rdi, r12
  call round_up_pages
  mov rsi, rax          ; old_map_len
  mov eax, SYS_munmap
  mov rdi, rbx
  syscall

.success_new:
  mov rax, r14

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  ret

.fail:
  xor eax, eax
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  ret

_start:
  ; Demo: allocate 100 bytes (old_ptr=0), then grow to 5000 bytes
  xor edi, edi
  xor esi, esi
  mov edx, 100
  call realloc_mmap
  mov rbx, rax

  mov rdi, rbx
  mov esi, 100
  mov edx, 5000
  call realloc_mmap

  mov eax, SYS_exit
  xor edi, edi
  syscall
