; Chapter 3 - Lesson 11 - Example 3
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
;   ./ex3
;
; Purpose:
;   Instantiate aligned and packed structs, access fields by offsets,
;   and highlight that unaligned integer loads work on x86-64 (but can be slower).

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    msg1 db "Reading PERSON fields",10,0
    msg2 db "  id     = ",0
    msg3 db "  age    = ",0
    msg4 db "  salary = ",0

    msg5 db 10,"Reading PERSON_PACKED fields",10,0
    msg6 db "  id     = ",0
    msg7 db "  age    = ",0
    msg8 db "  salary = ",0

    msg9 db 10,"Note: packed salary address mod 8 = ",0
    nl db 10

hex_lut db "0123456789ABCDEF"

struc PERSON
    .id     resd 1
    .age    resb 1
    align 8
    .salary resq 1
endstruc

struc PERSON_PACKED
    .id     resd 1
    .age    resb 1
    .salary resq 1
endstruc

    align 16
person1:
    istruc PERSON
        at PERSON.id,     dd 12345
        at PERSON.age,    db 37
        at PERSON.salary, dq 900000
    iend

    ; Force this to be misaligned on purpose:
    db 0x00
person2:
    istruc PERSON_PACKED
        at PERSON_PACKED.id,     dd 54321
        at PERSON_PACKED.age,    db 19
        at PERSON_PACKED.salary, dq 7777777
    iend

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

_start:
    ; PERSON (aligned)
    lea rsi, [msg1]
    call print_z

    lea rsi, [msg2]
    mov eax, [person1 + PERSON.id]
    movzx rax, eax
    call print_labeled_hex

    lea rsi, [msg3]
    movzx rax, byte [person1 + PERSON.age]
    call print_labeled_hex

    lea rsi, [msg4]
    mov rax, [person1 + PERSON.salary]
    call print_labeled_hex

    ; PERSON_PACKED (potentially misaligned salary)
    lea rsi, [msg5]
    call print_z

    lea rsi, [msg6]
    mov eax, [person2 + PERSON_PACKED.id]
    movzx rax, eax
    call print_labeled_hex

    lea rsi, [msg7]
    movzx rax, byte [person2 + PERSON_PACKED.age]
    call print_labeled_hex

    lea rsi, [msg8]
    mov rax, [person2 + PERSON_PACKED.salary] ; unaligned qword load is architecturally allowed on x86-64
    call print_labeled_hex

    ; show misalignment remainder of salary address
    lea rsi, [msg9]
    call print_z
    lea rax, [person2 + PERSON_PACKED.salary]
    and rax, 7
    call print_hex64

    lea rsi, [nl]
    mov edx, 1
    call write_buf

    mov eax, SYS_exit
    xor edi, edi
    syscall
