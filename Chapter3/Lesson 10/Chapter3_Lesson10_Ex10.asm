; Chapter3_Lesson10_Ex10.asm
; Programming Exercise 2 (Solution):
; Build a bounds-checked dynamic bitset API and implement set/clear/test using
; BT/BTS/BTR on a memory bit-string.
;
; API (simple conventions):
;   bitset_test(bit_index=RDI, nbits=RSI, base=RDX) -> AL=0/1, CF reflects bit if in range
;   bitset_set (bit_index=RDI, nbits=RSI, base=RDX) -> sets bit, returns ZF=1 if out of range
;   bitset_clear(...) similarly
;
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex10.asm && ld -o ex10 Chapter3_Lesson10_Ex10.o
; Run:      ./ex10

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg0: db "bit 0  = ",0
msg7: db "bit 7  = ",0
msg64:db "bit 64 = ",0
msg70:db "bit 70 = ",0
msg_oob: db "out-of-range",10,0
msg_0:   db "0",10,0
msg_1:   db "1",10,0

SECTION .bss
bits: resq 2                ; 128 bits total

SECTION .text

write_buf:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

print_cstr:
    xor rdx, rdx
.count:
    cmp byte [rsi+rdx], 0
    je .go
    inc rdx
    jmp .count
.go:
    jmp write_buf

print_bit_al:
    ; AL is 0/1
    test al, al
    jz .zero
    lea rsi, [rel msg_1]
    jmp print_cstr
.zero:
    lea rsi, [rel msg_0]
    jmp print_cstr

;--------------------------------------------
; in_range(bit_index=RDI, nbits=RSI) -> ZF=0 if in range, ZF=1 if out
;--------------------------------------------
in_range:
    cmp rdi, rsi
    jae .out
    mov eax, 1
    test eax, eax           ; ZF=0
    ret
.out:
    xor eax, eax
    test eax, eax           ; ZF=1
    ret

;--------------------------------------------
; bitset_test(bit_index=RDI, nbits=RSI, base=RDX) -> AL=0/1
; Out of range => AL=0 and ZF=1
;--------------------------------------------
bitset_test:
    call in_range
    jz .oob
    bt qword [rdx], rdi      ; CF <- bit
    setc al
    ; ZF=0 (in range) already, but setc may change flags; normalize:
    mov eax, 1
    test eax, eax
    ret
.oob:
    xor eax, eax
    test eax, eax           ; ZF=1
    ret

;--------------------------------------------
; bitset_set(bit_index=RDI, nbits=RSI, base=RDX)
; Out of range => ZF=1, no modification.
;--------------------------------------------
bitset_set:
    call in_range
    jz .oob
    bts qword [rdx], rdi
    mov eax, 1
    test eax, eax           ; ZF=0
    ret
.oob:
    xor eax, eax
    test eax, eax           ; ZF=1
    ret

;--------------------------------------------
; bitset_clear(bit_index=RDI, nbits=RSI, base=RDX)
;--------------------------------------------
bitset_clear:
    call in_range
    jz .oob
    btr qword [rdx], rdi
    mov eax, 1
    test eax, eax           ; ZF=0
    ret
.oob:
    xor eax, eax
    test eax, eax           ; ZF=1
    ret

_start:
    ; Initialize to zero
    mov qword [rel bits], 0
    mov qword [rel bits+8], 0

    ; nbits=128, base=&bits
    lea rdx, [rel bits]
    mov rsi, 128

    ; Set bits 0, 7, 70
    mov rdi, 0
    call bitset_set
    mov rdi, 7
    call bitset_set
    mov rdi, 70
    call bitset_set

    ; Print tests
    lea rsi, [rel msg0]
    call print_cstr
    mov rdi, 0
    call bitset_test
    call print_bit_al

    lea rsi, [rel msg7]
    call print_cstr
    mov rdi, 7
    call bitset_test
    call print_bit_al

    lea rsi, [rel msg64]
    call print_cstr
    mov rdi, 64
    call bitset_test
    call print_bit_al

    lea rsi, [rel msg70]
    call print_cstr
    mov rdi, 70
    call bitset_test
    call print_bit_al

    ; Out of bounds test: bit 200
    mov rdi, 200
    call bitset_test
    jnz .done_print          ; ZF=0 => in range (should not happen)
    lea rsi, [rel msg_oob]
    call print_cstr
.done_print:

    xor edi, edi
    mov eax, SYS_exit
    syscall
