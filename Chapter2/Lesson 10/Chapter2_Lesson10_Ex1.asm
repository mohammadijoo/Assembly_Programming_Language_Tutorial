; Chapter 2 - Lesson 10 - Example 1
; Core Data-Movement Instructions: MOV (forms, sizes, memory rules)
; Target: Linux x86-64 (NASM), assemble with:
;   nasm -felf64 Chapter2_Lesson10_Ex1.asm -o ex1.o && ld ex1.o -o ex1 && ./ex1 ; echo $?

global _start

section .data
    b   db  0x11
    w   dw  0x2222
    d   dd  0x33333333
    q   dq  0x4444444444444444
    arr dq  1, 2, 3, 4

section .bss
    tmp resq 1

section .text
_start:
    ; MOV reg, imm (immediate)
    mov rax, 0x1122334455667788

    ; MOV reg, reg
    mov rbx, rax

    ; MOV reg, [mem] (loads)
    xor rcx, rcx          ; clear RCX so CL load is well-defined
    mov cl, byte [b]      ; loads 1 byte into CL (upper bits of RCX unchanged -> here zero)

    mov dx, word [w]      ; loads 2 bytes into DX (upper bits of RDX unchanged)
    mov eax, dword [d]    ; loads 4 bytes into EAX (in x86-64 this also zero-extends into RAX)
    mov r8,  qword [q]    ; loads 8 bytes into R8

    ; MOV [mem], reg (stores)
    mov qword [tmp], r8

    ; MOV [mem], imm requires an explicit size
    mov byte  [tmp], 0x7F         ; store 1 byte
    mov word  [tmp], 0x1234       ; store 2 bytes
    mov dword [tmp], 0x89ABCDEF   ; store 4 bytes
    mov qword [tmp], 0x0102030405060708 ; store 8 bytes

    ; MOV does NOT allow memory-to-memory transfer:
    ;   mov [tmp], [q]     ; INVALID (need a register as staging)

    ; Demonstrate "staging" copy: tmp = q
    mov r9, [q]
    mov [tmp], r9

    ; Compute a tiny "checksum" in AL and return it as exit code.
    ; checksum = (b + low8(w) + low8(d) + low8(q) + arr[0]) mod 256
    mov al, 0
    add al, byte [b]
    add al, byte [w]
    add al, byte [d]
    add al, byte [q]
    add al, byte [arr]

    movzx edi, al         ; exit status in EDI (low 8 bits used by Linux shell)
    mov eax, 60           ; sys_exit
    syscall
