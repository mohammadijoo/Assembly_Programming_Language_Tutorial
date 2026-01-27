; Chapter5_Lesson2_Ex9.asm
; Programming Exercise (Very Hard) — Dot product + printing in decimal
;
; Compute dot = sum_{i=0..n-1} (int32 A[i])*(int32 B[i]) into a signed 64-bit accumulator,
; then print the result as decimal using a division-based conversion loop.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex9.asm -o Chapter5_Lesson2_Ex9.o
;   ld -o Chapter5_Lesson2_Ex9 Chapter5_Lesson2_Ex9.o
;
; Run:
;   ./Chapter5_Lesson2_Ex9

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
A: dd  10, -20,  30,  40, -50,  60
B: dd  -1,   2,  -3,   4,  -5,   6
n equ ($-A)/4

msg: db "dot=", 0
msg_len equ $-msg-1

nl: db 10

section .bss
outbuf: resb 32

section .text
global _start

; ---------------------------------------------
; write(STDOUT, RSI, RDX)
; clobbers: RAX, RDI
write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

; ---------------------------------------------
; print_u64: print unsigned RAX as decimal + newline
; uses outbuf as scratch
; clobbers: RAX, RBX, RCX, RDX, RSI, RDI
print_u64:
    mov rbx, 10
    lea rdi, [outbuf + 31]     ; end
    mov byte [rdi], 10         ; newline
    dec rdi

    ; do-while style conversion: at least one digit
.convert:
    xor edx, edx
    div rbx                    ; unsigned: RDX = rem, RAX = quotient
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert

    inc rdi                    ; point to first digit
    lea rsi, [rdi]
    lea rcx, [outbuf + 32]
    sub rcx, rsi               ; len = end - start
    mov rdx, rcx
    jmp write_stdout

; ---------------------------------------------
; print_i64: print signed RAX as decimal + newline
; clobbers: RAX, RBX, RCX, RDX, RSI, RDI, R8
print_i64:
    test rax, rax
    jns .pos
    ; negative: output '-' then print magnitude as unsigned
    mov r8, rax
    ; magnitude = two's complement (~x)+1 (works as unsigned even for INT64_MIN)
    not rax
    add rax, 1

    lea rsi, [minus]
    mov edx, 1
    call write_stdout

    ; fallthrough to unsigned printing (RAX = magnitude)
    jmp print_u64

.pos:
    jmp print_u64

minus: db "-"

_start:
    ; print "dot="
    lea rsi, [msg]
    mov edx, msg_len
    call write_stdout

    ; dot product loop
    xor rax, rax                ; accumulator (signed 64-bit)
    lea rsi, [A]
    lea rdi, [B]
    mov ecx, n

.loop:
    movsxd r8, dword [rsi]       ; r8 = (int64)A[i]
    movsxd r9, dword [rdi]       ; r9 = (int64)B[i]
    imul r8, r9                  ; r8 = product
    add rax, r8                  ; acc += product
    add rsi, 4
    add rdi, 4
    dec ecx
    jnz .loop

    ; print result (signed)
    call print_i64

    xor edi, edi
    mov eax, SYS_exit
    syscall
