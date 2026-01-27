BITS 64
default rel

global _start

section .data
msg db "FRAME macros: compile-time local layout with aligned allocation", 10
msg_len equ $-msg

section .text
; --- Frame macros (header-like content inside this .asm) -----------------
%macro FRAME_BEGIN 0
    push rbp
    mov rbp, rsp
    %assign __frame_bytes 0
%endmacro

%macro LOCAL_QWORD 1
    %assign __frame_bytes __frame_bytes + 8
    %define %1 (-__frame_bytes)
%endmacro

%macro LOCAL_BYTES 2
    %assign __frame_bytes __frame_bytes + %2
    %define %1 (-__frame_bytes)
%endmacro

%macro FRAME_ALLOC 0
    ; round __frame_bytes up to 16 (SysV alignment after push rbp)
    %assign __frame_alloc ((__frame_bytes + 15) & ~15)
    sub rsp, __frame_alloc
%endmacro

%macro FRAME_END 0
    leave
    ret
%endmacro
; ------------------------------------------------------------------------

_start:
    mov rdi, 9
    mov rsi, 4
    mov rdx, 2
    call affine3          ; returns (x + y)*z + bias where bias is a local constant

    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    mov eax, 60
    xor edi, edi
    syscall

; affine3(x=rdi, y=rsi, z=rdx) -> rax
affine3:
    FRAME_BEGIN
    LOCAL_QWORD x_loc
    LOCAL_QWORD y_loc
    LOCAL_QWORD z_loc
    LOCAL_QWORD bias_loc
    FRAME_ALLOC

    mov [rbp + x_loc], rdi
    mov [rbp + y_loc], rsi
    mov [rbp + z_loc], rdx
    mov qword [rbp + bias_loc], 7

    mov rax, [rbp + x_loc]
    add rax, [rbp + y_loc]
    imul rax, [rbp + z_loc]
    add rax, [rbp + bias_loc]

    FRAME_END

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
