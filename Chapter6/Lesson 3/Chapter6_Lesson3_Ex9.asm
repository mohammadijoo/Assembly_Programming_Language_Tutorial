; Chapter6_Lesson3_Ex9.asm
; Example 9: "ABI helper" macros for SysV AMD64 stack-argument access.
; This is a small, practical "header-like" utility that you can paste into
; many files (often saved as an .inc and included).
;
; IMPORTANT: This helper assumes you establish a frame pointer (RBP).
; With a frame pointer:
;   [rbp+8]  = return address
;   [rbp+16] = 7th integer argument
;   [rbp+24] = 8th integer argument
;   ...
; General formula for k>=7:
;   arg_k is at [rbp + 16 + 8*(k-7)] = [rbp + 8*(k-5)]
;
; Build/run: this file is a macro library, not a standalone program.

%macro PROLOGUE 0
    push    rbp
    mov     rbp, rsp
%endmacro

%macro EPILOGUE 0
    pop     rbp
    ret
%endmacro

%macro GET_SYSV_INT_ARG 2
    ; GET_SYSV_INT_ARG <dest_reg>, <k>
    ; k is 1-based
    %if %2 = 1
        mov %1, rdi
    %elif %2 = 2
        mov %1, rsi
    %elif %2 = 3
        mov %1, rdx
    %elif %2 = 4
        mov %1, rcx
    %elif %2 = 5
        mov %1, r8
    %elif %2 = 6
        mov %1, r9
    %else
        mov %1, [rbp + 8*(%2-5)]
    %endif
%endmacro

; Demonstration (uncomment and wrap in a program if desired):
; PROLOGUE
; GET_SYSV_INT_ARG rax, 8
; EPILOGUE
