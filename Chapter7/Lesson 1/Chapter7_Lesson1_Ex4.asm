; Chapter 7 - Lesson 1
; Example 4: Why stack alignment matters (MOVAPS requires 16-byte aligned memory)
;
; Key idea:
;   - CALL pushes an 8-byte return address.
;   - On SysV AMD64, a callee that wants to use aligned SIMD locals often ensures
;     that (RSP % 16) == 0 before using movaps/movdqa on stack memory.
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4

global _start

section .data
msg: db "Aligned MOVAPS to stack succeeded.",10
msg_len: equ $-msg

section .text

_start:
    ; CALL misaligns the callee's RSP by 8 bytes (because it pushes RIP).
    call use_movaps_stack

    ; print success message and exit
    mov rdi, msg
    mov rsi, msg_len
    call write_buf

    xor edi, edi
    mov eax, 60
    syscall

; use_movaps_stack():
;   - Creates a stack frame with 16-byte aligned local storage
;   - Writes XMM0 to stack and reads it back with MOVAPS
use_movaps_stack:
    push rbp
    mov rbp, rsp

    ; At this point, RSP % 16 == 8 (typical after CALL + PUSH RBP).
    ; We want 16 aligned space for a 16-byte local, so allocate 32 bytes:
    ;   16 bytes local + 16 bytes padding (restores alignment).
    sub rsp, 32

    ; Zero xmm0 and perform aligned store/load to [rsp] (16-byte aligned now)
    pxor xmm0, xmm0
    movaps [rsp], xmm0
    movaps xmm1, [rsp]

    leave
    ret

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret
