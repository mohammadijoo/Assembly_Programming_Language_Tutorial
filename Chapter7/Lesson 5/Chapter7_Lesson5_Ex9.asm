; Chapter7_Lesson5_Ex9.asm
; OS-level memory optimization primitive: mmap (anonymous mapping) (NASM, x86-64, Linux).
; Use cases: large allocations, page alignment, guard pages, zero-fill-on-demand.
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex9.asm && ld -o ex9 Chapter7_Lesson5_Ex9.o

BITS 64
default rel

%define SYS_write  1
%define SYS_mmap   9
%define SYS_munmap 11
%define SYS_exit   60

%define PROT_READ  1
%define PROT_WRITE 2

%define MAP_PRIVATE   2
%define MAP_ANONYMOUS 32

%define PAGE 4096

section .text
global _start

_start:
  ; void* mmap(addr=0, len=PAGE, prot=RW, flags=PRIVATE|ANON, fd=-1, off=0)
  xor edi, edi              ; addr = 0
  mov esi, PAGE             ; len
  mov edx, PROT_READ | PROT_WRITE
  mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
  mov r8d, -1               ; fd
  xor r9d, r9d              ; offset
  mov eax, SYS_mmap
  syscall
  ; rax = mapped address or -errno
  test rax, rax
  js .exit

  mov rbx, rax              ; save mapping

  ; Fill first 64 bytes with 'Z'
  mov rcx, 64
  mov rdi, rbx
  mov al, 'Z'
.fill:
  mov [rdi], al
  inc rdi
  dec rcx
  jnz .fill

  ; write(1, map, 64)
  mov eax, SYS_write
  mov edi, 1
  mov rsi, rbx
  mov edx, 64
  syscall

  ; munmap(map, PAGE)
  mov eax, SYS_munmap
  mov rdi, rbx
  mov esi, PAGE
  syscall

.exit:
  mov eax, SYS_exit
  xor edi, edi
  syscall
