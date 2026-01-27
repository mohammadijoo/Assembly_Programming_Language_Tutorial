BITS 64
default rel

global _start

section .data
data db "BANANA_BANDANA", 0

msg db "Exercise Solution: byte histogram using a 256-entry local array on the stack", 10
msg_len equ $-msg

lbl_A db "A: "
lbl_A_len equ $-lbl_A
lbl_B db "B: "
lbl_B_len equ $-lbl_B
lbl_N db "N: "
lbl_N_len equ $-lbl_N
lbl_US db "_: "
lbl_US_len equ $-lbl_US

section .text
_start:
    lea rdi, [msg]
    mov esi, msg_len
    call write_str

    lea rdi, [data]
    call count_bytes_demo

    mov eax, 60
    xor edi, edi
    syscall

; count_bytes_demo(str=rdi)
; Builds histogram[256] of byte counts using a stack local array.
; Then prints counts for 'A','B','N','_' as decimal.
count_bytes_demo:
    push rbp
    mov rbp, rsp
    ; locals:
    ;   [rbp-8]   = saved str pointer
    ;   [rbp-2064]..[rbp-17] = histogram (256 qwords = 2048 bytes)
    sub rsp, 2064          ; 2048 + 16 for saved ptr/padding (16-aligned)

    mov [rbp-8], rdi       ; save str

    ; zero histogram: RDI=dst, RCX=256, RAX=0
    lea rdi, [rbp-2064]
    xor eax, eax
    mov ecx, 256
    rep stosq

    ; iterate bytes
    mov rdi, [rbp-8]       ; str
.loop:
    movzx eax, byte [rdi]
    test al, al
    jz .done

    ; histogram[al]++
    lea rbx, [rbp-2064]
    mov ecx, eax
    shl rcx, 3
    add qword [rbx+rcx], 1

    inc rdi
    jmp .loop

.done:
    lea rbx, [rbp-2064]    ; histogram base

    ; Print A
    lea rdi, [lbl_A]
    mov esi, lbl_A_len
    call write_str
    mov rdi, [rbx + ('A'*8)]
    call write_u64_ln

    ; Print B
    lea rdi, [lbl_B]
    mov esi, lbl_B_len
    call write_str
    mov rdi, [rbx + ('B'*8)]
    call write_u64_ln

    ; Print N
    lea rdi, [lbl_N]
    mov esi, lbl_N_len
    call write_str
    mov rdi, [rbx + ('N'*8)]
    call write_u64_ln

    ; Print _
    lea rdi, [lbl_US]
    mov esi, lbl_US_len
    call write_str
    mov rdi, [rbx + ('_'*8)]
    call write_u64_ln

    leave
    ret

; write_u64_ln(val=rdi): prints unsigned decimal + newline
write_u64_ln:
    push rbp
    mov rbp, rsp
    sub rsp, 48            ; 32 bytes buffer + padding (multiple of 16)

    lea rsi, [rbp-32]      ; buf base
    mov edx, 32            ; cap
    call u64_to_dec         ; rax=ptr, ecx=len

    ; write number
    mov rsi, rax
    mov edx, ecx
    mov edi, 1
    mov eax, 1
    syscall

    ; newline
    mov byte [rbp-1], 10
    lea rsi, [rbp-1]
    mov edx, 1
    mov edi, 1
    mov eax, 1
    syscall

    leave
    ret

; u64_to_dec(val=rdi, buf=rsi, cap=edx) -> rax=ptr_to_digits, ecx=len
u64_to_dec:
    mov rax, rdi
    lea r8, [rsi+rdx]      ; end
    xor ecx, ecx

    test rax, rax
    jnz .loop
    dec r8
    mov byte [r8], '0'
    mov ecx, 1
    mov rax, r8
    ret

.loop:
    xor edx, edx
    mov r9, 10
    div r9
    dec r8
    add dl, '0'
    mov [r8], dl
    inc ecx
    test rax, rax
    jnz .loop
    mov rax, r8
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
