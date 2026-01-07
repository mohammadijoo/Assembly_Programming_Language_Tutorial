; Chapter4_Lesson3_Ex3.asm
; Topic: Variable bitfield extract/insert (u64) with safe shift handling (Linux x86-64, NASM)
; Build:
;   nasm -felf64 Chapter4_Lesson3_Ex3.asm -o Chapter4_Lesson3_Ex3.o
;   ld -o Chapter4_Lesson3_Ex3 Chapter4_Lesson3_Ex3.o
; Run:
;   ./Chapter4_Lesson3_Ex3

BITS 64
default rel
global _start

section .data
msg_title   db "Bitfield extract/insert demo (start,len)", 10, 0
msg_w       db "W = ", 0
msg_ext     db "extract(start=13,len=11) = ", 0
msg_ins     db "insert(field=0x5AA,start=13,len=11) => ", 0
nl          db 10, 0

W           dq 0x0123456789ABCDEF

section .bss
hexbuf      resb 18

section .text

_start:
    lea rdi, [msg_title]
    call print_cstr

    mov rax, [W]
    lea rdi, [msg_w]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; extract bits [start..start+len-1]
    mov rdi, rax        ; w
    mov esi, 13         ; start
    mov edx, 11         ; len
    call bf_extract_u64 ; rax = field

    lea rdi, [msg_ext]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    ; insert field 0x5AA into that range
    mov rdi, [W]        ; w
    mov rsi, 0x5AA      ; field
    mov edx, 13         ; start (use edx)
    mov ecx, 11         ; len
    call bf_insert_u64  ; rax = new word

    lea rdi, [msg_ins]
    call print_cstr
    mov rdi, rax
    call print_hex64_nl

    mov eax, 60
    xor edi, edi
    syscall

; ---------------------------------------------------------
; bf_extract_u64(w=rdi, start=esi, len=edx) -> rax=field
; Contracts:
;   - start in [0..63]
;   - len in [0..64]
;   - if len==0 => 0
;   - if len==64 and start==0 => w (full)
;   - if start+len exceeds 64 => returns 0 (reject invalid)
; ---------------------------------------------------------
bf_extract_u64:
    ; reject invalid: if len==0 return 0
    test edx, edx
    jz .zero

    ; if len==64: only valid when start==0
    cmp edx, 64
    jne .check_sum
    test esi, esi
    jnz .zero
    mov rax, rdi
    ret

.check_sum:
    mov eax, esi
    add eax, edx
    cmp eax, 64
    ja .zero

    ; mask = (1<<len)-1 (len in 1..63 here)
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

; ----------------------------------------------------------------------
; bf_insert_u64(w=rdi, field=rsi, start=edx, len=ecx) -> rax=new_word
; Contracts:
;   - start in [0..63]
;   - len in [0..64]
;   - if len==0 => w (no change)
;   - if len==64 and start==0 => field (full replace)
;   - if start+len exceeds 64 => w (reject invalid)
;   - field is truncated to len bits before insertion
; ----------------------------------------------------------------------
bf_insert_u64:
    test ecx, ecx
    jz .ret_w

    cmp ecx, 64
    jne .check_sum2
    test edx, edx
    jnz .ret_w
    mov rax, rsi
    ret

.check_sum2:
    mov eax, edx
    add eax, ecx
    cmp eax, 64
    ja .ret_w

    ; mask = ((1<<len)-1) << start
    mov r8d, ecx
    mov rax, 1
    mov ecx, r8d
    shl rax, cl
    dec rax                  ; low mask
    mov ecx, edx
    shl rax, cl              ; positioned mask in rax

    ; clear target bits in w: w & ~mask
    mov rbx, rdi
    not rax
    and rbx, rax
    not rax                  ; restore mask

    ; truncate field to len bits, then shift to start
    mov rcx, r8
    mov r9, 1
    shl r9, cl
    dec r9                   ; low mask
    and rsi, r9
    mov ecx, edx
    shl rsi, cl

    ; combine
    or rbx, rsi
    mov rax, rbx
    ret

.ret_w:
    mov rax, rdi
    ret

; -----------------------
; I/O helpers (same as Ex1)
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
