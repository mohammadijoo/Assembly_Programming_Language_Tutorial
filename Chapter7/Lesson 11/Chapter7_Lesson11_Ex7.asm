; Chapter 7 - Lesson 11 - Example 7 (Exercise Solution)
; Topic: Lifetime registry to catch use-after-free at API boundaries (conceptual instrumentation)
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex7.asm -o ex7.o
;   gcc -no-pie ex7.o -o ex7
;
; Run:
;   ./ex7

default rel
global main

extern malloc
extern free

%define MAX_LIVE  32

section .data
msg0        db "== Lifetime registry demo ==", 10
msg0_len    equ $-msg0

msg1        db "Allocated 32 bytes; writing within bounds: OK", 10
msg1_len    equ $-msg1

msg2        db "Freed pointer; next checked_store should be rejected as UAF.", 10
msg2_len    equ $-msg2

msgUAF      db "CATCH: use-after-free detected (ptr not live).", 10
msgUAF_len  equ $-msgUAF

msgOOB      db "CATCH: out-of-bounds write detected (offset exceeds allocation size).", 10
msgOOB_len  equ $-msgOOB

msgRegFull  db "Registry full: too many live allocations.", 10
msgRegFull_len equ $-msgRegFull

msgNotFound db "Free of unknown pointer (not in registry).", 10
msgNotFound_len equ $-msgNotFound

section .bss
live_ptrs   resq MAX_LIVE
live_sizes  resq MAX_LIVE

section .text

write1:
    mov eax, 1
    mov edi, 1
    syscall
    ret

sys_exit:
    mov eax, 60
    syscall

fatal_uaf:
    lea rsi, [rel msgUAF]
    mov edx, msgUAF_len
    call write1
    mov edi, 11
    jmp sys_exit

fatal_oob:
    lea rsi, [rel msgOOB]
    mov edx, msgOOB_len
    call write1
    mov edi, 12
    jmp sys_exit

fatal_full:
    lea rsi, [rel msgRegFull]
    mov edx, msgRegFull_len
    call write1
    mov edi, 13
    jmp sys_exit

fatal_notfound:
    lea rsi, [rel msgNotFound]
    mov edx, msgNotFound_len
    call write1
    mov edi, 14
    jmp sys_exit

; reg_add(ptr=rdi, size=rsi)
reg_add:
    push rbx
    xor ebx, ebx
.find_slot:
    cmp ebx, MAX_LIVE
    jae .full
    mov rax, [live_ptrs + rbx*8]
    test rax, rax
    jz .use
    inc ebx
    jmp .find_slot
.use:
    mov [live_ptrs + rbx*8], rdi
    mov [live_sizes + rbx*8], rsi
    pop rbx
    ret
.full:
    pop rbx
    jmp fatal_full

; reg_remove(ptr=rdi)
reg_remove:
    push rbx
    xor ebx, ebx
.find_ptr:
    cmp ebx, MAX_LIVE
    jae .nf
    mov rax, [live_ptrs + rbx*8]
    cmp rax, rdi
    je .rm
    inc ebx
    jmp .find_ptr
.rm:
    mov qword [live_ptrs + rbx*8], 0
    mov qword [live_sizes + rbx*8], 0
    pop rbx
    ret
.nf:
    pop rbx
    jmp fatal_notfound

; reg_lookup(ptr=rdi) returns rdx=size, CF=0 if found; CF=1 if not found
reg_lookup:
    push rbx
    xor ebx, ebx
.loop:
    cmp ebx, MAX_LIVE
    jae .notfound
    mov rax, [live_ptrs + rbx*8]
    cmp rax, rdi
    je .found
    inc ebx
    jmp .loop
.found:
    mov rdx, [live_sizes + rbx*8]
    clc
    pop rbx
    ret
.notfound:
    stc
    pop rbx
    ret

; xmalloc(size in edi) returns rax=ptr
xmalloc:
    push rbx
    mov ebx, edi
    call malloc
    test rax, rax
    je .fail
    mov rdi, rax
    mov rsi, rbx
    call reg_add
    pop rbx
    ret
.fail:
    pop rbx
    xor eax, eax
    ret

; xfree(ptr in rdi)
xfree:
    push rdi
    call reg_remove
    pop rdi
    call free
    ret

; checked_store(ptr=rdi, offset=rsi, value in dl)
checked_store:
    push rbx
    push r12
    mov r12, rdi
    mov rbx, rsi

    mov rdi, r12
    call reg_lookup
    jc .uaf

    cmp rbx, rdx
    jae .oob

    mov byte [r12 + rbx], dl
    pop r12
    pop rbx
    ret

.uaf:
    pop r12
    pop rbx
    jmp fatal_uaf

.oob:
    pop r12
    pop rbx
    jmp fatal_oob

main:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    mov edi, 32
    call xmalloc
    test rax, rax
    je .fail
    mov rbx, rax

    lea rsi, [rel msg1]
    mov edx, msg1_len
    call write1

    mov rdi, rbx
    mov esi, 10
    mov dl, 0x7f
    call checked_store

    lea rsi, [rel msg2]
    mov edx, msg2_len
    call write1
    mov rdi, rbx
    call xfree

    mov rdi, rbx
    mov esi, 0
    mov dl, 0x22
    call checked_store

    xor eax, eax
    ret

.fail:
    mov eax, 60
    mov edi, 1
    syscall
