; abi_sysv64.inc (example fragment)
%ifndef ABI_SYSV64_INC
%define ABI_SYSV64_INC 1

; SysV AMD64: caller-saved = rax, rcx, rdx, rsi, rdi, r8-r11
; callee-saved = rbx, rbp, r12-r15
%define SYSV_CALLEE_SAVED_MASK 0xF0F0  ; illustrative, not executable

%macro SYSV_PROLOGUE 0
    push rbp
    mov rbp, rsp
%endmacro

%macro SYSV_EPILOGUE 0
    pop rbp
    ret
%endmacro

%endif