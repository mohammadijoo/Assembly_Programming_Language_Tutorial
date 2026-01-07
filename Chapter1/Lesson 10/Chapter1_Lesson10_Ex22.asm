; AT&T syntax is shown inside x86asm highlighting for consistency of the site.
; The goal is equivalence; assembling requires GAS with proper directives.
.globl seqB
.text
seqB:
    movl (%rdi), %eax
    addl $7, %eax
    cmpl $100, %eax
    jl .less
    movl $1, %eax
    ret
.less:
    xorl %eax, %eax
    ret
