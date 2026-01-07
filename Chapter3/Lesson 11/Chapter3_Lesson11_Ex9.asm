; Chapter 3 - Lesson 11 - Programming Exercise 4 (Solution)
;
; Task:
;   Given a base pointer and stride, count how many 8-byte loads would cross
;   a 64-byte cache line boundary over N iterations.
;
;   A qword load at address A crosses a 64B line if:
;       (A mod 64) > 56
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define N 100000

section .data
    msg0 db "Cache-line crossing counter for qword loads (N=100,000)",10,0
    msg1 db "  base aligned (mod 64 == 0), stride 8  -> crossings = ",0
    msg2 db "  base + 1 (misaligned), stride 8       -> crossings = ",0
    msg3 db "  base + 57, stride 8                   -> crossings = ",0

hex_lut db "0123456789ABCDEF"

    align 64
buf:
    times 4096 db 0x11

section .bss
    hexbuf resb 19

section .text
global _start

write_buf:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

print_z:
    xor ecx, ecx
.count:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .count
.done:
    mov rdx, rcx
    call write_buf
    ret

print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'
    mov rbx, rax
    mov rcx, 16
    lea rdi, [hexbuf + 2 + 15]
.hex_loop:
    mov rdx, rbx
    and rdx, 0xF
    mov dl, [hex_lut + rdx]
    mov [rdi], dl
    shr rbx, 4
    dec rdi
    dec rcx
    jnz .hex_loop
    mov byte [hexbuf + 18], 10
    lea rsi, [hexbuf]
    mov edx, 19
    call write_buf
    ret

print_labeled_hex:
    call print_z
    call print_hex64
    ret

; count_crossings_qword(base=rdi, stride=rsi, n=rdx) -> rax
; counts how many qword loads cross 64-byte boundary using predicate (addr&63) > 56
count_crossings_qword:
    xor eax, eax          ; count
    xor rcx, rcx          ; i
.loop:
    mov r8, rdi
    and r8, 63
    cmp r8, 56
    jbe .no
    inc rax
.no:
    add rdi, rsi
    inc rcx
    cmp rcx, rdx
    jne .loop
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; case 1: aligned base
    lea rdi, [buf]
    mov rsi, 8
    mov rdx, N
    call count_crossings_qword
    lea rsi, [msg1]
    call print_labeled_hex

    ; case 2: base + 1
    lea rdi, [buf + 1]
    mov rsi, 8
    mov rdx, N
    call count_crossings_qword
    lea rsi, [msg2]
    call print_labeled_hex

    ; case 3: base + 57 (almost always crossing on qword loads)
    lea rdi, [buf + 57]
    mov rsi, 8
    mov rdx, N
    call count_crossings_qword
    lea rsi, [msg3]
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall
