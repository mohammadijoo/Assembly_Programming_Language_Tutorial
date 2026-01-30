; Chapter7_Lesson10_Ex10.asm
; Topic: Stack canary concept (detect corruption of a protected stack frame)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
corrupt     dq 1              ; set to 0 to take the "clean" path

msg_ok      db "Canary verified OK.", 10
msg_ok_len  equ $-msg_ok
msg_trip    db "Canary mismatch detected!", 10
msg_trip_len equ $-msg_trip

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

_start:
    ; Create a frame: [buffer 48 bytes][canary 8 bytes]
    sub rsp, 56
    mov rbp, rsp

    ; Canary = (rsp xor constant). In real systems you want randomness.
    mov rax, rsp
    xor rax, 0x9E3779B97F4A7C15
    mov [rbp + 48], rax

    ; "Work": write within the buffer's bounds (no actual overflow)
    lea rdi, [rbp]
    mov al, 0x41
    mov rcx, 48
    rep stosb

    ; Optional simulated corruption (to show detection without real overflow)
    cmp qword [corrupt], 0
    je .check
    xor qword [rbp + 48], 1

.check:
    mov rdx, rsp
    xor rdx, 0x9E3779B97F4A7C15
    cmp [rbp + 48], rdx
    jne .trip

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout
    add rsp, 56
    xor edi, edi
    jmp exit_

.trip:
    lea rsi, [msg_trip]
    mov edx, msg_trip_len
    call write_stdout
    add rsp, 56
    mov edi, 1
    jmp exit_
