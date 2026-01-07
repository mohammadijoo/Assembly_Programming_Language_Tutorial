; Chapter 3 - Lesson 13 Exercise Solution 3 (Very Hard):
; Compute ULP distance between two binary32 numbers by bitwise "ordering transform".
; File: Chapter3_Lesson13_Ex11.asm
;
; Definition used:
;   - If either input is NaN: return -1.
;   - Otherwise:
;       map(bits):
;           if sign bit is 1 (negative): ordered = 0x80000000 - bits
;           else                         ordered = bits + 0x80000000
;       ulp_distance = abs(ordered(a) - ordered(b))
;
; This mapping yields a monotone integer domain over all non-NaN floats, so adjacent floats
; have distance 1 in that domain (except across NaN and some special discontinuities).
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;   ./ex11

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"
%include "Chapter3_Lesson13_Ex2.asm"

section .rodata
msg_title: db "Exercise Solution 3: ULP distance for binary32", 0
msg_hdr:   db "format: a_bits  b_bits  dist (decimal; -1 means NaN involved)", 0
msg_spc:   db "  ", 0

pairs:
    dd 0x3F800000, 0x3F800001      ; 1.0 and next float
    dd 0x3F800000, 0x3F800002      ; distance 2
    dd 0xBF800000, 0xBF7FFFFF      ; -1.0 and next toward 0
    dd 0x80000000, 0x00000000      ; -0 and +0 (distance should be 0 or small depending mapping)
    dd 0x7F7FFFFF, 0x7F800000      ; max finite and +inf (adjacent in encoding space)
    dd 0x7FC00001, 0x3F800000      ; NaN and 1.0 -> -1
pairs_end:

section .text
global _start

; fp32_ordered_u32(eax=bits) -> eax=ordered_u32
fp32_ordered_u32:
    bt eax, 31
    jc .neg
    add eax, 0x80000000
    ret
.neg:
    mov edx, 0x80000000
    sub edx, eax
    mov eax, edx
    ret

; fp32_ulp_distance(eax=a_bits, edx=b_bits) -> eax=distance (unsigned), or eax=0xFFFFFFFF for NaN
fp32_ulp_distance:
    push rbx

    ; NaN check
    mov ebx, eax
    call fp32_is_nan
    test al, al
    jnz .nan

    mov eax, edx
    call fp32_is_nan
    test al, al
    jnz .nan

    ; order(a)
    mov eax, ebx
    call fp32_ordered_u32
    mov ebx, eax

    ; order(b)
    mov eax, edx
    call fp32_ordered_u32

    ; distance = abs(a - b)
    sub eax, ebx
    jnc .done
    neg eax
.done:
    pop rbx
    ret

.nan:
    mov eax, 0xFFFFFFFF
    pop rbx
    ret

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    lea rdi, [msg_hdr]
    call print_cstr
    call print_nl

    lea rbx, [pairs]
.loop:
    cmp rbx, pairs_end
    jae .exit

    mov eax, dword [rbx]
    mov edx, dword [rbx+4]

    ; print a_bits
    mov edi, eax
    call print_hex32
    lea rdi, [msg_spc]
    call print_cstr

    ; print b_bits
    mov edi, edx
    call print_hex32
    lea rdi, [msg_spc]
    call print_cstr

    ; distance
    call fp32_ulp_distance
    cmp eax, 0xFFFFFFFF
    jne .print_dist
    mov rdi, -1
    call print_i64
    call print_nl
    add rbx, 8
    jmp .loop

.print_dist:
    movzx rdi, eax
    call print_u64
    call print_nl

    add rbx, 8
    jmp .loop

.exit:
    mov eax, SYS_exit
    xor edi, edi
    syscall
