; Chapter2_Lesson9_Ex12.asm
; Programming Exercise Solution 1: overlap-safe memmove for qwords.
; Prototype (SysV-like):
;   memmove_qwords(dst=rdi, src=rsi, count=rcx) ; count in qwords
; Preserves: none (educational routine).
;
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;
; Expected run result (exit status): 4

default rel
global _start

section .data
buf dq 1,2,3,4,5,6,7,8

section .text
; rdi=dst, rsi=src, rcx=count(qwords)
memmove_qwords:
    test rcx, rcx
    jz .done

    ; If dst is below src, forward copy is safe.
    ; Else if dst is at/after src_end, forward copy is safe.
    ; Otherwise copy backward.
    lea r8, [rsi + rcx*8]          ; r8 = src_end

    cmp rdi, rsi
    jb .forward

    cmp rdi, r8
    jae .forward

.backward:
    lea rsi, [rsi + rcx*8 - 8]     ; point at last qword
    lea rdi, [rdi + rcx*8 - 8]
.bwd_loop:
    mov rax, [rsi]
    mov [rdi], rax
    sub rsi, 8
    sub rdi, 8
    dec rcx
    jnz .bwd_loop
    ret

.forward:
.fwd_loop:
    mov rax, [rsi]
    mov [rdi], rax
    add rsi, 8
    add rdi, 8
    dec rcx
    jnz .fwd_loop
    ret

.done:
    ret

_start:
    ; Overlapping move: dst = buf+16 bytes (2 qwords), src = buf, count=6 qwords
    lea rdi, [buf + 16]
    lea rsi, [buf]
    mov ecx, 6
    call memmove_qwords

    ; Validate by XOR-reducing all 8 qwords; expected low byte = 4.
    lea rbx, [buf]
    xor eax, eax
    mov ecx, 8
.xor_loop:
    xor eax, dword [rbx]           ; low 32-bits are sufficient for small numbers here
    add rbx, 8
    dec ecx
    jnz .xor_loop

    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall
