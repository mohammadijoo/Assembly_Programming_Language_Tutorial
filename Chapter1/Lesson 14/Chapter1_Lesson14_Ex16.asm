; Example: a tiny “constants include” approach (NASM)
; File: syscalls_linux_x64.inc (conceptually)
; %define __NR_write 1
; %define __NR_exit  60

; Then in code:
; mov eax, __NR_write
