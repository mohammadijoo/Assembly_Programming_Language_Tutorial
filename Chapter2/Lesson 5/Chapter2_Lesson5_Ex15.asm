# Chapter 2 - Lesson 5 - Ex15 (AT&T syntax, GAS)
# unsigned long popcount64(unsigned long x) using the Brian Kernighan loop.
.text
.globl popcount64
.type popcount64, @function

popcount64:
    xorl %eax, %eax

.Lloop:
    testq %rdi, %rdi
    jz .Ldone

    leaq -1(%rdi), %rcx
    andq %rcx, %rdi
    incl %eax
    jmp .Lloop

.Ldone:
    ret

.size popcount64, .-popcount64
