bits 16
org 0x100
cpu 8086

; Ex12 (Exercise Solution 2):
; Macro for "far" conditional branching on 8086 where Jcc are short only.
; Implement:
;   JCC_FAR <cond>, <label>
; by inverting the condition and using an unconditional near JMP.
;
; Usage example:
;   cmp ax, 0
;   JCC_FAR z, far_label     ; jump to far_label if ZF=1
;
; Note: "cond" uses NASM condition suffixes (z, nz, c, nc, s, ns, o, no, etc.)

%macro JCC_FAR 2
    ; Jump over the near JMP if condition is false (invert condition).
    j%+n%1 short %%skip
    jmp %2
%%skip:
%endmacro

start:
    mov ax, 0
    test ax, ax

    ; Jump far away if ZF=1 (true here).
    JCC_FAR z, far_label

    ; Not executed if we jumped.
    mov ax, 0x4C01
    int 0x21

    ; Make target definitely "far" relative to the short Jcc.
    times 400 db 0

far_label:
    mov ax, 0x4C00
    int 0x21
