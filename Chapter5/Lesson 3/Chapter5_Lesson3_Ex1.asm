; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
section .text
global _start

_start:
    ; Print a 9x9 multiplication table using nested loops.
    ;
    ; Demonstrates the x86 LOOP instruction for the inner loop:
    ;   LOOP label  <=>  RCX = RCX - 1; if (RCX != 0) jump label
    ;
    ; Outer loop: i = 1..9 (EBX)
    ; Inner loop: runs 9 times using RCX as a countdown counter
    ;             and derives j = 10 - RCX (so j goes 1..9).

    mov ebx, 1                ; i = 1
.row_loop:
    mov ecx, 9                ; RCX = 9 iterations
.col_loop:
    ; j = 10 - RCX  (when RCX = 9 => j=1, ... when RCX=1 => j=9)
    mov eax, 10
    sub eax, ecx              ; EAX = j
    mov r8d, eax              ; keep j in R8D

    mov eax, ebx              ; i
    imul eax, r8d             ; eax = i*j
    movzx rax, eax
    call print_u64
    call print_space

    loop .col_loop

    call print_newline

    inc ebx
    cmp ebx, 10
    jl .row_loop

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
