; Chapter3_Lesson10_Ex12.asm
; Programming Exercise 4 (Solution, very hard):
; Generalized "extract then deposit" permutation:
;   y = deposit(extract(x, src_mask), dst_mask)
; where extract packs bits selected by src_mask into low bits (PEXT semantics)
; and deposit scatters low bits into dst_mask positions (PDEP semantics).
;
; Uses BMI2 (PEXT/PDEP) when available; otherwise uses a software path.
;
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex12.asm && ld -o ex12 Chapter3_Lesson10_Ex12.o
; Run:      ./ex12

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_x:    db "x        = ",0
msg_src:  db "src_mask = ",0
msg_dst:  db "dst_mask = ",0
msg_y:    db "y        = ",0
msg_soft: db "software path used",10,0

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
    bt ebx, 8
    jc .yes
.no:
    xor eax, eax
    test eax, eax
    ret
.yes:
    mov eax, 1
    test eax, eax
    ret

soft_pext:
    xor rax, rax            ; dense
    xor rcx, rcx            ; out bit index
.loop:
    test rsi, rsi
    jz .done
    mov rdx, rsi
    and rdx, -rsi           ; lowbit
    test rdi, rdx
    jz .skip
    bts rax, rcx
.skip:
    xor rsi, rdx
    inc rcx
    jmp .loop
.done:
    ret

soft_pdep:
    xor rax, rax            ; scattered
    xor rcx, rcx            ; dense bit index
.loop:
    test rsi, rsi
    jz .done
    mov rdx, rsi
    and rdx, -rsi           ; lowbit position in dst
    bt rdi, rcx
    jnc .skip_or
    or rax, rdx
.skip_or:
    xor rsi, rdx
    inc rcx
    jmp .loop
.done:
    ret

; permute(x=RDI, src_mask=RSI, dst_mask=RDX) -> RAX
permute:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    call has_bmi2
    jz .soft

    pext rax, rbx, r12
    pdep rax, rax, r13
    pop r12
    pop rbx
    ret

.soft:
    lea rsi, [rel msg_soft]
    call print_cstr
    mov rdi, rbx
    mov rsi, r12
    call soft_pext
    mov rdi, rax
    mov rsi, r13
    call soft_pdep
    pop r12
    pop rbx
    ret

_start:
    mov rbx, 0xFEDCBA9876543210
    mov r12, 0x0F0F0F0F0F0F0F0F  ; pick low nibble of each byte
    mov r13, 0x3333333333333333  ; map into low 2 bits of each nibble (illustrative)

    lea rsi, [rel msg_x]
    call print_cstr
    mov rdi, rbx
    call print_hex64

    lea rsi, [rel msg_src]
    call print_cstr
    mov rdi, r12
    call print_hex64

    lea rsi, [rel msg_dst]
    call print_cstr
    mov rdi, r13
    call print_hex64

    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call permute
    lea rsi, [rel msg_y]
    call print_cstr
    mov rdi, rax
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
