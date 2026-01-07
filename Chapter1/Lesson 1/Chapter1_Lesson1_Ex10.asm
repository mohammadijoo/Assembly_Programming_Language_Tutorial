# Linux x86-64 (GAS/AT&T syntax) - preview form
  .section .rodata
msg:
  .ascii "Hello, Assembly!\n"
msg_end:
  .equ msg_len, msg_end - msg

  .section .text
  .globl _start
_start:
  # write(1, msg, msg_len)
  movl $1, %eax          # SYS_write
  movl $1, %edi          # fd = stdout
  leaq msg(%rip), %rsi   # buffer
  movl $msg_len, %edx    # length
  syscall

  # exit(0)
  movl $60, %eax         # SYS_exit
  xorl %edi, %edi        # status = 0
  syscall