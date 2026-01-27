; Chapter 6 - Lesson 11, Exercise 2 (with solution)
; File: Chapter6_Lesson11_Ex9.asm
; Topic: Leaf memmove using REP MOVSB, backward copy with DF=1, restore DF=0
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
; Run:
;   ./ex9 ; exit code 0 means success

global _start

section .data
buf db "ABCDEFGHIJ", 0

section .text

; void* memmove_leaf(void* dst, const void* src, size_t n)
; dst in RDI, src in RSI, n in RDX, returns dst in RAX
memmove_leaf:
    mov rax, rdi             ; return value

    test rdx, rdx
    jz .done

    ; If dst < src, safe to copy forward.
    cmp rdi, rsi
    jb .forward

    ; If dst >= src + n, no overlap => forward is ok.
    lea rcx, [rsi + rdx]
    cmp rdi, rcx
    jae .forward

    ; Overlap with dst after src: copy backward.
    std                       ; DF=1 (reverse)
    lea rdi, [rdi + rdx - 1]
    lea rsi, [rsi + rdx - 1]
    mov rcx, rdx
    rep movsb
    cld                       ; MUST restore DF=0
    jmp .done

.forward:
    cld
    mov rcx, rdx
    rep movsb

.done:
    ret

_start:
    ; Overlapping move: memmove(buf+2, buf, 6) => "ABABCDEF..."
    lea rdi, [buf + 2]
    lea rsi, [buf]
    mov rdx, 6
    call memmove_leaf

    ; Verify first 8 bytes now equal: A B A B C D E F
    ; We'll check buf[0..7] against expected.
    lea rbx, [buf]
    mov al, [rbx+0]
    cmp al, 'A'  ; 65
    jne .fail
    mov al, [rbx+1]
    cmp al, 'B'
    jne .fail
    mov al, [rbx+2]
    cmp al, 'A'
    jne .fail
    mov al, [rbx+3]
    cmp al, 'B'
    jne .fail
    mov al, [rbx+4]
    cmp al, 'C'
    jne .fail
    mov al, [rbx+5]
    cmp al, 'D'
    jne .fail
    mov al, [rbx+6]
    cmp al, 'E'
    jne .fail
    mov al, [rbx+7]
    cmp al, 'F'
    jne .fail

    xor edi, edi
    mov eax, 60
    syscall

.fail:
    mov edi, 1
    mov eax, 60
    syscall
