; ssize_t sys_write(int fd, const void* buf, size_t len)
; Linux x86-64 syscall ABI:
;   RAX = __NR_write
;   RDI = fd
;   RSI = buf
;   RDX = len
; Returns: RAX = bytes written, or negative error code.

global sys_write
section .text
sys_write:
    mov eax, 1              ; __NR_write is commonly 1 on x86-64 Linux
    syscall
    ret
