BITS 64
default rel

global _start

section .bss
align 16
g_tmpbuf resb 32          ; global scratch buffer (NOT re-entrant)

section .data
s1 db "ABCDEF", 0
s2 db "123456", 0
msg1 db "bad_reverse(): output is overwritten on each call (global scratch)", 10
msg1_len equ $-msg1
msg2 db "good_reverse(): caller supplies output buffer (re-entrant)", 10
msg2_len equ $-msg2

section .text
_start:
    ; Call bad_reverse twice; both pointers alias the same global buffer.
    lea rdi, [s1]
    call bad_reverse
    mov rbx, rax           ; p1

    lea rdi, [s2]
    call bad_reverse
    mov rcx, rax           ; p2 (same as p1)

    ; Print note (we won't print the strings themselves to keep the demo short).
    lea rdi, [msg1]
    mov esi, msg1_len
    call write_str

    ; Now demonstrate good_reverse with caller-provided buffers (two distinct stack buffers).
    sub rsp, 64
    lea rdi, [s1]
    lea rsi, [rsp+0]       ; out1
    mov edx, 6
    call good_reverse_n

    lea rdi, [s2]
    lea rsi, [rsp+32]      ; out2
    mov edx, 6
    call good_reverse_n

    lea rdi, [msg2]
    mov esi, msg2_len
    call write_str

    add rsp, 64

    mov eax, 60
    xor edi, edi
    syscall

; bad_reverse(in=rdi) -> rax = &g_tmpbuf
; Reverses a 0-terminated string into a global scratch buffer.
bad_reverse:
    ; find length
    xor ecx, ecx
.len_loop:
    mov al, [rdi+rcx]
    test al, al
    jz .len_done
    inc rcx
    jmp .len_loop
.len_done:
    ; rcx = len (<= 31 assumed)
    lea rsi, [g_tmpbuf]
    mov rax, rsi           ; return pointer

    ; reverse copy: for i=0..len-1: out[i]=in[len-1-i]
    xor r8d, r8d
.copy_loop:
    cmp r8, rcx
    jae .term
    mov r9, rcx
    dec r9
    sub r9, r8
    mov dl, [rdi+r9]
    mov [rsi+r8], dl
    inc r8
    jmp .copy_loop
.term:
    mov byte [rsi+rcx], 0
    ret

; good_reverse_n(in=rdi, out=rsi, n=edx) -> rax=out
; Reverses exactly n bytes (no terminator handling).
good_reverse_n:
    mov rax, rsi
    mov ecx, edx
    test ecx, ecx
    jz .done
    dec rcx
    xor r8d, r8d
.loop:
    mov dl, [rdi+rcx]
    mov [rsi+r8], dl
    inc r8
    dec rcx
    cmp rcx, -1
    jne .loop
.done:
    ret

write_str:
    mov edx, esi
    mov rsi, rdi
    mov edi, 1
    mov eax, 1
    syscall
    ret
