global write_wrap
global last_errno
section .bss
last_errno: resd 1

section .text
write_wrap:
    ; SysV: fd=EDI, buf=RSI, len=RDX
    ; We must issue syscall with:
    ;   RAX=1, RDI=fd, RSI=buf, RDX=len

    ; Preserve callee-saved regs (none used besides RBP here, but keep a standard frame)
    push rbp
    mov rbp, rsp

    mov eax, 1          ; __NR_write
    mov rdi, rdi        ; fd already in RDI (EDI zero-extends into RDI)
    ; RSI already buf, RDX already len
    syscall

    test rax, rax
    jns .ok
    neg eax
    mov [rel last_errno], eax
    mov rax, -1
.ok:
    pop rbp
    ret
