; file: hosted_main.asm
; x86-64 SysV ABI: main(int argc, char** argv, char** envp)
;   argc in EDI, argv in RSI, envp in RDX (as passed by crt)
;
; We will call printf(const char*, ...).
; SysV varargs: format pointer in RDI, then args in RSI, RDX, RCX, R8, R9.

default rel
global main
extern printf

section .rodata
fmt: db "argc=%d, first_arg=%s", 10, 0

section .text
main:
    ; Save argv (RSI) because we will overwrite registers for printf args
    mov rbx, rsi

    ; If argc > 0, argv[0] is program name (char*)
    ; argv is pointer array of 8-byte pointers on x86-64
    mov rsi, rdi          ; 2nd printf arg: argc (int promoted) in RSI
    mov rdx, [rbx + 0]    ; 3rd printf arg: argv[0] pointer in RDX
    lea rdi, [fmt]        ; 1st printf arg: format in RDI
    xor eax, eax          ; SysV: AL = number of vector registers used for varargs (0 here)
    call printf

    xor eax, eax
    ret
