# Chapter 2 - Lesson 5 - Ex17 (GAS file that toggles between Intel and AT&T syntax)
# Edit USE_INTEL below to 1 (Intel) or 0 (AT&T) and re-assemble with GAS.
.set USE_INTEL, 1

.text
.globl madd3
.type madd3, @function

.if USE_INTEL
    .intel_syntax noprefix
madd3:
    ; long madd3(long x, long y, long z) => x + 3*y + z
    lea rax, [rsi + rsi*2]
    add rax, rdi
    add rax, rdx
    ret
    .att_syntax prefix
.else
madd3:
    # long madd3(long x, long y, long z) => x + 3*y + z
    leaq (%rsi,%rsi,2), %rax
    addq %rdi, %rax
    addq %rdx, %rax
    ret
.endif

.size madd3, .-madd3
