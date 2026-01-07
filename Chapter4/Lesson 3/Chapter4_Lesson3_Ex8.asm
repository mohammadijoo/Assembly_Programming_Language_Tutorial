; Chapter4_Lesson3_Ex8.asm
; Solution: Exercise 2 (Very Hard) - Robust bitfield extract/insert API
; Adds stricter validation and supports corner cases without undefined shifts:
;   bf_extract_u64(w, start, len) with invalid range rejection
;   bf_insert_u64(w, field, start, len) with truncation + invalid range rejection
;
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex8.asm -o Chapter4_Lesson3_Ex8.o
;   ld -o Chapter4_Lesson3_Ex8 Chapter4_Lesson3_Ex8.o
; Run:
;   ./Chapter4_Lesson3_Ex8

BITS 64
default rel
global _start

section .data
msg_title db "Robust bitfield extract/insert (edge cases covered)", 10, 0
msg_w     db "W = ", 0
msg_e1    db "extract(start=0,len=64) = ", 0
msg_e2    db "extract(start=60,len=8) invalid => ", 0
msg_i1    db "insert(start=8,len=8,field=0xAB) => ", 0
nl        db 10, 0

W         dq 0x0123456789ABCDEF

section .bss
hexbuf    resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    mov rax, [W]
    lea rdi, [msg_w]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; full extract
    mov rdi, [W]
    mov esi, 0
    mov edx, 64
    call bf_extract_u64
    lea rdi, [msg_e1]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; invalid extract
    mov rdi, [W]
    mov esi, 60
    mov edx, 8
    call bf_extract_u64
    lea rdi, [msg_e2]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; insert byte into bits 8..15
    mov rdi, [W]
    mov rsi, 0xAB
    mov edx, 8
    mov ecx, 8
    call bf_insert_u64
    lea rdi, [msg_i1]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

; bf_extract_u64(w=rdi, start=esi, len=edx) -> rax
bf_extract_u64:
    ; len==0 => 0
    test edx, edx
    jz .zero

    ; len==64 => valid only if start==0
    cmp edx, 64
    jne .range
    test esi, esi
    jnz .zero
    mov rax, rdi
    ret

.range:
    ; reject if start+len > 64
    mov eax, esi
    add eax, edx
    cmp eax, 64
    ja .zero

    ; mask = (1<<len)-1 (len 1..63)
    mov ecx, edx
    mov rax, 1
    shl rax, cl
    dec rax

    ; (w >> start) & mask
    mov ecx, esi
    mov rbx, rdi
    shr rbx, cl
    and rbx, rax
    mov rax, rbx
    ret

.zero:
    xor eax, eax
    ret

; bf_insert_u64(w=rdi, field=rsi, start=edx, len=ecx) -> rax
bf_insert_u64:
    ; len==0 => w
    test ecx, ecx
    jz .ret_w

    ; len==64 => valid only if start==0
    cmp ecx, 64
    jne .range2
    test edx, edx
    jnz .ret_w
    mov rax, rsi
    ret

.range2:
    ; reject if start+len > 64
    mov eax, edx
    add eax, ecx
    cmp eax, 64
    ja .ret_w

    ; lowmask = (1<<len)-1 (len 1..63)
    mov r8d, ecx
    mov ecx, r8d
    mov r9, 1
    shl r9, cl
    dec r9

    ; positioned mask = lowmask << start
    mov ecx, edx
    mov r10, r9
    shl r10, cl

    ; clear in w: w & ~positioned_mask
    mov rax, rdi
    not r10
    and rax, r10

    ; truncate field and shift
    and rsi, r9
    mov ecx, edx
    shl rsi, cl

    ; merge
    or rax, rsi
    ret

.ret_w:
    mov rax, rdi
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
