; x86 (32-bit), cdecl:
; int add2(int a, int b);
; Stack on entry:
;   [ESP+4]  = a
;   [ESP+8]  = b

global add2
add2:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp+8]      ; a
    add  eax, [ebp+12]     ; a + b

    pop  ebp
    ret
