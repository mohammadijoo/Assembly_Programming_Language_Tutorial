; Chapter 4 - Lesson 12 (Ex7)
; Partial registers + encoding pitfall: AH/BH/CH/DH are not encodable with a REX prefix.
; In 64-bit mode, many instructions (or using R8-R15) force a REX prefix.
; Pitfall: code that uses AH in 32-bit breaks when ported to 64-bit with REX-using instructions.
; Fix: use AL/BL/CL/DL or use MOVZX from byte in memory, or rearrange so you don't need high 8-bit regs.

bits 64
default rel
global _start

section .text
_start:
    ; This is fine: uses AL (low 8-bit) and no REX requirement.
    mov     al, 0x12

    ; Demonstration of the pitfall (disabled). NASM will error if enabled.
%if 0
    mov     ah, 0x34            ; wants high 8-bit
    mov     r8, 1               ; forces REX prefix in the instruction stream nearby
    add     ah, 1               ; cannot encode AH with REX -> assembler error
%endif

    ; Safe alternative: keep data in AL and shift/mask if you need the "high byte"
    mov     eax, 0x1234         ; EAX=0x00001234, RAX zero-extended
    shr     eax, 8
    and     eax, 0xFF           ; EAX now holds former AH as a clean value

    mov     eax, 60
    xor     edi, edi
    syscall
