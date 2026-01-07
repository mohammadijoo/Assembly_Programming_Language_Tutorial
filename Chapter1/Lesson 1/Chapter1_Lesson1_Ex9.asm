; Linux x86-64 (NASM/Intel syntax) - minimal write + exit
; Syscall convention (overview):
;   rax = syscall number
;   rdi, rsi, rdx, r10, r8, r9 = args 1..6
;   syscall clobbers rcx, r11

section .rodata
msg:    db "Hello, Assembly!", 10
msg_len equ $ - msg

section .text
global _start

_start:
  ; write(1, msg, msg_len)
  mov eax, 1          ; SYS_write
  mov edi, 1          ; fd = stdout
  lea rsi, [rel msg]  ; buffer address (RIP-relative)
  mov edx, msg_len    ; length
  syscall

  ; exit(0)
  mov eax, 60         ; SYS_exit
  xor edi, edi        ; status = 0
  syscall