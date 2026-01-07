; Chapter2_Lesson9_Ex9.asm
; GAS (as) syntax demo: AT&T vs Intel in the same file.
; Build (Linux x86-64, GAS via gcc):
;   gcc -c Chapter2_Lesson9_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o

    .globl _start
    .text
_start:
    # --- AT&T syntax (default): src, dst; registers have %; immediates have $ ---
    mov $0x11223344, %eax
    leaq array(%rip), %rbx
    xchg %eax, %eax                # historically used as a NOP-like idiom
    mov %eax, %edi
    mov $60, %eax
    syscall

    # --- Intel syntax (GAS) is opt-in ---
    .intel_syntax noprefix
intel_example:
    mov eax, 0x55667788
    lea rcx, [rbx + 8]
    xchg eax, eax
    .att_syntax prefix

    .data
array:
    .quad 1, 2, 3, 4
