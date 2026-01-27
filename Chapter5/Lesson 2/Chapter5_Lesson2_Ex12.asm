; Chapter5_Lesson2_Ex12.asm
; Programming Exercise (Very Hard) — Sieve of Eratosthenes (loop-heavy, nested loops)
;
; Count primes up to N using a byte array is_prime[0..N].
; Prints "primes=<count>".
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex12.asm -o Chapter5_Lesson2_Ex12.o
;   ld -o Chapter5_Lesson2_Ex12 Chapter5_Lesson2_Ex12.o

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define N 5000

section .data
msg: db "primes=", 0
msg_len equ $-msg-1

section .bss
is_prime: resb (N+1)
outbuf:   resb 40

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

print_u64_nl:
    mov rbx, 10
    lea rdi, [outbuf + 39]
    mov byte [rdi], 10
    dec rdi
.convert:
    xor edx, edx
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert
    inc rdi
    lea rsi, [rdi]
    lea rcx, [outbuf + 40]
    sub rcx, rsi
    mov rdx, rcx
    jmp write_stdout

_start:
    ; Initialize is_prime[0..N] = 1, then clear 0 and 1.
    lea rdi, [is_prime]
    mov ecx, (N+1)
    mov al, 1
.init_loop:
    mov [rdi], al
    inc rdi
    dec ecx
    jnz .init_loop

    mov byte [is_prime+0], 0
    mov byte [is_prime+1], 0

    xor rbx, rbx        ; RBX = prime count
    mov esi, 2          ; i = 2

.outer:
    cmp esi, (N+1)
    jae .done

    movzx eax, byte [is_prime + rsi]
    test eax, eax
    jz .next_i

    inc rbx             ; found a prime

    ; if i*i > N, skip marking multiples
    mov eax, esi
    imul eax, esi       ; eax = i*i (fits within 32-bit for N=5000)
    cmp eax, N
    ja  .next_i

    ; j = i*i
    mov edi, eax

.inner:
    ; is_prime[j] = 0
    mov byte [is_prime + rdi], 0
    add edi, esi
    cmp edi, N
    jbe .inner

.next_i:
    inc esi
    jmp .outer

.done:
    ; print "primes=<count>"
    lea rsi, [msg]
    mov edx, msg_len
    call write_stdout

    mov rax, rbx
    call print_u64_nl

    xor edi, edi
    mov eax, SYS_exit
    syscall
