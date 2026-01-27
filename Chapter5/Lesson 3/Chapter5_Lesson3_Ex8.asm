; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define W 5
%define H 5
%define KW 3
%define KH 3

section .data
; 5x5 image (unsigned bytes), row-major
img db  1,  2,  3,  4,  5,
        6,  7,  8,  9, 10,
       11, 12, 13, 14, 15,
       16, 17, 18, 19, 20,
       21, 22, 23, 24, 25

; 3x3 kernel (signed bytes), e.g., simple edge-like pattern
ker db  1,  0, -1,
        1,  0, -1,
        1,  0, -1

; Output is valid convolution: (H-KH+1) x (W-KW+1) = 3x3 of signed dwords
out dd  0,0,0,
        0,0,0,
        0,0,0

msg db "Checksum(out) = ", 0

section .text
global _start

_start:
    ; out[y][x] = sum_{ky,kx} img[y+ky][x+kx] * ker[ky][kx]
    xor edi, edi              ; y = 0..2
.y_loop:
    xor esi, esi              ; x = 0..2
.x_loop:
    xor r10d, r10d            ; sum (signed 32 within 64)

    xor ecx, ecx              ; ky = 0..2
.ky_loop:
    xor edx, edx              ; kx = 0..2
.kx_loop:
    ; img index = (y+ky)*W + (x+kx)
    mov eax, edi
    add eax, ecx
    imul eax, W
    mov ebx, esi
    add ebx, edx
    add eax, ebx

    movzx r8d, byte [img + rax]       ; pixel (0..255)

    ; ker index = ky*KW + kx
    mov eax, ecx
    imul eax, KW
    add eax, edx
    movsx r9d, byte [ker + rax]       ; coeff (signed)

    mov eax, r8d
    imul eax, r9d                     ; signed product 32-bit
    add r10d, eax

    inc edx
    cmp edx, KW
    jl .kx_loop

    inc ecx
    cmp ecx, KH
    jl .ky_loop

    ; store to out[y][x]
    mov eax, edi
    imul eax, (W-KW+1)
    add eax, esi
    mov [out + rax*4], r10d

    inc esi
    cmp esi, (W-KW+1)
    jl .x_loop

    inc edi
    cmp edi, (H-KH+1)
    jl .y_loop

    ; checksum all out elements
    xor r12d, r12d
    xor edi, edi
.sum_loop:
    movsxd rax, dword [out + rdi*4]
    add r12, rax
    inc edi
    cmp edi, ((H-KH+1)*(W-KW+1))
    jl .sum_loop

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
