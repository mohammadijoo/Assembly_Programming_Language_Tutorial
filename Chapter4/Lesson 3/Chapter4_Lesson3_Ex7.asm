; Chapter4_Lesson3_Ex7.asm
; Solution: Exercise 1 (Hard) - Bitset library over a bitmap (Linux x86-64, NASM)
; Implements:
;   bitset_test(bitmap_ptr=rdi, nbits=esi, index=edx) -> eax (0/1)
;   bitset_set (bitmap_ptr=rdi, nbits=esi, index=edx) -> eax (old bit)
;   bitset_clr (bitmap_ptr=rdi, nbits=esi, index=edx) -> eax (old bit)
;   bitset_tgl (bitmap_ptr=rdi, nbits=esi, index=edx) -> eax (old bit)
; Notes:
;   - Bitmap is little-endian in memory, but operations define bits by index.
;   - Bounds: if index is out of range, functions return 0 and do not modify.
;
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex7.asm -o Chapter4_Lesson3_Ex7.o
;   ld -o Chapter4_Lesson3_Ex7 Chapter4_Lesson3_Ex7.o
; Run:
;   ./Chapter4_Lesson3_Ex7

BITS 64
default rel
global _start

section .data
msg_title db "Bitset library demo (BTS/BTR/BTC + bounds checks)", 10, 0
msg_init  db "initial word0 = ", 0
msg_t1    db "test bit 3 = ", 0
msg_s5    db "set bit 5 old = ", 0
msg_c3    db "clear bit 3 old = ", 0
msg_t63   db "toggle bit 63 old = ", 0
msg_word0 db "final word0 = ", 0
nl        db 10, 0

section .bss
hexbuf    resb 18

section .data
; 128-bit bitmap (2 qwords) => 128 bits
bitmap    dq 0x0000000000000009, 0x0
nbits     dd 128

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    ; show initial word0
    lea rdi, [msg_init]
    call print_cstr
    mov rdi, [bitmap]
    call print_hex64_nl

    ; test bit 3
    lea rdi, [bitmap]
    mov esi, [nbits]
    mov edx, 3
    call bitset_test
    lea rdi, [msg_t1]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; set bit 5
    lea rdi, [bitmap]
    mov esi, [nbits]
    mov edx, 5
    call bitset_set
    lea rdi, [msg_s5]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; clear bit 3
    lea rdi, [bitmap]
    mov esi, [nbits]
    mov edx, 3
    call bitset_clr
    lea rdi, [msg_c3]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; toggle bit 63
    lea rdi, [bitmap]
    mov esi, [nbits]
    mov edx, 63
    call bitset_tgl
    lea rdi, [msg_t63]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; show final word0
    lea rdi, [msg_word0]
    call print_cstr
    mov rdi, [bitmap]
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

; ----------------------------------------------------------
; Internal: validate index and compute word address + bit idx
; Inputs: bitmap_ptr=rdi, nbits=esi, index=edx
; Outputs:
;   - if valid: rax = address of qword containing bit, ecx = bit_in_word (0..63), ZF=0
;   - if invalid: ZF=1 (caller should return 0)
; Clobbers: r8, r9
; ----------------------------------------------------------
bitset_locate:
    cmp edx, esi
    jae .bad

    mov eax, edx
    shr eax, 6              ; word_index = index / 64
    and edx, 63             ; bit_in_word = index % 64
    mov ecx, edx

    lea r8, [rdi + rax*8]   ; address of qword
    mov rax, r8
    or ecx, 1               ; ensure ZF cleared for "valid" path (any nonzero)
    ret

.bad:
    xor eax, eax
    xor ecx, ecx
    test eax, eax           ; set ZF=1
    ret

; bitset_test(...) -> eax 0/1
bitset_test:
    push rbx
    call bitset_locate
    jz .ret0
    mov rbx, [rax]
    bt rbx, rcx
    xor eax, eax
    adc eax, 0
    pop rbx
    ret
.ret0:
    xor eax, eax
    pop rbx
    ret

; bitset_set(...) -> eax oldbit
bitset_set:
    push rbx
    call bitset_locate
    jz .ret0s
    mov rbx, [rax]
    bts rbx, rcx
    mov [rax], rbx
    xor eax, eax
    adc eax, 0
    pop rbx
    ret
.ret0s:
    xor eax, eax
    pop rbx
    ret

; bitset_clr(...) -> eax oldbit
bitset_clr:
    push rbx
    call bitset_locate
    jz .ret0c
    mov rbx, [rax]
    btr rbx, rcx
    mov [rax], rbx
    xor eax, eax
    adc eax, 0
    pop rbx
    ret
.ret0c:
    xor eax, eax
    pop rbx
    ret

; bitset_tgl(...) -> eax oldbit
bitset_tgl:
    push rbx
    call bitset_locate
    jz .ret0t
    mov rbx, [rax]
    btc rbx, rcx
    mov [rax], rbx
    xor eax, eax
    adc eax, 0
    pop rbx
    ret
.ret0t:
    xor eax, eax
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
