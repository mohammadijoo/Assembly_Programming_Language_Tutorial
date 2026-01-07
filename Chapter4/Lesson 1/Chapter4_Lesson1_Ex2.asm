;
; Chapter 4 - Lesson 1 (Arithmetic): Example 2
; Topic: Flags from ADD/SUB: CF vs OF, capturing flags with SETcc and PUSHFQ/POPFQ
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Debug:
;   gdb -q ./ex2 ; run and stop on int3, inspect registers and memory

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .bss
flags1  resq 1
flags2  resq 1
ccbits  resb 8                ; store some SETcc results

SECTION .text
_start:
    ; Case A: signed overflow (OF=1), no unsigned carry (CF=0)
    ; 0x7FFF... + 1 => 0x8000... (changes sign, overflow in signed interpretation)
    mov rax, 0x7FFFFFFFFFFFFFFF
    add rax, 1
    pushfq
    pop qword [flags1]
    ; Capture key flags into bytes (1 or 0)
    seto  byte [ccbits+0]     ; OF
    setc  byte [ccbits+1]     ; CF
    sets  byte [ccbits+2]     ; SF
    setz  byte [ccbits+3]     ; ZF

    ; Case B: unsigned carry (CF=1), no signed overflow (OF=0)
    ; 0xFFFF... + 1 => 0x0000... (wrap-around)
    mov rax, 0xFFFFFFFFFFFFFFFF
    add rax, 1
    pushfq
    pop qword [flags2]
    seto  byte [ccbits+4]
    setc  byte [ccbits+5]
    sets  byte [ccbits+6]
    setz  byte [ccbits+7]     ; should be 1 (result is zero)

    int3

    ; Exit with code = (ccbits[0]..ccbits[7] as bitfield) & 255
    xor eax, eax
    mov al, byte [ccbits+0]
    shl al, 1
    or  al, byte [ccbits+1]
    shl al, 1
    or  al, byte [ccbits+2]
    shl al, 1
    or  al, byte [ccbits+3]
    shl al, 1
    or  al, byte [ccbits+4]
    shl al, 1
    or  al, byte [ccbits+5]
    shl al, 1
    or  al, byte [ccbits+6]
    shl al, 1
    or  al, byte [ccbits+7]

    mov edi, eax
    mov eax, 60
    syscall
