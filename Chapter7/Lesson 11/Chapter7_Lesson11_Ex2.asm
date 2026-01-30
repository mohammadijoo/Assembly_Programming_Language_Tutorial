; Chapter 7 - Lesson 11 - Example 2
; Topic: Double-Free diagnosis (child triggers the bug; parent continues)
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex2.asm -o ex2.o
;   gcc -no-pie ex2.o -o ex2
;
; Run:
;   ./ex2
;
; Notes:
;   - The child process intentionally calls free(ptr) twice.
;   - Many allocators (e.g., glibc) detect this and abort the child.
;   - The parent waits and then demonstrates the defensive pattern:
;       free(ptr); ptr = 0; and guard checks before freeing.

default rel
global main

extern malloc
extern free

section .data
msg0       db "== Double-Free demo (child triggers, parent survives) ==", 10
msg0_len   equ $-msg0

msg1       db "Parent: allocated and freed once. Forking child...", 10
msg1_len   equ $-msg1

msgC       db "Child: attempting double-free now (expected allocator abort).", 10
msgC_len   equ $-msgC

msgP1      db "Parent: child terminated; now demonstrating safe free discipline.", 10
msgP1_len  equ $-msgP1

msgP2      db "Parent: ptr was nulled; guarded free skipped. (No second free.)", 10
msgP2_len  equ $-msgP2

section .bss
status     resd 1

section .text

; write(1, rsi, rdx)
write1:
    mov eax, 1
    mov edi, 1
    syscall
    ret

; exit(code in edi)
sys_exit:
    mov eax, 60
    syscall

main:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    ; ptr = malloc(64)
    mov edi, 64
    call malloc
    test rax, rax
    je .fail
    mov rbx, rax

    ; free(ptr) once
    mov rdi, rbx
    call free

    lea rsi, [rel msg1]
    mov edx, msg1_len
    call write1

    ; fork()
    mov eax, 57
    syscall
    test eax, eax
    js .fail
    jz .child

    ; parent: eax = child pid
    mov edi, eax                 ; pid
    lea rsi, [rel status]        ; status*
    xor edx, edx                 ; options = 0
    xor r10d, r10d               ; rusage = 0
    mov eax, 61                  ; wait4(pid, status, 0, 0)
    syscall

    lea rsi, [rel msgP1]
    mov edx, msgP1_len
    call write1

    ; Defensive pattern: treat freed pointer as invalid.
    xor rbx, rbx                 ; ptr = 0

    ; Guarded free: if ptr == 0 then skip
    test rbx, rbx
    jz .skip

    mov rdi, rbx
    call free

.skip:
    lea rsi, [rel msgP2]
    mov edx, msgP2_len
    call write1

    xor edi, edi
    jmp sys_exit

.child:
    lea rsi, [rel msgC]
    mov edx, msgC_len
    call write1

    ; Intentional double-free (may abort inside allocator)
    mov rdi, rbx
    call free

    ; If allocator did NOT abort, exit nonzero to highlight undefined behavior.
    mov edi, 2
    jmp sys_exit

.fail:
    mov edi, 1
    jmp sys_exit
