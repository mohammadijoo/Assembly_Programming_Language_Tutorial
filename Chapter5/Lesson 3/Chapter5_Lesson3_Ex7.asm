; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define N 200

section .bss
is_prime resb (N+1)

section .data
msg db "Number of primes <= 200: ", 0

section .text
global _start

_start:
    ; Initialize is_prime[0..N] = 1
    lea rdi, [is_prime]
    mov ecx, (N+1)
    mov al, 1
    rep stosb

    ; is_prime[0] = is_prime[1] = 0
    mov byte [is_prime + 0], 0
    mov byte [is_prime + 1], 0

    ; Sieve
    mov edi, 2                ; p = 2
.p_loop:
    mov eax, edi
    imul eax, edi             ; p*p
    cmp eax, N
    jg .count

    cmp byte [is_prime + rdi], 0
    je .next_p

    ; mark multiples from p*p, step p
    mov esi, eax              ; m = p*p
.m_loop:
    mov byte [is_prime + rsi], 0
    add esi, edi
    cmp esi, N
    jle .m_loop

.next_p:
    inc edi
    jmp .p_loop

.count:
    xor ebx, ebx              ; count
    mov edi, 2
.c_loop:
    cmp byte [is_prime + rdi], 0
    je .skip
    inc ebx
.skip:
    inc edi
    cmp edi, (N+1)
    jl .c_loop

    lea rsi, [msg]
    call print_cstr
    movzx rax, ebx
    call print_u64
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
