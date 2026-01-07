; Chapter 3 - Lesson 3 (Ex12) - Exercise 4 Solution
; Very hard: Build a generic SUM_ARRAY macro that supports DB/DW/DD/DQ arrays.
; The macro emits specialized code based on element size at assembly time.
;
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;   ./ex12

default rel
global _start

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Exercise 4: SUM_ARRAY macro for element sizes 1/2/4/8", 10
msg_len    equ $-msg

arr_b  db 5,10,15,20
arr_b_n equ 4

arr_w  dw 100,200,300
arr_w_n equ 3

arr_d  dd 100000,200000
arr_d_n equ 2

arr_q  dq 7, 11, 13, 17, 19
arr_q_n equ 5

section .bss
outbuf  resb 128

section .text

%macro SUM_ARRAY 4
    ; %1 base label
    ; %2 count (immediate)
    ; %3 elem_size (1/2/4/8)
    ; %4 destination 64-bit register
    xor %4, %4
    xor ecx, ecx
%%loop:
    cmp ecx, %2
    je %%done
%if %3 = 1
    movzx edx, byte [%1 + rcx]
    add %4, rdx
%elif %3 = 2
    movzx edx, word [%1 + rcx*2]
    add %4, rdx
%elif %3 = 4
    mov edx, dword [%1 + rcx*4]
    movzx rdx, edx
    add %4, rdx
%elif %3 = 8
    add %4, qword [%1 + rcx*8]
%else
    %error Unsupported element size
%endif
    inc ecx
    jmp %%loop
%%done:
%endmacro

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_hex64:
    push rbx
    push rcx
    push rdx
    mov rbx, outbuf
    mov rcx, 16
.loop:
    mov rdx, rax
    shr rdx, 60
    and edx, 0x0F
    mov dl, byte [hex_digits + rdx]
    mov byte [rbx], dl
    inc rbx
    shl rax, 4
    loop .loop
    mov byte [rbx], 10
    inc rbx
    mov rsi, outbuf
    mov rdx, rbx
    sub rdx, rsi
    call write_stdout
    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    SUM_ARRAY arr_b, arr_b_n, 1, rax
    call print_hex64

    SUM_ARRAY arr_w, arr_w_n, 2, rax
    call print_hex64

    SUM_ARRAY arr_d, arr_d_n, 4, rax
    call print_hex64

    SUM_ARRAY arr_q, arr_q_n, 8, rax
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
