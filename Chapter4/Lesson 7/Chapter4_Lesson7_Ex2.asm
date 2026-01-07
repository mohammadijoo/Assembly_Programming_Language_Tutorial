BITS 64
default rel
global _start

section .text
_start:
    ; Demonstrate JZ/JNZ after CMP and TEST (JE/JNE are synonyms)

    ; Case A: CMP sets ZF when operands are equal
    mov eax, 42
    mov ebx, 42
    cmp eax, ebx          ; ZF=1 because 42 == 42
    je  .equal            ; JE == JZ

.not_equal:
    ; exit(1)
    mov eax, 60
    mov edi, 1
    syscall

.equal:
    ; Case B: TEST sets ZF when (x AND x) == 0 (i.e., x==0)
    xor ecx, ecx          ; ECX = 0
    test ecx, ecx         ; ZF=1 because ECX==0
    jnz .should_not_happen

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

.should_not_happen:
    mov eax, 60
    mov edi, 2
    syscall
