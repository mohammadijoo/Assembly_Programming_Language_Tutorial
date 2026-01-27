; Chapter 6 - Lesson 2 - Example 3
; File: Chapter6_Lesson2_Ex3.asm
; Topic: Calling your own procedures in a complete Linux x86-64 program
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
; Run:
;   ./ex3
;
; Output:
;   sum = 150

default rel

section .data
arr:    dq 10, 20, 30, 40, 50
arr_n:  dq 5
msg1:   db "sum = ", 0
nl:     db 10, 0

section .bss
buf:    resb 32     ; enough for u64 decimal

section .text
global _start

; ------------------------------------------------------------
; u64_strlen(const char* s) -> RAX = length (bytes, excluding NUL)
; RDI = s
u64_strlen:
    xor eax, eax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; ------------------------------------------------------------
; sys_write(fd, buf, len)
; RDI = fd, RSI = buf, RDX = len
; clobbers: RAX, RCX, R11
sys_write:
    mov eax, 1
    syscall
    ret

; ------------------------------------------------------------
; sum_u64(const uint64_t* a, uint64_t n) -> RAX = sum
; RDI = a, RSI = n
sum_u64:
    xor rax, rax
    xor rcx, rcx
.loop:
    cmp rcx, rsi
    jae .done
    add rax, [rdi + rcx*8]
    inc rcx
    jmp .loop
.done:
    ret

; ------------------------------------------------------------
; u64_to_dec(uint64_t x, char* out_end) -> RAX=ptr_to_first_char, RDX=len
; Writes decimal digits ending at out_end-1 and returns pointer to start.
; RDI = x, RSI = out_end
;
; Strategy: build digits backward in the buffer.
u64_to_dec:
    mov rax, rdi          ; x in RAX for div
    mov r8, rsi           ; end pointer
    mov rcx, 10

    ; Handle x == 0
    test rax, rax
    jnz .loop
    dec r8
    mov byte [r8], '0'
    mov rax, r8
    mov rdx, 1
    ret

.loop:
    xor edx, edx
    div rcx               ; quotient in RAX, remainder in RDX
    add dl, '0'
    dec r8
    mov [r8], dl
    test rax, rax
    jnz .loop

    ; length = out_end - r8
    mov rax, r8
    mov rdx, rsi
    sub rdx, r8
    ret

_start:
    ; Compute sum(arr, n)
    lea rdi, [rel arr]
    mov rsi, [rel arr_n]
    call sum_u64          ; RAX = sum
    mov r12, rax          ; save sum (callee-saved register)

    ; Print "sum = "
    lea rdi, [rel msg1]
    call u64_strlen       ; RAX = len
    mov rdx, rax
    mov rdi, 1
    lea rsi, [rel msg1]
    call sys_write

    ; Convert sum to decimal string at end of buf
    lea rsi, [rel buf + 32]
    mov rdi, r12
    call u64_to_dec       ; RAX=ptr, RDX=len

    ; write digits
    mov rdi, 1
    mov rsi, rax
    call sys_write

    ; newline
    lea rdi, [rel nl]
    call u64_strlen
    mov rdx, rax
    mov rdi, 1
    lea rsi, [rel nl]
    call sys_write

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall
