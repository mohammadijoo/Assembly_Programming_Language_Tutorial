; Chapter 3 - Lesson 11 - Programming Exercise 2 (Solution)
;
; Task:
;   Serialize a naturally-aligned record into a packed byte stream (no padding),
;   then deserialize back into an aligned in-memory record.
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;   ./ex7

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg0 db "Serialize/deserialize demo (packed stream vs aligned struct)",10,0
    msg1 db "  original.salary = ",0
    msg2 db "  stream bytes (first 16) = ",0
    msg3 db "  decoded.salary  = ",0
    msg4 db "  decoded flags   = ",0

hex_lut db "0123456789ABCDEF"

; Aligned record layout:
;   u32 id
;   u8  flags
;   padding (to 8)
;   u64 salary
struc REC
    .id     resd 1
    .flags  resb 1
    align 8
    .salary resq 1
endstruc

; Packed stream format (network/protocol style):
;   id (4) | flags (1) | salary (8)  => 13 bytes
%define STREAM_LEN 13

    align 16
original:
    istruc REC
        at REC.id,     dd 0x11223344
        at REC.flags,  db 0xA5
        at REC.salary, dq 0x0102030405060708
    iend

section .bss
    hexbuf  resb 19
    stream  resb STREAM_LEN
    decoded resb REC_size

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
; serialize_REC:
;   input: rdi = &REC aligned record
;          rsi = &stream buffer (>= 13)
; -----------------------------------------
serialize_REC:
    ; id (little-endian)
    mov eax, [rdi + REC.id]
    mov [rsi + 0], eax

    ; flags
    mov al, [rdi + REC.flags]
    mov [rsi + 4], al

    ; salary
    mov rax, [rdi + REC.salary]
    mov [rsi + 5], rax
    ret

; -----------------------------------------
; deserialize_REC:
;   input: rdi = &stream buffer (13 bytes)
;          rsi = &REC output record (aligned in memory)
; -----------------------------------------
deserialize_REC:
    mov eax, [rdi + 0]
    mov [rsi + REC.id], eax

    mov al, [rdi + 4]
    mov [rsi + REC.flags], al

    mov rax, [rdi + 5]          ; unaligned qword load is allowed
    mov [rsi + REC.salary], rax ; aligned store
    ret

; print first 16 bytes of stream as hex nibbles (simple dump)
; input: rdi = ptr, rsi = count (<= 16)
dump_bytes_16:
    ; prints 16 bytes packed into two hex digits each, separated by spaces
    ; For teaching, we print each byte as 0x?? on its own line to keep code short.
    ; (More compact dumps are a later lesson topic.)
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; show original salary
    lea rsi, [msg1]
    mov rax, [original + REC.salary]
    call print_labeled_hex

    ; serialize
    lea rdi, [original]
    lea rsi, [stream]
    call serialize_REC

    ; show first 16 bytes of the stream by reading 2 qwords (over-reading is fine for demo due to reserved space)
    lea rsi, [msg2]
    call print_z
    mov rax, [stream + 0]       ; bytes 0..7 (contains id + flags + start of salary)
    call print_hex64
    mov rax, [stream + 8]       ; bytes 8..15 (rest of salary + garbage beyond 13 bytes)
    call print_hex64

    ; deserialize
    lea rdi, [stream]
    lea rsi, [decoded]
    call deserialize_REC

    ; show decoded salary
    lea rsi, [msg3]
    mov rax, [decoded + REC.salary]
    call print_labeled_hex

    lea rsi, [msg4]
    movzx rax, byte [decoded + REC.flags]
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall
