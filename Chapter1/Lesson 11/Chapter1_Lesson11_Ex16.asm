; x86 (32-bit) Linux: write(1, msg, len) via int 0x80
; EAX = syscall number
; EBX = fd
; ECX = buf
; EDX = count

section .data
msg db "Hello from 32-bit", 10
len equ $ - msg

section .text
global _start
_start:
    mov eax, 4          ; SYS_write (32-bit)
    mov ebx, 1          ; fd=stdout
    mov ecx, msg
    mov edx, len
    int 0x80

    mov eax, 1          ; SYS_exit (32-bit)
    xor ebx, ebx
    int 0x80
