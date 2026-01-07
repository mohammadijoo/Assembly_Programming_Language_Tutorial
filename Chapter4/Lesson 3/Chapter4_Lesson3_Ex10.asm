; Chapter4_Lesson3_Ex10.asm
; Solution: Exercise 4 (Very Hard) - Find first zero bit in a bitmap
; API:
;   ffz(bitmap_ptr=rdi, nbits=esi) -> eax index of first zero bit, or -1 if none
; Strategy:
;   - Scan qwords
;   - Invert word to turn zeros into ones
;   - Use BSF to locate the first one in the inverted word
;   - Handle final partial word if nbits not multiple of 64
;
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex10.asm -o Chapter4_Lesson3_Ex10.o
;   ld -o Chapter4_Lesson3_Ex10 Chapter4_Lesson3_Ex10.o
; Run:
;   ./Chapter4_Lesson3_Ex10

BITS 64
default rel
global _start

section .data
msg_title db "ffz demo: find first zero bit in bitmap", 10, 0
msg_ans   db "ffz index = ", 0
msg_none  db "no zero bit found", 10, 0
nl        db 10, 0

; 130 bits: two full qwords + 2 bits in third qword (partial)
; Here we set most bits to 1 but leave bit 67 as 0 to test.
bitmap    dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFB, 0x0000000000000003
nbits     dd 130

section .bss
hexbuf    resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    lea rdi, [bitmap]
    mov esi, [nbits]
    call ffz
    cmp eax, -1
    je .none

    lea rdi, [msg_ans]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl
    jmp .done

.none:
    lea rdi, [msg_none]
    call print_cstr

.done:
    mov eax, 60
    xor edi, edi
    syscall

; -----------------------------------------------------------
; ffz(bitmap_ptr=rdi, nbits=esi) -> eax or -1
; -----------------------------------------------------------
ffz:
    push rbx
    push r12
    push r13

    test esi, esi
    jz .none

    ; qword_count = nbits / 64, rem_bits = nbits % 64
    mov eax, esi
    shr eax, 6
    mov r12d, eax                ; full qwords
    mov eax, esi
    and eax, 63
    mov r13d, eax                ; remainder

    xor ebx, ebx                 ; word index i = 0

.scan_full:
    cmp ebx, r12d
    jae .scan_partial
    mov rax, [rdi + rbx*8]
    not rax
    test rax, rax
    jz .next_full
    bsf rcx, rax
    mov eax, ebx
    shl eax, 6
    add eax, ecx
    pop r13
    pop r12
    pop rbx
    ret
.next_full:
    inc ebx
    jmp .scan_full

.scan_partial:
    test r13d, r13d
    jz .none

    ; load partial word, mask off bits beyond rem_bits (treat them as ones)
    mov rax, [rdi + r12*8]
    not rax
    mov ecx, r13d
    mov rdx, 1
    shl rdx, cl
    dec rdx                      ; low mask for valid bits
    and rax, rdx
    test rax, rax
    jz .none
    bsf rcx, rax
    mov eax, r12d
    shl eax, 6
    add eax, ecx
    pop r13
    pop r12
    pop rbx
    ret

.none:
    mov eax, -1
    pop r13
    pop r12
    pop rbx
    ret

; -----------------------
; I/O helpers
; -----------------------
print_cstr:
    push rdi
    call cstr_len
    pop rsi
    mov rdx, rax
    mov edi, 1
    mov eax, 1
    syscall
    ret

cstr_len:
    xor eax, eax
.len_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    ret

print_hex64_nl:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rsi, [hexbuf]
    mov byte [rsi + 0], '0'
    mov byte [rsi + 1], 'x'

    mov rax, rdi
    mov rcx, 16
    lea rbx, [rsi + 2 + 15]

.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    cmp dl, 9
    jbe .digit
    add dl, 7
.digit:
    add dl, '0'
    mov [rbx], dl
    shr rax, 4
    dec rbx
    loop .hex_loop

    mov edi, 1
    lea rsi, [hexbuf]
    mov edx, 18
    mov eax, 1
    syscall

    mov edi, 1
    lea rsi, [nl]
    mov edx, 1
    mov eax, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
