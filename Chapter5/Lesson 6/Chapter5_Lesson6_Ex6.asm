bits 64
default rel

global _start
section .text

; Ex6: Trampoline pattern: keep a short conditional branch,
; then use an unconditional near jump to reach a far target.
;
; Motivation:
; - Sometimes you *want* Jcc short (layout discipline / size policy).
; - Or you're targeting a restricted ISA subset (e.g., 8086-style short Jcc only).
;
; Pattern:
;   jcc short .island
;   ... fallthrough ...
;   jmp short .after
; .island:
;   jmp near far_target
; .after:

_start:
    mov eax, 0
    cmp eax, 0
    je short .island

    ; fallthrough path
    mov edi, 1
    jmp short .after

.island:
    jmp near .far_target

.after:
    ; Common exit
    mov eax, 60
    syscall

    ; Put the far target far away (beyond rel8).
    times 300 nop

.far_target:
    mov edi, 0
    mov eax, 60
    syscall
