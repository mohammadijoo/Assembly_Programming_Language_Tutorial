; Chapter5_Lesson10_Ex8.asm
; Defensive Control Flow — Safe Jump Table Dispatch (bounds check then indirect jump)
; SysV AMD64 ABI
;
; int32_t dispatch_op(int32_t op, int32_t a, int32_t b, uint32_t* err);
;   edi = op   (0..3)
;   esi = a
;   edx = b
;   rcx = err (optional)
; Returns:
;   eax = result (or 0 on error)
; Side effect:
;   *err = 0 ok, 1 invalid op, 2 divide-by-zero
;
; ops:
;   0: a + b
;   1: a - b
;   2: a * b  (lower 32 bits)
;   3: a / b  (checked for b==0)

BITS 64
default rel

global dispatch_op
section .text

dispatch_op:
    test rcx, rcx
    jz   .chk
    mov  dword [rcx], 0

.chk:
    cmp  edi, 3
    ja   .badop

    jmp  qword [rel .jt + rdi*8]

.op_add:
    lea  eax, [esi + edx]
    ret

.op_sub:
    mov  eax, esi
    sub  eax, edx
    ret

.op_mul:
    mov  eax, esi
    imul eax, edx
    ret

.op_div:
    test edx, edx
    jz   .div0
    mov  eax, esi
    cdq
    idiv edx
    ret

.badop:
    test rcx, rcx
    jz   .ret0
    mov  dword [rcx], 1
.ret0:
    xor  eax, eax
    ret

.div0:
    test rcx, rcx
    jz   .ret0b
    mov  dword [rcx], 2
.ret0b:
    xor  eax, eax
    ret

section .rodata
align 8
.jt:
    dq .op_add, .op_sub, .op_mul, .op_div
