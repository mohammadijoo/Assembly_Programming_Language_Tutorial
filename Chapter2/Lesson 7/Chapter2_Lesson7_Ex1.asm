; Chapter 2 - Lesson 7 (Execution Flow) - Example 1
; Build (Linux x86-64, NASM):
;   nasm -f elf64 Chapter2_Lesson7_Ex1.asm -o ex1.o
;   ld ex1.o -o ex1
; Run:
;   ./ex1

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
msg_start  db "Start", 10
len_start  equ $-msg_start

msg_A      db "Took path A", 10
len_A      equ $-msg_A

msg_B      db "Took path B", 10
len_B      equ $-msg_B

msg_done   db "Done", 10
len_done   equ $-msg_done

SECTION .text
_start:
    ; Straight-line execution starts at _start.
    mov eax, 1              ; SYS_write
    mov edi, 1              ; STDOUT
    lea rsi, [msg_start]
    mov edx, len_start
    syscall

    ; A conditional decision typically ends a basic block.
    ; Here we branch based on AL (simulating a runtime condition).
    mov al, 1               ; change to 0 to take path B
    test al, al
    jz  .pathB              ; if ZF=1 => AL == 0

.pathA:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_A]
    mov edx, len_A
    syscall
    jmp .done               ; unconditional control transfer

.pathB:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_B]
    mov edx, len_B
    syscall

.done:
    mov eax, 1
    mov edi, 1
    lea rsi, [msg_done]
    mov edx, len_done
    syscall

    mov eax, 60             ; SYS_exit
    xor edi, edi            ; status = 0
    syscall
