; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
; Hard exercise solution: blocked (tiled) matrix multiplication.
; Computes C = A*B for 8x8 dword matrices using block size 2.
; Purpose: demonstrate multi-level nested loops for cache-friendly traversal.

%define N  8
%define BS 2

section .data
A:
    dd 1, 2, 3, 4, 5, 6, 7, 8
    dd 9, 10, 11, 12, 13, 14, 15, 16
    dd 17, 18, 19, 20, 21, 22, 23, 24
    dd 25, 26, 27, 28, 29, 30, 31, 32
    dd 33, 34, 35, 36, 37, 38, 39, 40
    dd 41, 42, 43, 44, 45, 46, 47, 48
    dd 49, 50, 51, 52, 53, 54, 55, 56
    dd 57, 58, 59, 60, 61, 62, 63, 64

B:
    dd 64, 63, 62, 61, 60, 59, 58, 57
    dd 56, 55, 54, 53, 52, 51, 50, 49
    dd 48, 47, 46, 45, 44, 43, 42, 41
    dd 40, 39, 38, 37, 36, 35, 34, 33
    dd 32, 31, 30, 29, 28, 27, 26, 25
    dd 24, 23, 22, 21, 20, 19, 18, 17
    dd 16, 15, 14, 13, 12, 11, 10, 9
    dd 8, 7, 6, 5, 4, 3, 2, 1

msg db "Checksum(C) = ", 0

section .bss
C resd (N*N)

section .text
global _start

_start:
    ; Zero C
    lea rdi, [C]
    mov ecx, (N*N)
    xor eax, eax
    rep stosd

    xor r8d, r8d              ; ii = 0
.ii_loop:
    xor r9d, r9d              ; jj = 0
.jj_loop:
    xor r10d, r10d            ; kk = 0
.kk_loop:
    ; for i in [ii..ii+BS-1]
    mov edi, r8d
.i_loop:
    ; for j in [jj..jj+BS-1]
    mov esi, r9d
.j_loop:
    ; load current C[i][j] into R11D
    mov eax, edi
    imul eax, N
    add eax, esi
    mov r11d, [C + rax*4]

    ; for k in [kk..kk+BS-1]
    mov ecx, r10d
.k_loop:
    ; A[i][k]
    mov eax, edi
    imul eax, N
    add eax, ecx
    movsxd rax, dword [A + rax*4]

    ; B[k][j]
    mov edx, ecx
    imul edx, N
    add edx, esi
    movsxd rbx, dword [B + rdx*4]

    imul rax, rbx
    add r11d, eax             ; accumulate low 32 (values small here)

    inc ecx
    mov edx, r10d
    add edx, BS
    cmp ecx, edx
    jl .k_loop

    ; store updated C[i][j]
    mov eax, edi
    imul eax, N
    add eax, esi
    mov [C + rax*4], r11d

    inc esi
    mov eax, r9d
    add eax, BS
    cmp esi, eax
    jl .j_loop

    inc edi
    mov eax, r8d
    add eax, BS
    cmp edi, eax
    jl .i_loop

    add r10d, BS
    cmp r10d, N
    jl .kk_loop

    add r9d, BS
    cmp r9d, N
    jl .jj_loop

    add r8d, BS
    cmp r8d, N
    jl .ii_loop

    ; checksum all elements of C
    xor r12, r12
    xor edi, edi
.sum:
    movsxd rax, dword [C + rdi*4]
    add r12, rax
    inc edi
    cmp edi, (N*N)
    jl .sum

    lea rsi, [msg]
    call print_cstr
    mov rax, r12
    call print_s64
    call print_newline

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
