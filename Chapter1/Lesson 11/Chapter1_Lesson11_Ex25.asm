extern h
global call_h_win64

call_h_win64:
    sub rsp, 40         ; 32 shadow + 8 alignment safety
    mov rcx, 11         ; a
    mov rdx, 22         ; b
    mov r8,  33         ; c
    call h
    add rsp, 40
    ret
