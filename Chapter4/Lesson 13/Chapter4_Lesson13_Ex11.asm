; Chapter4_Lesson13_Ex11.asm
; Exercise Solution (Very Hard): Microbenchmark aligned vs misaligned loop bodies using RDTSC.
; This is deliberately minimal and *not* a production benchmark harness.
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter4_Lesson13_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;
; Notes:
; - We serialize with LFENCE (reasonable on modern Intel/AMD for TSC ordering).
; - We avoid printing (I/O dominates). We exit with a status code derived from measurements.
; - For real benchmarking, you would repeat trials, pin CPU, disable turbo, etc.

BITS 64
GLOBAL _start

%macro RDTSCP_LIKE 0
    ; Return TSC in RDX:RAX (RAX low) with basic ordering.
    lfence
    rdtsc
    lfence
%endmacro

SECTION .text
_start:
    ; Measure aligned loop
    call measure_aligned
    mov r12, rax

    ; Measure misaligned loop
    call measure_misaligned
    mov r13, rax

    ; Compare: if misaligned is slower, exit(0), else exit(1)
    ; (This is intentionally simplistic; some CPUs may show little difference.)
    cmp r13, r12
    ja  .ok
    mov edi, 1
    jmp .exit
.ok:
    xor edi, edi
.exit:
    mov eax, 60
    syscall

; Returns elapsed cycles in RAX
measure_aligned:
    push rbp
    mov rbp, rsp

    mov ecx, 40000000

    ; Align loop body to 32 bytes
    align 32, db 0x90
.aligned_loop:
    ; Start timing right before the loop begins (first iteration may be cold).
    RDTSCP_LIKE
    shl rdx, 32
    or rax, rdx
    mov r8, rax

    ; Loop body (small, but non-empty)
    xor eax, eax
.loop1:
    add eax, 1
    sub eax, 1
    dec ecx
    jnz .loop1

    RDTSCP_LIKE
    shl rdx, 32
    or rax, rdx
    sub rax, r8

    pop rbp
    ret

; Returns elapsed cycles in RAX
measure_misaligned:
    push rbp
    mov rbp, rsp

    mov ecx, 40000000

    ; Intentionally "misalign" the loop by inserting 1 byte of padding before it.
    ; (The exact misalignment depends on the linker's placement, but this reliably
    ; shifts the loop relative to the aligned version.)
    db 0x90

.misaligned_loop:
    RDTSCP_LIKE
    shl rdx, 32
    or rax, rdx
    mov r8, rax

    xor eax, eax
.loop2:
    add eax, 1
    sub eax, 1
    dec ecx
    jnz .loop2

    RDTSCP_LIKE
    shl rdx, 32
    or rax, rdx
    sub rax, r8

    pop rbp
    ret
