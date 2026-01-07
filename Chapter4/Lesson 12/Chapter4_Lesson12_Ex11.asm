; Chapter 4 - Lesson 12 (Ex11) — Programming Exercise Solution 2
; Hard: strlen using REPNE SCASB, with correct DF handling and careful implicit registers.
; Goal: compute length of a zero-terminated string in RAX.
; Contract: preserves RBX and RBP (illustrative; not a formal ABI here).
; Validation: checks against expected length and exits 0/1.

bits 64
default rel
global _start

section .data
s:      db "flag_clobber_and_partial_regs", 0
expected_len: dq 28

section .text
strlen_scasb:
    ; Input:  RDI = pointer to string
    ; Output: RAX = length (bytes, excluding terminator)
    ; Clobbers: RCX, RDI, AL
    push    rbx
    push    rbp

    cld                         ; must be forward unless contract says otherwise
    xor     eax, eax            ; AL=0 for terminator search
    mov     rcx, -1             ; "infinite" count

    repne scasb                 ; implicit: scans [RDI] for AL, increments RDI, decrements RCX
    ; After match, RCX = ~len-1 (because started at -1), and RDI points past the terminator.
    not     rcx
    dec     rcx                 ; subtract 1 for terminator
    mov     rax, rcx

    pop     rbp
    pop     rbx
    ret

_start:
    lea     rdi, [s]
    call    strlen_scasb

    cmp     rax, [expected_len]
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
