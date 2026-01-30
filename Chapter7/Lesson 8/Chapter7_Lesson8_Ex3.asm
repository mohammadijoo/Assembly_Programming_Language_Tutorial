; Chapter7_Lesson8_Ex3.asm
; W^X pattern: map RW, write machine code bytes, flip to RX with mprotect, call it.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

%define PAGESZ 4096

section .data
msg_intro: db "W^X demo: RW map -> write bytes -> mprotect to RX -> execute.", 10
len_intro: equ $-msg_intro

msg_ret: db "Generated function returned: "
len_ret: equ $-msg_ret

section .bss
numbuf: resb 32

section .text
_start:
    and rsp, -16

    syscall3 SYS_write, 1, msg_intro, len_intro

    ; rax = mmap(NULL, PAGESZ, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
    syscall6 SYS_mmap, 0, PAGESZ, (PROT_READ|PROT_WRITE), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0
    test rax, rax
    js .exit_fail
    mov r12, rax             ; base pointer

    ; Emit machine code: mov eax, 42 ; ret
    ; bytes: B8 2A 00 00 00 C3
    mov byte [r12+0], 0xB8
    mov dword [r12+1], 42
    mov byte [r12+5], 0xC3

    ; mprotect(base, PAGESZ, PROT_READ|PROT_EXEC)
    syscall3 SYS_mprotect, r12, PAGESZ, (PROT_READ|PROT_EXEC)
    test rax, rax
    js .exit_fail

    ; Call generated code
    call r12                  ; returns in eax
    movzx rax, eax

    ; Print result
    syscall3 SYS_write, 1, msg_ret, len_ret
    call u64_to_dec           ; returns rsi=ptr, rdx=len
    syscall3 SYS_write, 1, rsi, rdx

    ; cleanup
    syscall2 SYS_munmap, r12, PAGESZ
    syscall1 SYS_exit, 0

.exit_fail:
    syscall1 SYS_exit, 1

; Convert unsigned in rax to decimal ASCII + '\n'
; Output: rsi=ptr, rdx=len
u64_to_dec:
    push rbx
    lea rbx, [rel numbuf + 31]
    mov byte [rbx], 10        ; '\n'
    dec rbx

    cmp rax, 0
    jne .loop

    mov byte [rbx], '0'
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret

.loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx                   ; rax=quotient, rdx=remainder
    add dl, '0'
    mov [rbx], dl
    dec rbx
    test rax, rax
    jne .loop

    inc rbx
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret
