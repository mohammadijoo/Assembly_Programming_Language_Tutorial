; Chapter5_Lesson2_Ex10.asm
; Programming Exercise (Very Hard) — Extended Euclidean Algorithm (iterative)
;
; Given a and b (positive), compute gcd(a,b) and coefficients x,y such that:
;   a*x + b*y = gcd(a,b)
; This uses a loop with integer division (IDIV) and state updates.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex10.asm -o Chapter5_Lesson2_Ex10.o
;   ld -o Chapter5_Lesson2_Ex10 Chapter5_Lesson2_Ex10.o

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
a: dq 240
b: dq 46

msg_g: db "gcd=", 0
msg_g_len equ $-msg_g-1
msg_x: db " x=", 0
msg_x_len equ $-msg_x-1
msg_y: db " y=", 0
msg_y_len equ $-msg_y-1
nl: db 10

section .bss
outbuf: resb 40

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

; print_u64: unsigned RAX + optional newline (here: ALWAYS newline)
print_u64:
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

; print_i64: signed RAX + newline
print_i64:
    test rax, rax
    jns .pos
    ; emit '-'
    lea rsi, [minus]
    mov edx, 1
    call write_stdout
    ; magnitude as unsigned
    not rax
    add rax, 1
    jmp print_u64
.pos:
    jmp print_u64

minus: db "-"

_start:
    ; Load inputs
    mov r10, [a]      ; old_r
    mov r11, [b]      ; r

    mov r12, 1        ; old_s
    mov r13, 0        ; s

    mov r14, 0        ; old_t
    mov r15, 1        ; t

.loop:
    test r11, r11
    jz .done

    ; q = old_r / r  (signed division; inputs positive so same as unsigned here)
    mov rax, r10
    cqo                  ; sign-extend into RDX
    idiv r11             ; RAX=q, RDX=rem
    mov r8, rax          ; save q

    ; (old_r, r) = (r, old_r - q*r)
    mov r9, r10          ; tmp_old_r
    mov r10, r11         ; old_r = r
    mov rax, r8
    imul rax, r11        ; q*r
    sub r9, rax          ; old_r - q*r
    mov r11, r9          ; r = old_r - q*r

    ; (old_s, s) = (s, old_s - q*s)
    mov r9, r12
    mov r12, r13
    mov rax, r8
    imul rax, r13
    sub r9, rax
    mov r13, r9

    ; (old_t, t) = (t, old_t - q*t)
    mov r9, r14
    mov r14, r15
    mov rax, r8
    imul rax, r15
    sub r9, rax
    mov r15, r9

    jmp .loop

.done:
    ; old_r = gcd, old_s=x, old_t=y
    lea rsi, [msg_g]
    mov edx, msg_g_len
    call write_stdout
    mov rax, r10
    call print_i64

    lea rsi, [msg_x]
    mov edx, msg_x_len
    call write_stdout
    mov rax, r12
    call print_i64

    lea rsi, [msg_y]
    mov edx, msg_y_len
    call write_stdout
    mov rax, r14
    call print_i64

    xor edi, edi
    mov eax, SYS_exit
    syscall
