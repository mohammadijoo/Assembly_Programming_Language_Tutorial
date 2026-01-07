; Chapter3_Lesson10_Ex3.asm
; Bit test and bit modification instructions: BT / BTS / BTR / BTC.
; Demonstrates bit-string semantics on memory operands (index selects word+bit).
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex3.asm && ld -o ex3 Chapter3_Lesson10_Ex3.o
; Run:      ./ex3

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_init: db "bitmap initial: ",0
msg_bts:  db "after BTS bit 70: ",0
msg_bt:   db "BT bit 70 (CF): ",0
msg_btr:  db "after BTR bit 70: ",0
msg_btc:  db "after BTC bit 3:  ",0
msg_cf0:  db "CF=0",10,0
msg_cf1:  db "CF=1",10,0

hexdigits: db "0123456789ABCDEF"

SECTION .bss
hexbuf:  resb 19
bitmap:  resq 2              ; 128-bit bitset (2 qwords)

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

print_hex64:
    lea rsi, [rel hexbuf]
    mov byte [rsi+0], '0'
    mov byte [rsi+1], 'x'
    mov rax, rdi
    lea rbx, [rel hexdigits]
    mov rcx, 16
.loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx+rdx]
    mov [rsi+1+rcx], dl
    shr rax, 4
    dec rcx
    jnz .loop
    mov byte [rsi+18], 10
    mov rdx, 19
    jmp write_buf

print_bitmap:
    ; prints bitmap[1] then bitmap[0] (high then low), one per line
    mov rdi, [rel bitmap+8]
    call print_hex64
    mov rdi, [rel bitmap]
    call print_hex64
    ret

_start:
    ; Initialize bitmap to 0
    mov qword [rel bitmap], 0
    mov qword [rel bitmap+8], 0

    lea rsi, [rel msg_init]
    call print_cstr
    call print_bitmap

    ; BTS bit 70 (sets the bit and copies the old bit into CF).
    ; For a memory operand, the CPU treats it as a bit-string; index 70 selects:
    ; qword_index = 70 / 64 = 1, bit_in_qword = 70 % 64 = 6.
    mov eax, 70
    bts qword [rel bitmap], rax

    lea rsi, [rel msg_bts]
    call print_cstr
    call print_bitmap

    ; BT bit 70 (loads that bit into CF)
    mov eax, 70
    bt qword [rel bitmap], rax
    lea rsi, [rel msg_bt]
    call print_cstr
    jc .cf_is_1
    lea rsi, [rel msg_cf0]
    jmp .cf_print
.cf_is_1:
    lea rsi, [rel msg_cf1]
.cf_print:
    call print_cstr

    ; BTR bit 70 (clears it; old value goes to CF)
    mov eax, 70
    btr qword [rel bitmap], rax
    lea rsi, [rel msg_btr]
    call print_cstr
    call print_bitmap

    ; BTC bit 3 toggles bit 3 in the first qword
    mov eax, 3
    btc qword [rel bitmap], rax
    lea rsi, [rel msg_btc]
    call print_cstr
    call print_bitmap

    xor edi, edi
    mov eax, SYS_exit
    syscall
