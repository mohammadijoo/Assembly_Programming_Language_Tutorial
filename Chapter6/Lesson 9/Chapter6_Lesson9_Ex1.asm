; Chapter6_Lesson9_Ex1.asm
; Returning a 128-bit value via a register pair (RDX:RAX) on x86-64 (SysV ABI).
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1 ; echo $?
;
; Convention:
;   uint128_t umul128(uint64_t a, uint64_t b);
;   a in RDI, b in RSI
;   return low64 in RAX, high64 in RDX

global _start

section .text

umul128:
    mov     rax, rdi
    mul     rsi                 ; unsigned: RDX:RAX = RAX * RSI
    ret

_start:
    mov     rdi, 0x1122334455667788
    mov     rsi, 0x10
    call    umul128

    ; expected: (a * 16) = (a << 4), high = a >> 60
    mov     rcx, 0x1122334455667788
    shl     rcx, 4
    mov     rbx, 0x1122334455667788
    shr     rbx, 60

    cmp     rax, rcx
    jne     .fail
    cmp     rdx, rbx
    jne     .fail

.ok:
    mov     eax, 60             ; sys_exit
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
