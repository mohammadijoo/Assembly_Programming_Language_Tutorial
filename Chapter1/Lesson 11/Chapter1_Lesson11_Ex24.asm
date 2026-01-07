extern g
global f_sysv

f_sysv:
    ; Input: RDI=x
    ; We will call g(x). Ensure stack alignment before CALL.
    sub rsp, 8          ; aligns RSP for the call sequence on SysV
    call g              ; g returns in RAX
    add rsp, 8

    add rax, 1
    ret
