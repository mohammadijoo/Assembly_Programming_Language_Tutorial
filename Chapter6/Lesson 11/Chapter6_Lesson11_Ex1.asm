; Chapter 6 - Lesson 11, Example 1
; File: Chapter6_Lesson11_Ex1.asm
; Topic: Reusable SysV AMD64 prologue/epilogue macros (NASM)
; Notes:
;   - NASM can %include files with any extension; keep .asm for consistency.
;   - These macros assume Linux/SysV AMD64 ABI and 16-byte stack alignment before CALL.

%ifndef CH6_L11_ABI_MACROS_INCLUDED
%define CH6_L11_ABI_MACROS_INCLUDED 1

; -------------------------------
; Syscall numbers (Linux x86-64)
; -------------------------------
%define SYS_write 1
%define SYS_exit  60

; -------------------------------
; ABI facts (SysV AMD64)
; -------------------------------
; - Integer args: RDI, RSI, RDX, RCX, R8, R9
; - Return: RAX
; - Callee-saved: RBX, RBP, R12-R15
; - RSP must be 16-byte aligned *before* any CALL instruction.
; - Red zone: 128 bytes below RSP is preserved across interrupts (not across signals in all cases).
; - DF (direction flag) must be clear on function entry and return for C interoperability.

; -------------------------------
; Align stack before a CALL
; -------------------------------
; At function entry (after CALL), RSP % 16 == 8.
; If you did not push anything, subtract 8 before CALL to align.
%macro ALIGN_BEFORE_CALL 0
    sub rsp, 8
%endmacro

%macro UNALIGN_AFTER_CALL 0
    add rsp, 8
%endmacro

; -------------------------------
; Standard frame-pointer prologue
; -------------------------------
; PROLOGUE_FP locals_bytes
; - locals_bytes should be multiple of 16 when possible.
%macro PROLOGUE_FP 1
    push rbp
    mov rbp, rsp
    %if %1 > 0
        sub rsp, %1
    %endif
%endmacro

; EPILOGUE_FP locals_bytes
%macro EPILOGUE_FP 1
    %if %1 > 0
        add rsp, %1
    %endif
    pop rbp
    ret
%endmacro

; -------------------------------
; Omit-frame-pointer prologue
; -------------------------------
; PROLOGUE_NOFP locals_bytes
%macro PROLOGUE_NOFP 1
    %if %1 > 0
        sub rsp, %1
    %endif
%endmacro

%macro EPILOGUE_NOFP 1
    %if %1 > 0
        add rsp, %1
    %endif
    ret
%endmacro

; -------------------------------
; Save/restore callee-saved regs
; -------------------------------
%macro SAVE_CALLEE 0
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro RESTORE_CALLEE 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

; -------------------------------
; Minimal write(1, buf, len)
; -------------------------------
; Clobbers: RAX, RDI, RSI, RDX
%macro WRITE_STDOUT 2
    mov eax, SYS_write
    mov edi, 1
    lea rsi, [%1]
    mov edx, %2
    syscall
%endmacro

%endif ; CH6_L11_ABI_MACROS_INCLUDED
