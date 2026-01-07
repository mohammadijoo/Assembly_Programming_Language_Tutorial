; Chapter 3 - Lesson 11 - Programming Exercise 3 (Solution)
;
; Task:
;   Implement memcpy_aligned(dst=rdi, src=rsi, len=rdx) with:
;     - If dst and src are both 16-byte aligned and len is multiple of 16:
;         copy using MOVDQA in a loop.
;     - Otherwise:
;         copy using MOVDQU (unaligned) in 16-byte chunks and a tail.
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;   ./ex8

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg0 db "memcpy_aligned demo",10,0
    msg1 db "  dst aligned, src aligned, len 256 -> uses MOVDQA path",10,0
    msg2 db "  dst unaligned, src aligned, len 256 -> uses MOVDQU path",10,0
    msg3 db "  checksum(dst[0..31]) = ",0

hex_lut db "0123456789ABCDEF"

    align 16
src_buf:
    ; 256 bytes pattern
    %assign i 0
    %rep 256
        db i
        %assign i i+1
    %endrep

    align 16
dst_buf:
    times 320 db 0

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

; -----------------------------------------
; memcpy_aligned(dst=rdi, src=rsi, len=rdx)
; returns: rax = dst
; clobbers: rcx, r8, r9, xmm0
; -----------------------------------------
memcpy_aligned:
    mov rax, rdi

    ; Fast-path predicate:
    ;   (dst|src) mod 16 == 0  AND  len mod 16 == 0
    mov r8, rdi
    or  r8, rsi
    and r8, 15
    jnz .unaligned_path
    test rdx, 15
    jnz .unaligned_path

.aligned_path:
    mov rcx, rdx
    shr rcx, 4            ; number of 16-byte blocks
    jz .done
.a_loop:
    movdqa xmm0, [rsi]
    movdqa [rdi], xmm0
    add rsi, 16
    add rdi, 16
    dec rcx
    jnz .a_loop
    jmp .done

.unaligned_path:
    ; copy 16-byte chunks using MOVDQU
    mov rcx, rdx
    shr rcx, 4
    jz .tail
.u_loop:
    movdqu xmm0, [rsi]
    movdqu [rdi], xmm0
    add rsi, 16
    add rdi, 16
    dec rcx
    jnz .u_loop

.tail:
    ; copy remaining bytes (0..15)
    mov rcx, rdx
    and rcx, 15
    jz .done
.t_loop:
    mov r9b, [rsi]
    mov [rdi], r9b
    inc rsi
    inc rdi
    dec rcx
    jnz .t_loop

.done:
    ret

; checksum first 32 bytes at rdi (sum of bytes) -> rax
checksum32:
    xor eax, eax
    xor rcx, rcx
.loop:
    movzx edx, byte [rdi + rcx]
    add eax, edx
    inc rcx
    cmp rcx, 32
    jne .loop
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; Case 1: aligned dst and src
    lea rsi, [msg1]
    call print_z
    lea rdi, [dst_buf]
    lea rsi, [src_buf]
    mov rdx, 256
    call memcpy_aligned

    lea rdi, [dst_buf]
    call checksum32
    lea rsi, [msg3]
    movzx rax, eax
    call print_labeled_hex

    ; Case 2: unaligned dst (+1)
    lea rsi, [msg2]
    call print_z
    lea rdi, [dst_buf + 1]
    lea rsi, [src_buf]
    mov rdx, 256
    call memcpy_aligned

    lea rdi, [dst_buf + 1]
    call checksum32
    lea rsi, [msg3]
    movzx rax, eax
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall
