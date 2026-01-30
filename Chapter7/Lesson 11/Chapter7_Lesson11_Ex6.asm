; Chapter 7 - Lesson 11 - Example 6 (Exercise Solution)
; Topic: Bounds-checked copy primitive (safe_copy) + test harness
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;
; Run:
;   ./ex6

default rel
global _start

%define SYS_write 1
%define SYS_exit  60

section .data
msg0       db "== safe_copy demo ==", 10
msg0_len   equ $-msg0

msgOK      db "Copy 16 bytes: OK", 10
msgOK_len  equ $-msgOK

msgFAIL    db "Copy 20 bytes into 16-byte dst: REJECTED (bounds check).", 10
msgFAIL_len equ $-msgFAIL

hexdigits  db "0123456789abcdef"
nl         db 10

section .bss
dst        resb 16
src        resb 32
bytebuf    resb 3

section .text

write1:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

print_nl:
    lea rsi, [rel nl]
    mov edx, 1
    jmp write1

; rdi=ptr, esi=len
dump_bytes_hex:
    push rbx
    push r12
    mov r12, rdi
    mov ebx, esi
    xor ecx, ecx
.loop:
    cmp ecx, ebx
    jae .done

    movzx eax, byte [r12 + rcx]
    mov edx, eax
    shr edx, 4
    and eax, 0x0F

    lea r8, [rel hexdigits]
    mov dl, byte [r8 + rdx]
    mov byte [bytebuf], dl
    mov dl, byte [r8 + rax]
    mov byte [bytebuf+1], dl
    mov byte [bytebuf+2], ' '

    lea rsi, [rel bytebuf]
    mov edx, 3
    call write1

    inc ecx
    jmp .loop
.done:
    call print_nl
    pop r12
    pop rbx
    ret

; safe_copy(dst=rdi, dst_size=rsi, src=rdx, n=rcx) returns rax
safe_copy:
    cmp rcx, rsi
    ja .fail
    mov rsi, rdx
    rep movsb
    xor eax, eax
    ret
.fail:
    mov rax, -1
    ret

_start:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    ; init src with 0..31
    lea rdi, [rel src]
    xor eax, eax
    mov ecx, 32
.init:
    mov byte [rdi], al
    inc rdi
    inc al
    loop .init

    ; case 1: copy 16 bytes (OK)
    lea rdi, [rel dst]
    mov esi, 16
    lea rdx, [rel src]
    mov ecx, 16
    call safe_copy
    test rax, rax
    js .case2

    lea rsi, [rel msgOK]
    mov edx, msgOK_len
    call write1

    lea rdi, [rel dst]
    mov esi, 16
    call dump_bytes_hex

.case2:
    ; case 2: copy 20 bytes (FAIL)
    lea rdi, [rel dst]
    mov esi, 16
    lea rdx, [rel src]
    mov ecx, 20
    call safe_copy
    test rax, rax
    jns .done

    lea rsi, [rel msgFAIL]
    mov edx, msgFAIL_len
    call write1

.done:
    mov eax, SYS_exit
    xor edi, edi
    syscall
