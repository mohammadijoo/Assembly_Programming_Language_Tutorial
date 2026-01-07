; Chapter 3 - Lesson 4 (Working with Constants)
; Example 8: Compile-time table generation with %rep/%assign

global _start
default rel

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Square table generated at assembly time (0^2..15^2):", 10
hdr_len      equ $ - hdr

; Generate 16 dwords: i*i
square_table:
%assign i 0
%rep 16
    dd i*i
    %assign i i+1
%endrep

square_bytes  equ $ - square_table
square_elems  equ square_bytes / 4

section .text
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

print_hex64:
    mov rbx, rax
    lea rdi, [hexbuf + 2 + 15]
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop
    lea rsi, [hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

_start:
    lea rsi, [hdr]
    mov edx, hdr_len
    write_stdout

    ; Loop over the table using the compile-time count (square_elems)
    xor ecx, ecx
.loop_tbl:
    cmp ecx, square_elems
    jae .done

    mov eax, [square_table + rcx*4]
    movzx rax, eax
    call print_hex64

    inc ecx
    jmp .loop_tbl

.done:
    xor edi, edi
    exit
