; Chapter6_Lesson1_Ex10.asm
; Exercise Solution: Stack alignment checker + deliberate misalignment.
; SysV AMD64 expects the CALL site to maintain alignment such that callee entry has RSP % 16 == 0.
;
; We implement:
;   int is_rsp_aligned_16_at_entry(void) -> returns 1 if aligned, else 0
; and demonstrate both aligned and misaligned calls.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex10.asm -o ex10.o
;   ld ex10.o -o ex10

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

is_rsp_aligned_16_at_entry:
    mov rax, rsp
    and rax, 15
    cmp rax, 0
    sete al                    ; AL=1 if equal
    movzx eax, al
    ret

_start:
    ; 1) aligned call (normal)
    call is_rsp_aligned_16_at_entry
    mov r12d, eax              ; save result in non-volatile reg for later comparison

    ; 2) deliberately misalign by 8 bytes, then call again
    sub rsp, 8
    call is_rsp_aligned_16_at_entry
    add rsp, 8

    ; If first result==1 and second result==0 => exit 0, else exit 1.
    cmp r12d, 1
    jne .fail
    cmp eax, 0
    jne .fail

    xor edi, edi
    mov eax, 60
    syscall

.fail:
    mov edi, 1
    mov eax, 60
    syscall
