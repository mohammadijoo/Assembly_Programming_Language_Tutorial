BITS 64
default rel
global _start

; Ex9: Preserving CF vs preserving ALL flags.
; - INC/DEC preserve CF but clobber many other flags.
; - LEA does not modify flags at all (useful when flags are live across arithmetic).

section .data
    rflags_before dq 0
    rflags_after_inc dq 0
    rflags_after_lea dq 0

section .text
_start:
    ; Establish a non-trivial flag state
    mov rax, 0x7FFFFFFFFFFFFFFF
    add rax, 1                  ; OF=1, ZF=0, SF=1, CF=0
    stc                         ; CF=1 (force it)
    pushfq
    pop qword [rflags_before]

    ; INC: CF preserved (=1), but OF/ZF/SF/AF/PF updated from the increment
    inc rax
    pushfq
    pop qword [rflags_after_inc]

    ; Restore a similar arithmetic state, then use LEA to do +1 without flag changes
    mov rax, 0x7FFFFFFFFFFFFFFF
    add rax, 1                  ; OF=1, SF=1, CF=0
    stc                         ; CF=1 again
    lea rax, [rax + 1]          ; arithmetic without flag changes
    pushfq
    pop qword [rflags_after_lea]

    mov eax, 60
    xor edi, edi
    syscall
