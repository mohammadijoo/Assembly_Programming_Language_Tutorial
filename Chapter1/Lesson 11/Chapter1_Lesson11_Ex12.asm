; x86 (32-bit), stdcall:
; int add2_stdcall(int a, int b);
global add2_stdcall
add2_stdcall:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp+8]
    add  eax, [ebp+12]

    pop  ebp
    ret  8         ; callee cleans 2 args * 4 bytes
