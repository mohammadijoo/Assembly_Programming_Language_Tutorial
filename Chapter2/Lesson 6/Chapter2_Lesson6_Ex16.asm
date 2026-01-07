\
; Chapter2_Lesson6_Ex16.asm
; Programming Exercise 3 (Solution): MASM memcmp_u8 (Windows x64 ABI).
;
; Semantics match C memcmp for unsigned bytes:
; - compare byte-by-byte
; - stop at first mismatch or after n bytes
; - return (unsigned)a[i] - (unsigned)b[i] as signed int in EAX
;
; Windows x64:
;   RCX=a, RDX=b, R8=n
; Volatile regs: RAX, RCX, RDX, R8-R11
; Non-volatile regs: RBX, RBP, RSI, RDI, R12-R15 must be preserved if used.
; We use only volatile regs.

option casemap:none
PUBLIC memcmp_u8

.code
memcmp_u8 PROC
    ; if (n == 0) return 0;
    test r8, r8
    jz  L_equal

    xor r9d, r9d                ; i = 0

L_loop:
    ; load bytes
    mov al, byte ptr [rcx + r9]
    mov dl, byte ptr [rdx + r9]
    cmp al, dl
    jne L_diff

    inc r9
    cmp r9, r8
    jb  L_loop

L_equal:
    xor eax, eax
    ret

L_diff:
    ; return (unsigned)al - (unsigned)dl
    movzx eax, al
    movzx edx, dl
    sub eax, edx
    ret
memcmp_u8 ENDP
END
