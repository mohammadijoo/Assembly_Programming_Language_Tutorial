; Chapter 6 - Lesson 8 (Exercise 1 Solution)
; Very hard: Case-insensitive ASCII strcmp that calls a helper (tolower_ascii).
; Demonstrates: (1) keeping long-lived pointers in callee-saved regs, (2) call-safe loop discipline.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
;   ./ex10

BITS 64
default rel
global _start

section .rodata
s1 db "Hello-Assembly", 0
s2 db "hELLo-assembly", 0
s3 db "Hello-AssemblX", 0

msg_ok1 db "OK: equal (case-insensitive)", 10
len_ok1 equ $-msg_ok1
msg_ok2 db "OK: not equal (case-insensitive)", 10
len_ok2 equ $-msg_ok2
msg_fail db "FAIL", 10
len_fail equ $-msg_fail

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

tolower_ascii:
    ; al = input char, returns al = lowercased if 'A'..'Z'
    cmp al, 'A'
    jb .done
    cmp al, 'Z'
    ja .done
    add al, 32
.done:
    ret

strcmpi_ascii:
    ; rdi = s1, rsi = s2
    ; returns eax: 0 if equal, negative if s1<s2, positive if s1>s2 (like strcmp)
    ; Calls tolower_ascii -> we must treat caller-saved regs as clobbered across that call.
    push rbx
    push r12
    push r13
    sub rsp, 8               ; align (3 pushes -> odd, need 8 for SysV)
    mov r12, rdi             ; keep pointers in callee-saved regs
    mov r13, rsi

.loop:
    mov al, [r12]
    mov bl, [r13]

    ; normalize al
    call tolower_ascii       ; uses al only
    mov dl, al               ; save normalized s1 char in dl (caller-saved, but no call until saved)
    ; normalize bl: move to al, call, then restore into bl
    mov al, bl
    call tolower_ascii
    mov bl, al

    ; compare dl vs bl
    cmp dl, bl
    jne .diff

    ; if both zero, equal
    test dl, dl
    jz .eq

    inc r12
    inc r13
    jmp .loop

.diff:
    movzx eax, dl
    movzx ebx, bl
    sub eax, ebx
    jmp .out

.eq:
    xor eax, eax
.out:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [rel s1]
    lea rsi, [rel s2]
    call strcmpi_ascii
    test eax, eax
    jne .fail

    lea rsi, [rel msg_ok1]
    mov edx, len_ok1
    call write_msg

    lea rdi, [rel s1]
    lea rsi, [rel s3]
    call strcmpi_ascii
    test eax, eax
    je .fail

    lea rsi, [rel msg_ok2]
    mov edx, len_ok2
    call write_msg

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
    mov eax, 60
    mov edi, 1
    syscall
