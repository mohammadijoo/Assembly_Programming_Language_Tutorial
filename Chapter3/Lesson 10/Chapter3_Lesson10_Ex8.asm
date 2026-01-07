; Chapter3_Lesson10_Ex8.asm
; BMI2 PEXT/PDEP (scatter-gather bitfields) with a software fallback.
; CPUID.(EAX=7, ECX=0):EBX bit 8 indicates BMI2 support.
;
; Task demonstrated:
; - Extract selected bits from x into a dense field using PEXT (or fallback).
; - Deposit that dense field into a new set of positions using PDEP (or fallback).
;
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex8.asm && ld -o ex8 Chapter3_Lesson10_Ex8.o
; Run:      ./ex8

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_x:     db "x        = ",0
msg_msrc:  db "src_mask = ",0
msg_mdst:  db "dst_mask = ",0
msg_pext:  db "pext     = ",0
msg_pdep:  db "pdep     = ",0
msg_soft:  db "software path used",10,0

hexdigits: db "0123456789ABCDEF"

SECTION .bss
hexbuf: resb 19

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

has_bmi2:
    mov eax, 0
    cpuid
    cmp eax, 7
    jb .no
    mov eax, 7
    xor ecx, ecx
    cpuid
    bt ebx, 8               ; BMI2 bit
    jc .yes
.no:
    xor eax, eax
    test eax, eax           ; ZF=1
    ret
.yes:
    mov eax, 1
    test eax, eax           ; ZF=0
    ret

;--------------------------------------------
; soft_pext(rdi=x, rsi=mask) -> rax=dense
; Extracts bits from x where mask has 1s, packing them into low bits of rax.
;--------------------------------------------
soft_pext:
    xor rax, rax            ; result
    xor rcx, rcx            ; output bit position
.loop:
    test rsi, rsi
    jz .done
    ; find lowest set bit in mask
    mov rdx, rsi
    and rdx, -rsi           ; lowbit = mask & -mask
    ; if x has that bit, set bit rcx in rax
    test rdi, rdx
    jz .skip_set
    bts rax, rcx
.skip_set:
    ; clear that bit in mask
    xor rsi, rdx
    inc rcx
    jmp .loop
.done:
    ret

;--------------------------------------------
; soft_pdep(rdi=dense, rsi=mask) -> rax=scattered
; Deposits low bits of dense into positions where mask has 1s.
;--------------------------------------------
soft_pdep:
    xor rax, rax
    xor rcx, rcx            ; input bit position in dense
.loop:
    test rsi, rsi
    jz .done
    mov rdx, rsi
    and rdx, -rsi
    bt rdi, rcx
    jnc .skip_or
    or rax, rdx
.skip_or:
    xor rsi, rdx
    inc rcx
    jmp .loop
.done:
    ret

_start:
    mov rbx, 0x0123456789ABCDEF
    mov r12, 0x00F000F000F000F0 ; pick 4 bits out of each 16-bit chunk
    mov r13, 0x0003000300030003 ; deposit into low 2 bits of each 16-bit chunk (example)

    lea rsi, [rel msg_x]
    call print_cstr
    mov rdi, rbx
    call print_hex64

    lea rsi, [rel msg_msrc]
    call print_cstr
    mov rdi, r12
    call print_hex64

    lea rsi, [rel msg_mdst]
    call print_cstr
    mov rdi, r13
    call print_hex64

    call has_bmi2
    jz .software

    ; BMI2 path:
    ; pext dense <- x using src_mask
    pext rax, rbx, r12
    lea rsi, [rel msg_pext]
    call print_cstr
    mov rdi, rax
    call print_hex64

    ; pdep scattered <- dense into dst_mask
    pdep rax, rax, r13
    lea rsi, [rel msg_pdep]
    call print_cstr
    mov rdi, rax
    call print_hex64
    jmp .done

.software:
    lea rsi, [rel msg_soft]
    call print_cstr
    mov rdi, rbx
    mov rsi, r12
    call soft_pext
    lea rsi, [rel msg_pext]
    call print_cstr
    mov rdi, rax
    call print_hex64

    mov rdi, rax
    mov rsi, r13
    call soft_pdep
    lea rsi, [rel msg_pdep]
    call print_cstr
    mov rdi, rax
    call print_hex64

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall
