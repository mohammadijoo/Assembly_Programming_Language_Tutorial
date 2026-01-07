; Chapter 3 - Lesson 3 (Ex9) - Exercise 1 Solution
; Hard: Parse packed records (DB/DW/DD/DQ), compute checksum, print as hex.
;
; Record layout (packed):
;   byte  type      @ +0
;   word  len       @ +1
;   dword value     @ +3
;   qword ts        @ +7
; Total size = 15 bytes (REC_SIZE)
;
; Build:
;   nasm -felf64 Chapter3_Lesson3_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9

default rel
global _start

%include "Chapter3_Lesson3_Ex8.asm"

section .data
hex_digits db "0123456789ABCDEF"
msg        db "Exercise 1: checksum over packed records (type+len+value+ts_low32)", 10
msg_len    equ $-msg

; Example records (3 items). Note how directives map to exact widths.
records:
    db 1
    dw 5
    dd 0x01020304
    dq 0x0000000012345678

    db 2
    dw 2
    dd 0x11111111
    dq 0x00000000ABCDEF01

    db 7
    dw 9
    dd 0x80000010
    dq 0x00000000DEADBEEF

records_n equ 3

section .bss
outbuf resb 128

section .text

write_stdout:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_hex64:
    push rbx
    push rcx
    push rdx

    mov rbx, outbuf
    mov rcx, 16
.loop:
    mov rdx, rax
    shr rdx, 60
    and edx, 0x0F
    mov dl, byte [hex_digits + rdx]
    mov byte [rbx], dl
    inc rbx
    shl rax, 4
    loop .loop

    mov byte [rbx], 10
    inc rbx

    mov rsi, outbuf
    mov rdx, rbx
    sub rdx, rsi
    call write_stdout

    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    mov rsi, msg
    mov rdx, msg_len
    call write_stdout

    lea rbx, [records]
    xor rax, rax          ; checksum accumulator (64-bit)
    xor ecx, ecx          ; i = 0

.loop_rec:
    cmp ecx, records_n
    je .done

    ; type (u8)
    movzx edx, byte [rbx + REC_OFF_TYPE]
    add rax, rdx

    ; len (u16)
    LOAD_U16 edx, rbx, REC_OFF_LEN
    add rax, rdx

    ; value (u32)
    LOAD_U32 edx, rbx, REC_OFF_VALUE
    movzx rdx, edx
    add rax, rdx

    ; ts (u64) - only add low 32 bits as a constrained variant (forces careful masking)
    LOAD_U64 rdx, rbx, REC_OFF_TS
    and rdx, 0xFFFFFFFF
    add rax, rdx

    ; advance
    add rbx, REC_SIZE
    inc ecx
    jmp .loop_rec

.done:
    call print_hex64

    mov eax, 60
    xor edi, edi
    syscall
