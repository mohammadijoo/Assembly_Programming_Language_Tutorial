; macros_nasm.inc
%ifndef MACROS_NASM_INC
%define MACROS_NASM_INC 1

; Define a global function label with a consistent naming convention.
%macro DEF_FUNC 1
    global %1
    %1:
%endmacro

; Emit a RIP-relative address load (x86-64 PIC-friendly)
%macro LEA_RIP 2
    lea %1, [rel %2]
%endmacro

%endif