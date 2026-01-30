; Chapter7_Lesson5_Ex15.asm
; Exercise Solution: constant-time memcmp (branchless early-exit-free) (NASM, x86-64, Linux).
; This avoids data-dependent timing due to early return and tends to be predictably fast.
;
; API:
;   eax = ct_memcmp(a=rdi, b=rsi, n=rdx)
; Returns:
;   eax = 0 if equal, 1 otherwise
;
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex15.asm && ld -o ex15 Chapter7_Lesson5_Ex15.o

BITS 64
default rel

%define SYS_exit 60

section .bss
align 16
buf1: resb 64
buf2: resb 64

section .text
global _start
global ct_memcmp

ct_memcmp:
  xor eax, eax        ; diff accumulator (use RAX)
  test rdx, rdx
  jz .finish

  mov rcx, rdx
  shr rcx, 3          ; qword chunks
.qloop:
  test rcx, rcx
  jz .tail
  mov r8,  [rdi]
  mov r9,  [rsi]
  xor r8, r9
  or  rax, r8
  add rdi, 8
  add rsi, 8
  dec rcx
  jmp .qloop

.tail:
  mov rcx, rdx
  and rcx, 7
.bloop:
  test rcx, rcx
  jz .finish
  mov r8b, [rdi]
  mov r9b, [rsi]
  xor r8b, r9b
  or  al,  r8b
  inc rdi
  inc rsi
  dec rcx
  jmp .bloop

.finish:
  ; Convert diff!=0 to 1, else 0
  test rax, rax
  setnz al
  movzx eax, al
  ret

_start:
  ; init both buffers equal, then flip one byte
  lea rdi, [buf1]
  lea rsi, [buf2]
  xor ecx, ecx
.init:
  mov byte [rdi + rcx], 0x55
  mov byte [rsi + rcx], 0x55
  inc ecx
  cmp ecx, 64
  jb .init
  xor byte [buf2 + 17], 1

  lea rdi, [buf1]
  lea rsi, [buf2]
  mov edx, 64
  call ct_memcmp

  mov eax, SYS_exit
  xor edi, edi
  syscall
