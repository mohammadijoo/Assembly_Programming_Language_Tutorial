; Chapter5_Lesson9_Ex5.asm
; Macro-assisted structured programming in NASM (IF/ELSE/ENDIF, WHILE/ENDWHILE).
; Demonstrates Euclid GCD with readable intent and collision-safe local labels (%%).
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex5.asm -o ex5.o
;   ld ex5.o -o ex5

BITS 64
DEFAULT REL

%macro IF_NE 2
    cmp %1, %2
    je %%else
%endmacro

%macro ELSE 0
    jmp %%endif
%%else:
%endmacro

%macro ENDIF 0
%%endif:
%endmacro

%macro WHILE_NE 2
%%while_test:
    cmp %1, %2
    je %%while_done
%endmacro

%macro ENDWHILE 0
    jmp %%while_test
%%while_done:
%endmacro

SECTION .text
global _start

; gcd_u32(a=edi, b=esi) -> eax
gcd_u32:
    ; Invariant: gcd(a,b) unchanged by (a,b) := (b, a mod b)
    mov     eax, edi
    mov     ecx, esi

    ; while (b != 0)
    WHILE_NE ecx, 0
        ; t = a mod b  (32-bit)
        xor     edx, edx
        div     ecx            ; eax/ecx -> quotient in eax, remainder in edx
        mov     eax, ecx       ; a = b
        mov     ecx, edx       ; b = t
    ENDWHILE

    ; result in eax
    ret

_start:
    mov     edi, 270
    mov     esi, 192
    call    gcd_u32

    ; gcd(270,192)=6
    cmp     eax, 6
    jne     .L_fail
    xor     edi, edi
    mov     eax, 60
    syscall
.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall
