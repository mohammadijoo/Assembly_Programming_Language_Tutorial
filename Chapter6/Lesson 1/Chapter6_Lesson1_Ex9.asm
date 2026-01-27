; Chapter6_Lesson1_Ex9.asm
; Exercise Solution: Indirect calls via a function-pointer jump table.
; Implement dispatch(op, a, b):
;   op=0:add, 1:sub, 2:mul, 3:xor ; invalid op -> return -1
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex9.asm -o ex9.o
;   ld ex9.o -o ex9
; Run:
;   ./ex9 ; echo $?  (example computes (7*9)=63 => exit 63)

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL dispatch

SECTION .rodata
; table of function pointers (relative works with DEFAULT REL)
op_table:
    dq op_add, op_sub, op_mul, op_xor

SECTION .text

; uint64_t op_add(uint64_t a, uint64_t b)
op_add:
    lea rax, [rdi + rsi]
    ret

op_sub:
    mov rax, rdi
    sub rax, rsi
    ret

op_mul:
    mov rax, rdi
    imul rax, rsi
    ret

op_xor:
    mov rax, rdi
    xor rax, rsi
    ret

; int64_t dispatch(uint64_t op, uint64_t a, uint64_t b)
; args: RDI=op, RSI=a, RDX=b
dispatch:
    cmp rdi, 3
    ja .bad                    ; op > 3
    ; load function pointer: op_table[op]
    mov rax, [rel op_table + rdi*8]
    ; set args to target: a in RDI, b in RSI
    mov rdi, rsi
    mov rsi, rdx
    call rax                   ; indirect call
    ret

.bad:
    mov rax, -1
    ret

_start:
    mov rdi, 2                 ; op=mul
    mov rsi, 7                 ; a
    mov rdx, 9                 ; b
    call dispatch              ; rax = 63

    mov edi, eax
    mov eax, 60
    syscall
