# Chapter 2 - Lesson 5 - Ex8 (AT&T syntax, GAS)
# Demonstrates indirect CALL/JMP and RIP-relative global loads.
.data
.globl funcptr
funcptr:
    .quad 0

.text
.globl call_indirect_demo
.type call_indirect_demo, @function

call_indirect_demo:
    # Inputs:
    #   %rdi = function pointer: long f(long)
    #   %rsi = argument
    movq %rdi, %rax
    movq %rsi, %rdi
    call *%rax

    # Jump through global (RIP-relative)
    jmp *funcptr(%rip)

.size call_indirect_demo, .-call_indirect_demo
