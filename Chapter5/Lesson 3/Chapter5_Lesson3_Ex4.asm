; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define N 4
%define ELEM_SIZE 8

section .data
src dq  1,  2,  3,  4,
        5,  6,  7,  8,
        9, 10, 11, 12,
       13, 14, 15, 16

dst dq  0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0

msg db "Transpose(dst) as 4x4 matrix:", 0

section .text
global _start

_start:
    ; dst[j][i] = src[i][j]
    xor edi, edi              ; i
.i_loop:
    xor esi, esi              ; j
.j_loop:
    ; src_off = (i*N + j)*8
    mov eax, edi
    imul eax, N
    add eax, esi
    mov rax, [src + rax*8]

    ; dst_off = (j*N + i)*8
    mov edx, esi
    imul edx, N
    add edx, edi
    mov [dst + rdx*8], rax

    inc esi
    cmp esi, N
    jl .j_loop

    inc edi
    cmp edi, N
    jl .i_loop

    ; print msg then dst matrix
    lea rsi, [msg]
    call print_cstr
    call print_newline

    xor edi, edi              ; row
.pr_row:
    xor esi, esi              ; col
.pr_col:
    mov eax, edi
    imul eax, N
    add eax, esi
    mov rax, [dst + rax*8]
    call print_u64
    call print_space

    inc esi
    cmp esi, N
    jl .pr_col

    call print_newline
    inc edi
    cmp edi, N
    jl .pr_row

    xor edi, edi
    jmp exit

; RSI = zero-terminated string
print_cstr:
    push rdx
    xor edx, edx
.len:
    cmp byte [rsi + rdx], 0
    je .emit
    inc edx
    jmp .len
.emit:
    call _write_stdout
    pop rdx
    ret

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
