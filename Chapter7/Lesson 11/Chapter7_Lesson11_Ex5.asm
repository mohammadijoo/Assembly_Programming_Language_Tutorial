; Chapter 7 - Lesson 11 - Example 5 (Exercise Solution)
; Topic: A debug allocator wrapper (header + poisoning) to detect double-free / invalid free
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex5.asm -o ex5.o
;   gcc -no-pie ex5.o -o ex5
;
; Run:
;   ./ex5

default rel
global main

extern malloc
extern free

section .data
MAGIC_QWORD   dq 0x434f4c4c41474244    ; "DBGALLOC" little-endian

msg0          db "== Debug allocator wrapper demo ==", 10
msg0_len      equ $-msg0

msgOk         db "First dbg_free succeeded.", 10
msgOk_len     equ $-msgOk

msgBad        db "Caught memory bug: double free or invalid pointer passed to dbg_free.", 10
msgBad_len    equ $-msgBad

section .text

write1:
    mov eax, 1
    mov edi, 1
    syscall
    ret

sys_exit:
    mov eax, 60
    syscall

fatal_bad_free:
    lea rsi, [rel msgBad]
    mov edx, msgBad_len
    call write1
    mov edi, 7
    jmp sys_exit

; dbg_malloc(size in edi) returns rax=user_ptr
dbg_malloc:
    push rbx
    mov ebx, edi
    add edi, 32
    call malloc
    test rax, rax
    je .fail
    mov rdx, [rel MAGIC_QWORD]
    mov [rax], rdx
    mov [rax+8], rbx
    mov qword [rax+16], 0
    mov qword [rax+24], 0
    add rax, 32
    pop rbx
    ret
.fail:
    pop rbx
    xor eax, eax
    ret

; dbg_free(user_ptr in rdi)
dbg_free:
    push rbx
    push r12
    mov r12, rdi
    sub r12, 32
    mov rax, [r12]
    cmp rax, [rel MAGIC_QWORD]
    jne .bad
    mov rax, [r12+16]
    test rax, rax
    jne .bad

    mov rbx, [r12+8]
    lea rdi, [r12+32]
    mov ecx, ebx
    mov al, 0xDD
    rep stosb

    mov qword [r12+16], 1
    mov rdi, r12
    call free

    pop r12
    pop rbx
    ret

.bad:
    pop r12
    pop rbx
    jmp fatal_bad_free

main:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    mov edi, 64
    call dbg_malloc
    test rax, rax
    je .fail
    mov rbx, rax

    mov rdi, rbx
    call dbg_free

    lea rsi, [rel msgOk]
    mov edx, msgOk_len
    call write1

    mov rdi, rbx
    call dbg_free

    mov edi, 0
    jmp sys_exit

.fail:
    mov edi, 1
    jmp sys_exit
