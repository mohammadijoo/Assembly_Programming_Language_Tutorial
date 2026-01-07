; x86-64 (SysV):
; long add2(long a, long b);
; Inputs:
;   RDI = a
;   RSI = b
; Output:
;   RAX = a+b

global add2_64
add2_64:
    mov rax, rdi
    add rax, rsi
    ret
