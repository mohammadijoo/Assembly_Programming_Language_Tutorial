; Chapter4_Lesson3_Ex11.asm
; Topic: NASM preprocessor patterns for bitfields (equ, %assign, %if, %error)
; Demonstrates generating masks/shifts at assemble-time, then using them at runtime.
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex11.asm -o Chapter4_Lesson3_Ex11.o
;   ld -o Chapter4_Lesson3_Ex11 Chapter4_Lesson3_Ex11.o
; Run:
;   ./Chapter4_Lesson3_Ex11

BITS 64
default rel
global _start

; ------------------------------
; Bitfield layout (example ISA)
; ------------------------------
; [31:26] opcode (6 bits)
; [25:21] rd     (5 bits)
; [20:16] rs1    (5 bits)
; [15:0]  imm16  (16 bits)

%assign OP_SHIFT   26
%assign OP_LEN     6

%assign RD_SHIFT   21
%assign RD_LEN     5

%assign RS1_SHIFT  16
%assign RS1_LEN    5

%assign IMM_SHIFT  0
%assign IMM_LEN    16

%assign MAX_BITS 32

%if (OP_SHIFT + OP_LEN) > MAX_BITS
  %error "opcode field exceeds 32-bit word"
%endif

%macro MASK 1
  ((1 << (%1)) - 1)
%endmacro

OP_MASK   equ (MASK(OP_LEN)  << OP_SHIFT)
RD_MASK   equ (MASK(RD_LEN)  << RD_SHIFT)
RS1_MASK  equ (MASK(RS1_LEN) << RS1_SHIFT)
IMM_MASK  equ (MASK(IMM_LEN) << IMM_SHIFT)

section .data
msg_title db "Preprocessor-generated masks/shifts for bitfields", 10, 0
msg_w     db "encoded word = ", 0
msg_op    db "opcode = ", 0
msg_rd    db "rd = ", 0
msg_rs1   db "rs1 = ", 0
msg_imm   db "imm16 = ", 0
nl        db 10, 0

section .bss
hexbuf    resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    ; Encode word = (op<<26)|(rd<<21)|(rs1<<16)|(imm16)
    mov eax, 0
    mov ebx, 0x15          ; op = 0b010101 (21)
    mov ecx, 0x1A          ; rd = 26
    mov edx, 0x0F          ; rs1 = 15
    mov esi, 0xBEEF        ; imm16

    shl ebx, OP_SHIFT
    shl ecx, RD_SHIFT
    shl edx, RS1_SHIFT
    shl esi, IMM_SHIFT

    or eax, ebx
    or eax, ecx
    or eax, edx
    or eax, esi

    lea rdi, [msg_w]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; Decode opcode
    lea rdi, [msg_op]
    call print_cstr
    mov ebx, eax
    and ebx, OP_MASK
    shr ebx, OP_SHIFT
    mov rdi, rbx
    call print_hex64_nl

    ; Decode rd
    lea rdi, [msg_rd]
    call print_cstr
    mov ebx, eax
    and ebx, RD_MASK
    shr ebx, RD_SHIFT
    mov rdi, rbx
    call print_hex64_nl

    ; Decode rs1
    lea rdi, [msg_rs1]
    call print_cstr
    mov ebx, eax
    and ebx, RS1_MASK
    shr ebx, RS1_SHIFT
    mov rdi, rbx
    call print_hex64_nl

    ; Decode imm16
    lea rdi, [msg_imm]
    call print_cstr
    mov ebx, eax
    and ebx, IMM_MASK
    shr ebx, IMM_SHIFT
    mov rdi, rbx
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

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
