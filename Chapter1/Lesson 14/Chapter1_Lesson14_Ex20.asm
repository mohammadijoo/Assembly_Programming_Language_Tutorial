extern tweak
global sum8
section .text
sum8:
    ; SysV arg regs: a1=RDI, a2=RSI, a3=RDX, a4=RCX, a5=R8, a6=R9
    ; Stack args: a7 at [RSP+8] and a8 at [RSP+16] at entry (because [RSP] is return address)

    push rbp
    mov rbp, rsp

    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rbp + 16]   ; a7: at entry [RSP+8], but after push rbp, it becomes [RBP+16]
    add rax, [rbp + 24]   ; a8

    ; Now call tweak(sum). Need SysV alignment:
    ; We pushed RBP (8 bytes). If we do no more pushes, we are misaligned for calls,
    ; so adjust by 8.
    sub rsp, 8
    mov rdi, rax
    call tweak
    add rsp, 8

    pop rbp
    ret
