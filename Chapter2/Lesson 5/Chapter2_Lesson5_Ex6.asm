# Chapter 2 - Lesson 5 - Ex6 (AT&T syntax, GAS)
# Demonstrates size suffixes (b/w/l/q) and (zero/sign) extension loads.
# int load_store_demo(unsigned char* p, unsigned int v)
.text
.globl load_store_demo
.type load_store_demo, @function

load_store_demo:
    # Inputs: %rdi = p, %esi = v
    movb $0x7f,   (%rdi)      # store 8-bit immediate
    movw $0xff80, 1(%rdi)     # store 16-bit immediate (-128)
    movl %esi,    3(%rdi)     # store 32-bit value

    movzbl (%rdi),  %eax      # zero-extend byte -> long
    movswl 1(%rdi), %ecx      # sign-extend word -> long
    movl   3(%rdi), %edx

    addl %ecx, %eax
    addl %edx, %eax
    ret

.size load_store_demo, .-load_store_demo
