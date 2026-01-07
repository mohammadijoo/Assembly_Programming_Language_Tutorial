; Chapter 3 - Lesson 11 - Programming Exercise 1 (Solution)
;
; Task:
;   Implement an alignment-aware bump allocator from a fixed pool.
;   API:
;       alloc_aligned(size=rdi, align_pow2=rsi) -> rax = pointer or 0
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;   ./ex6

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg0 db "Aligned bump allocator demo",10,0
    msg1 db "  alloc 24, align 16  -> ",0
    msg2 db "  alloc 24, align 64  -> ",0
    msg3 db "  alloc 4000, align 32 -> ",0
    msg4 db "  alloc 128, align 256 -> ",0
    msg5 db "  (0 means out-of-memory)",10,0
    msgR db "    remainder (ptr mod align) = ",0

hex_lut db "0123456789ABCDEF"

section .bss
    hexbuf resb 19

    align 64
pool:       resb 4096
pool_end:

heap_ptr:   resq 1

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
; alloc_aligned(size=rdi, align_pow2=rsi) -> rax
; Requirements:
;   - rsi is a power of two
;   - returns 0 on failure
; Clobbers: rbx, rcx, rdx
; -----------------------------------------
alloc_aligned:
    mov rbx, [heap_ptr]
    test rbx, rbx
    jnz .have_ptr
    lea rbx, [pool]
.have_ptr:
    ; aligned = align_up(rbx, rsi)
    mov rcx, rsi
    dec rcx
    lea rdx, [rbx + rcx]
    not rcx
    and rdx, rcx             ; rdx = aligned pointer

    ; new_ptr = aligned + size
    lea rax, [rdx + rdi]
    lea rcx, [pool_end]
    cmp rax, rcx
    ja .fail

    mov [heap_ptr], rax
    mov rax, rdx
    ret
.fail:
    xor eax, eax
    ret

; -----------------------------------------
; print remainder of ptr modulo alignment
; input: rdi = ptr, rsi = align_pow2
; clobbers: rax, rcx, rdx, rdi
; -----------------------------------------
print_remainder:
    mov rax, rdi
    mov rcx, rsi
    dec rcx
    and rax, rcx
    mov rdx, rax             ; save remainder

    lea rsi, [msgR]
    call print_z

    mov rax, rdx
    call print_hex64
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; Initialize heap_ptr = pool
    lea rax, [pool]
    mov [heap_ptr], rax

    ; alloc 24 align 16
    mov rdi, 24
    mov rsi, 16
    call alloc_aligned
    mov r12, rax
    lea rsi, [msg1]
    call print_labeled_hex
    test r12, r12
    jz .skip1
    mov rdi, r12
    mov rsi, 16
    call print_remainder
.skip1:

    ; alloc 24 align 64
    mov rdi, 24
    mov rsi, 64
    call alloc_aligned
    mov r12, rax
    lea rsi, [msg2]
    call print_labeled_hex
    test r12, r12
    jz .skip2
    mov rdi, r12
    mov rsi, 64
    call print_remainder
.skip2:

    ; alloc 4000 align 32 (likely fails depending on previous allocations)
    mov rdi, 4000
    mov rsi, 32
    call alloc_aligned
    mov r12, rax
    lea rsi, [msg3]
    call print_labeled_hex
    test r12, r12
    jz .skip3
    mov rdi, r12
    mov rsi, 32
    call print_remainder
.skip3:

    ; alloc 128 align 256
    mov rdi, 128
    mov rsi, 256
    call alloc_aligned
    mov r12, rax
    lea rsi, [msg4]
    call print_labeled_hex
    test r12, r12
    jz .skip4
    mov rdi, r12
    mov rsi, 256
    call print_remainder
.skip4:

    lea rsi, [msg5]
    call print_z

    mov eax, SYS_exit
    xor edi, edi
    syscall
