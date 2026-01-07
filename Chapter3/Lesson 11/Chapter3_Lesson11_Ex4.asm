; Chapter 3 - Lesson 11 - Example 4
;
; Build:
;   nasm -felf64 Chapter3_Lesson11_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;   ./ex4
;
; Purpose:
;   Microbenchmark aligned vs misaligned reads using RDTSC.
;   Demonstrate safe unaligned SIMD loads (MOVDQU) vs aligned loads (MOVDQA).
;
; Notes:
;   - Microbenchmarks are noisy: run multiple times, pin CPU, disable frequency scaling if possible.
;   - Alignment penalties vary across microarchitectures and across access patterns.

BITS 64
DEFAULT REL

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define ITER 2000000
%define BUF_SZ 4096           ; power of two

section .data
    msg0 db "Scalar qword loads (buffer size 4096, ITER=2,000,000)",10,0
    msg1 db "  aligned base cycles   = ",0
    msg2 db "  misaligned base cycles = ",0

    msg3 db 10,"SSE2 16-byte loads (MOVDQA vs MOVDQU)",10,0
    msg4 db "  MOVDQA (aligned) cycles = ",0
    msg5 db "  MOVDQU (unaligned) cycles = ",0

hex_lut db "0123456789ABCDEF"

    align 64
buf:
    times BUF_SZ db 0x7F

section .bss
    hexbuf resb 19

section .text
global _start

write_buf:
    mov eax, SYS_write
    mov edi, STDOUT
    syscall
    ret

print_z:
    xor ecx, ecx
.count:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .count
.done:
    mov rdx, rcx
    call write_buf
    ret

print_hex64:
    mov byte [hexbuf+0], '0'
    mov byte [hexbuf+1], 'x'
    mov rbx, rax
    mov rcx, 16
    lea rdi, [hexbuf + 2 + 15]
.hex_loop:
    mov rdx, rbx
    and rdx, 0xF
    mov dl, [hex_lut + rdx]
    mov [rdi], dl
    shr rbx, 4
    dec rdi
    dec rcx
    jnz .hex_loop
    mov byte [hexbuf + 18], 10
    lea rsi, [hexbuf]
    mov edx, 19
    call write_buf
    ret

print_labeled_hex:
    call print_z
    call print_hex64
    ret

; -----------------------------------------
; TSC helpers
; -----------------------------------------
tsc_start:
    xor eax, eax
    cpuid               ; serialize before RDTSC
    rdtsc
    shl rdx, 32
    or rax, rdx
    ret

tsc_stop:
    rdtscp              ; partially serializing after
    shl rdx, 32
    or rax, rdx
    xor eax, eax
    cpuid               ; serialize after
    ret

; -----------------------------------------
; scalar benchmark
; input: rdi = base pointer
; output: rax = cycles
; clobbers: rcx, rbx, rdx, r8, r9
; -----------------------------------------
bench_scalar_qword:
    mov r8, rdi
    call tsc_start
    mov r9, rax          ; start

    xor rax, rax         ; accumulator (prevents dead-code elimination patterns)
    xor rbx, rbx
    mov rcx, ITER
.loop:
    mov rdx, [r8 + rbx]
    add rax, rdx
    add rbx, 8
    and rbx, (BUF_SZ - 8)
    dec rcx
    jnz .loop

    ; mix accumulator into something observable
    mov rdx, rax
    shr rdx, 17
    xor rax, rdx

    call tsc_stop
    sub rax, r9
    ret

; -----------------------------------------
; SIMD benchmark (SSE2)
; input: rdi = base pointer
; output: rax = cycles
; -----------------------------------------
bench_sse_load:
    mov r8, rdi
    call tsc_start
    mov r9, rax

    pxor xmm1, xmm1
    xor rbx, rbx
    mov rcx, ITER
.loop:
    ; This instruction is patched by caller:
    ;   MOVDQA xmm0, [r8 + rbx]  (aligned)
    ; or
    ;   MOVDQU xmm0, [r8 + rbx]  (unaligned)
    db 0x66, 0x0F, 0x6F, 0x04, 0x18   ; MOVDQA xmm0, [rax+rbx] placeholder bytes
    paddq xmm1, xmm0
    add rbx, 16
    and rbx, (BUF_SZ - 16)
    dec rcx
    jnz .loop

    movq rax, xmm1
    call tsc_stop
    sub rax, r9
    ret

_start:
    lea rsi, [msg0]
    call print_z

    ; aligned scalar: buf is 64-aligned; qword aligned trivially
    lea rdi, [buf]
    call bench_scalar_qword
    lea rsi, [msg1]
    call print_labeled_hex

    ; misaligned scalar: buf+1 (forces occasional cache-line splits and store-forwarding quirks)
    lea rdi, [buf + 1]
    call bench_scalar_qword
    lea rsi, [msg2]
    call print_labeled_hex

    lea rsi, [msg3]
    call print_z

    ; --- MOVDQA path: patch instruction bytes to MOVDQA with correct base register (r8)
    ; We encoded a placeholder MOVDQA xmm0, [rax+rbx].
    ; Patch ModRM/SIB to use r8 as base: [r8+rbx] uses REX prefix.
    ; For teaching, we use two separate tiny functions instead of self-modifying code:
    ; We simply call two different loops below.

    ; MOVDQA aligned:
    lea rdi, [buf]          ; 64-aligned and 16-aligned
    call bench_movdqa
    lea rsi, [msg4]
    call print_labeled_hex

    ; MOVDQU unaligned:
    lea rdi, [buf + 1]
    call bench_movdqu
    lea rsi, [msg5]
    call print_labeled_hex

    mov eax, SYS_exit
    xor edi, edi
    syscall

; -----------------------------------------
; Dedicated versions to avoid self-modifying complexity.
; -----------------------------------------
bench_movdqa:
    mov r8, rdi
    call tsc_start
    mov r9, rax
    pxor xmm1, xmm1
    xor rbx, rbx
    mov rcx, ITER
.loop:
    movdqa xmm0, [r8 + rbx]   ; requires 16-byte alignment
    paddq xmm1, xmm0
    add rbx, 16
    and rbx, (BUF_SZ - 16)
    dec rcx
    jnz .loop
    movq rax, xmm1
    call tsc_stop
    sub rax, r9
    ret

bench_movdqu:
    mov r8, rdi
    call tsc_start
    mov r9, rax
    pxor xmm1, xmm1
    xor rbx, rbx
    mov rcx, ITER
.loop:
    movdqu xmm0, [r8 + rbx]   ; works with any alignment
    paddq xmm1, xmm0
    add rbx, 16
    and rbx, (BUF_SZ - 16)
    dec rcx
    jnz .loop
    movq rax, xmm1
    call tsc_stop
    sub rax, r9
    ret
