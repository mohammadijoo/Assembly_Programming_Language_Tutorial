global call4_win64
section .text
call4_win64:
    ; Windows x64 args:
    ; f in RCX, a in RDX, b in R8, c in R9, d on stack (at entry)
    ;
    ; We will rearrange so that:
    ;   RCX=a, RDX=b, R8=c, R9=d and then call f.

    ; Allocate shadow space (32 bytes) + alignment padding if needed.
    ; Use 40h (64) as a conservative allocation that keeps alignment stable and gives scratch.
    sub rsp, 40h

    ; Save f from RCX before overwriting RCX with a
    mov rax, rcx

    ; Load d: after sub rsp, 64 bytes, the original stack argument location shifts.
    ; At entry, d is at [RSP+8] (return address at [RSP], then next qword).
    ; After sub rsp, d is at [RSP+40h + 8] = [RSP+48h].
    mov r10, [rsp + 48h]

    mov rcx, rdx    ; rcx = a
    mov rdx, r8     ; rdx = b
    mov r8,  r9     ; r8  = c
    mov r9,  r10    ; r9  = d

    call rax

    add rsp, 40h
    ret
