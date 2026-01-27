bits 16
org 0x100

; Ex4: ISA/CPU constraints (16-bit mode, 8086 vs 386+).
; - On 8086/80186: Jcc are *only* short (rel8).
; - On 386+: you also have "near" Jcc using 0F 8x rel16 in 16-bit mode.
;
; NASM can enforce a minimum CPU with the "cpu" directive.
; Set CPU_LEVEL to 8086 to see the assembler reject "jz near".
%define CPU_LEVEL 386

%if CPU_LEVEL = 8086
    cpu 8086
%else
    cpu 386
%endif

start:
    xor ax, ax
    test ax, ax

    ; This is valid only when CPU_LEVEL >= 386
    jz near far_label

    mov ax, 0x4C01
    int 0x21

    times 200 db 0

far_label:
    mov ax, 0x4C00
    int 0x21
