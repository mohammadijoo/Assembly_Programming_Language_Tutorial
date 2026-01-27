; Chapter5_Lesson10_Ex6.asm
; Defensive Control Flow — Safe Signed Division (div0 + INT_MIN/-1)
; SysV AMD64 ABI
;
; int32_t div_s32_checked(int32_t a, int32_t b, uint32_t* err);
;   edi = a
;   esi = b
;   rdx = err (optional)
; Returns:
;   eax = quotient on success (or 0 on error)
; Side effect:
;   *err = 0 ok, 1 divide-by-zero, 2 overflow (INT_MIN / -1)
;
; Notes:
; - idiv writes remainder in EDX, so any error code must be stored after idiv.

BITS 64
default rel

global div_s32_checked
section .text

div_s32_checked:
    ; default err=0
    test rdx, rdx
    jz   .check_div
    mov  dword [rdx], 0

.check_div:
    test esi, esi
    jz   .div0

    ; overflow case: INT_MIN / -1
    cmp  edi, 0x80000000
    jne  .do_div
    cmp  esi, -1
    jne  .do_div
    jmp  .ovf

.do_div:
    mov  eax, edi
    cdq                             ; EDX:EAX sign-extend EAX
    idiv esi
    ; quotient in EAX
    ret

.div0:
    test rdx, rdx
    jz   .ret0
    mov  dword [rdx], 1
.ret0:
    xor  eax, eax
    ret

.ovf:
    test rdx, rdx
    jz   .ret0b
    mov  dword [rdx], 2
.ret0b:
    xor  eax, eax
    ret
