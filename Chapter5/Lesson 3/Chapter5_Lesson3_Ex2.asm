; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define ROWS 4
%define COLS 5
%define ELEM_SIZE 4

section .data
; 4x5 signed dword matrix (row-major)
mat dd  3,  1, -2,  7,  9,
        4, -5,  6,  2,  0,
        8,  1,  1, -1,  2,
       -3,  4,  5,  6,  7

msg db "Sum(mat) = ", 0

section .text
global _start

_start:
    ; Sum all elements using two-level nesting: i over rows, j over cols.
    xor r12d, r12d            ; sum in R12 (64-bit accumulator)

    xor edi, edi              ; i = 0
.row:
    xor esi, esi              ; j = 0
.col:
    ; offset_bytes = ((i*COLS) + j) * ELEM_SIZE
    mov eax, edi
    imul eax, COLS
    add eax, esi
    shl eax, 2                ; *4 bytes
    movsxd rax, dword [mat + rax]
    add r12, rax

    inc esi
    cmp esi, COLS
    jl .col

    inc edi
    cmp edi, ROWS
    jl .row

    ; print "Sum(mat) = " then number
    lea rsi, [msg]
    ; compute length of zero-terminated msg
    xor edx, edx
.len:
    cmp byte [rsi + rdx], 0
    je .emit
    inc edx
    jmp .len
.emit:
    call _write_stdout
    mov rax, r12
    call print_s64
    call print_newline

    xor edi, edi
    jmp exit

\
; ----------------------------
; Minimal I/O helpers (Linux)
; ----------------------------
%define SYS_write 1
%define SYS_exit  60

section .bss
numbuf  resb 32
chbuf   resb 1

section .text

; write(fd=1, buf=rsi, len=rdx)
_write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

; BL = character
print_char_bl:
    mov [chbuf], bl
    lea rsi, [chbuf]
    mov edx, 1
    jmp _write_stdout

print_newline:
    mov bl, 10
    jmp print_char_bl

print_space:
    mov bl, ' '
    jmp print_char_bl

; RAX = unsigned 64-bit integer
print_u64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rdi, [numbuf + 31]     ; one past last printable digit slot
    mov byte [rdi], 0

    mov rbx, 10
    cmp rax, 0
    jne .convert

    dec rdi
    mov byte [rdi], '0'
    jmp .emit

.convert:
    ; produce digits in reverse
.loop:
    xor edx, edx
    div rbx                   ; RAX = quotient, RDX = remainder
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jne .loop

.emit:
    lea rsi, [rdi]
    lea rdx, [numbuf + 31]
    sub rdx, rsi              ; len = end - start
    call _write_stdout

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; RAX = signed 64-bit integer
print_s64:
    test rax, rax
    jns .pos
    mov bl, '-'
    call print_char_bl
    neg rax
.pos:
    jmp print_u64

; Exit with status in EDI
exit:
    mov eax, SYS_exit
    syscall
