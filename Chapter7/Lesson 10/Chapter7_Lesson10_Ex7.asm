; Chapter7_Lesson10_Ex7.asm
; Topic: Poison-after-free + nulling the pointer to block obvious UAF paths
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .bss
heap_buf   resb 32
heap_ptr   resq 1

section .data
msg_alloc  db "Allocated pointer is non-null.", 10
msg_alloc_len equ $-msg_alloc
msg_free   db "Freed: memory poisoned + pointer nulled.", 10
msg_free_len equ $-msg_free
msg_block  db "Blocked access because pointer is null.", 10
msg_block_len equ $-msg_block

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

; poison_and_null(ptr_addr=rdi, len=rsi) -> rax = 0 (null)
poison_and_null:
    ; Load pointer
    mov rbx, [rdi]
    test rbx, rbx
    jz .already_null

    ; Poison bytes with 0xDD
    mov rdi, rbx
    mov al, 0xDD
    mov rcx, rsi
    rep stosb

    ; Null out the stored pointer
    mov qword [heap_ptr], 0
.already_null:
    xor eax, eax
    ret

_start:
    ; "Allocate": point to static buffer
    lea rax, [heap_buf]
    mov [heap_ptr], rax

    lea rsi, [msg_alloc]
    mov edx, msg_alloc_len
    call write_stdout

    ; Free with poisoning + nulling
    lea rdi, [heap_ptr]
    mov rsi, 32
    call poison_and_null

    lea rsi, [msg_free]
    mov edx, msg_free_len
    call write_stdout

    ; Attempt to use: blocked by null check
    mov rbx, [heap_ptr]
    test rbx, rbx
    jz .blocked

    ; If not blocked, write would happen here (omitted)
    mov edi, 3
    jmp exit_

.blocked:
    lea rsi, [msg_block]
    mov edx, msg_block_len
    call write_stdout
    xor edi, edi
    jmp exit_
