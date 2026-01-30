; Chapter7_Lesson10_Ex3.asm
; Topic: Overflow-safe pointer arithmetic for base + index*stride with bounds checking
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

bits 64
default rel

%define SYS_write 1
%define SYS_exit  60

section .data
buf:      times 240 db 0       ; 10 records * 24 bytes each
buf_len   equ $-buf
stride    equ 24

idx       dq 9                 ; change to 10 or huge to trigger rejection

msg_ok      db "Address computed safely.", 10
msg_ok_len  equ $-msg_ok
msg_bad     db "Rejected (overflow or out-of-range).", 10
msg_bad_len equ $-msg_bad

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

die:
    ; edi = exit code, rsi/rdx = message
    call write_stdout
    mov eax, SYS_exit
    syscall

_start:
    lea rbx, [buf]            ; base
    mov rcx, buf_len          ; total length
    mov rdx, [idx]            ; index (u64)

    ; Compute offset = idx * stride, detect signed overflow in imul
    mov rax, rdx
    imul rax, stride
    jo .bad

    ; Ensure offset <= buf_len - stride (so record fits fully)
    mov r8, rcx
    sub r8, stride
    jc .bad                   ; buf_len < stride (should not happen here)
    cmp rax, r8
    ja .bad

    ; addr = base + offset, detect carry overflow
    add rax, rbx
    jc .bad

    ; Touch the first byte of the chosen record safely
    mov byte [rax], 0x7F

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    xor edi, edi
    jmp die

.bad:
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    mov edi, 2
    jmp die
