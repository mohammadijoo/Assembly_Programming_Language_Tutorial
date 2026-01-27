; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define A_R 2
%define A_C 3
%define B_R 3
%define B_C 2

section .data
; A is 2x3, B is 3x2, C is 2x2
A dd  1,  2,  3,
      4,  5,  6

B dd  7,  8,
      9, 10,
     11, 12

C dd  0, 0,
      0, 0

msg db "C = A*B (2x2):", 0

section .text
global _start

_start:
    ; C[i][j] = sum_k A[i][k] * B[k][j]
    xor edi, edi              ; i
.i_loop:
    xor esi, esi              ; j
.j_loop:
    xor r10d, r10d            ; sum (64-bit in R10)

    xor ecx, ecx              ; k
.k_loop:
    ; load A[i][k]
    mov eax, edi
    imul eax, A_C
    add eax, ecx
    movsxd rax, dword [A + rax*4]

    ; load B[k][j]
    mov edx, ecx
    imul edx, B_C
    add edx, esi
    movsxd rbx, dword [B + rdx*4]

    imul rax, rbx
    add r10, rax

    inc ecx
    cmp ecx, A_C              ; A_C == B_R
    jl .k_loop

    ; store into C[i][j] (truncate to dword for demo)
    mov eax, edi
    imul eax, B_C
    add eax, esi
    mov [C + rax*4], r10d

    inc esi
    cmp esi, B_C
    jl .j_loop

    inc edi
    cmp edi, A_R
    jl .i_loop

    ; print C as 2x2
    lea rsi, [msg]
    call print_cstr
    call print_newline

    xor edi, edi
.row:
    xor esi, esi
.col:
    mov eax, edi
    imul eax, B_C
    add eax, esi
    movsxd rax, dword [C + rax*4]
    call print_s64
    call print_space

    inc esi
    cmp esi, B_C
    jl .col

    call print_newline
    inc edi
    cmp edi, A_R
    jl .row

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
