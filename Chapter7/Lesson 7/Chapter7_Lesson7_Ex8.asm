; Chapter7_Lesson7_Ex8.asm
; Alignment-sensitive SIMD local storage:
; - movaps requires 16-byte aligned memory operand
; - movups works with unaligned memory (but may be slower)
;
; We keep the program safe by default. Flip RUN_MISALIGNED to 1 to see why alignment matters.

%define SYS_exit 60

%define RUN_MISALIGNED 0

global _start

section .text

_start:
%if RUN_MISALIGNED
    call    misaligned_movaps_demo   ; may fault
%else
    call    aligned_movaps_demo      ; safe
%endif

    xor     edi, edi
    mov     eax, SYS_exit
    syscall

aligned_movaps_demo:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16                  ; 16B local slot, aligned after push rbp

    pxor    xmm0, xmm0
    movaps  [rsp], xmm0              ; aligned store

    mov     rsp, rbp
    pop     rbp
    ret

misaligned_movaps_demo:
    ; Intentionally misalign RSP by pushing an extra register, then use movaps [rsp]
    push    rbp
    mov     rbp, rsp
    push    rbx                      ; breaks alignment
    sub     rsp, 16

    pxor    xmm0, xmm0
    movaps  [rsp], xmm0              ; may fault if [rsp] is not 16B aligned

    add     rsp, 16
    pop     rbx
    pop     rbp
    ret
