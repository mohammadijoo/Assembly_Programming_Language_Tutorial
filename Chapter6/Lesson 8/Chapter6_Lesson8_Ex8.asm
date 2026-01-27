; Chapter 6 - Lesson 8 (Example 8)
; "Header-style" NASM macros for disciplined register saving/restoring.
; You may keep this file as .inc in real projects, but we keep .asm to match lesson packaging.
;
; Usage:
;   %include "Chapter6_Lesson8_Ex8.asm"
;   PUSH_LIST rbx, r12, r13
;   ; ...
;   POP_LIST  rbx, r12, r13
;
; Notes:
; - POP_LIST expects the same register list as PUSH_LIST, and restores in reverse order.
; - Stack alignment is still your responsibility: ensure RSP is 16-byte aligned before CALL (SysV AMD64).
; - On Linux syscalls, RCX and R11 are clobbered by SYSCALL.

%ifndef ABI_SAVE_MACROS_INCLUDED
%define ABI_SAVE_MACROS_INCLUDED 1

%macro PUSH_LIST 1-*
%rep %0
    push %1
%rotate 1
%endrep
%endmacro

%macro POP_LIST 1-*
%rep %0
%rotate -1
    pop %1
%endrep
%endmacro

; Align stack for SysV AMD64 before making a CALL.
; Assumption: on function entry, RSP mod 16 == 8.
; If you push an odd number of 8-byte values in the prologue, you end at RSP mod 16 == 8 and must SUB RSP,8.
; If you push an even number, you end at RSP mod 16 == 0 and you are already aligned.
%macro SYSV_ALIGN_FOR_CALL 1
    ; %1 = number of 8-byte pushes performed so far in prologue (an integer constant)
    %if (%1 % 2) = 1
        sub rsp, 8
    %endif
%endmacro

%macro SYSV_UNALIGN_AFTER_CALL 1
    %if (%1 % 2) = 1
        add rsp, 8
    %endif
%endmacro

%endif
