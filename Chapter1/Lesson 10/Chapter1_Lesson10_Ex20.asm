; Linux x86-64, NASM. Minimal “micro-disassembler” for a tiny subset.
; Prints fixed strings; for MOV EAX, imm32, prints a placeholder and advances by 5 bytes.
; (Extending to print the imm32 value is an optional enhancement.)

global _start

section .rodata
buf:    db 0x90, 0xB8, 0x44, 0x33, 0x22, 0x11, 0xCC, 0xC3
buf_end:

s_nop:  db "NOP", 10
l_nop:  equ $-s_nop
s_ret:  db "RET", 10
l_ret:  equ $-s_ret
s_int3: db "INT3", 10
l_int3: equ $-s_int3
s_mov:  db "MOV EAX, imm32", 10
l_mov:  equ $-s_mov

section .text
_start:
    lea rbx, [rel buf]
    lea r12, [rel buf_end]

.loop:
    cmp rbx, r12
    jae .done

    mov al, [rbx]
    cmp al, 0x90
    je  .is_nop
    cmp al, 0xC3
    je  .is_ret
    cmp al, 0xCC
    je  .is_int3
    cmp al, 0xB8
    je  .is_mov

    ; unknown byte: skip 1 (in real tools you'd error out)
    inc rbx
    jmp .loop

.is_nop:
    ; write(1, s_nop, l_nop)
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s_nop]
    mov edx, l_nop
    syscall
    inc rbx
    jmp .loop

.is_ret:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s_ret]
    mov edx, l_ret
    syscall
    inc rbx
    jmp .loop

.is_int3:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s_int3]
    mov edx, l_int3
    syscall
    inc rbx
    jmp .loop

.is_mov:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel s_mov]
    mov edx, l_mov
    syscall
    add rbx, 5          ; B8 + imm32
    jmp .loop

.done:
    mov eax, 60
    xor edi, edi
    syscall
