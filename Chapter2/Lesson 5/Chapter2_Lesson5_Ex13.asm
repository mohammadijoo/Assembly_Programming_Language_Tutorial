# Chapter 2 - Lesson 5 - Ex13 (AT&T syntax, GAS)
# long muladd10(long a, long b) => a*10 + b
.text
.globl muladd10
.type muladd10, @function

muladd10:
    imulq $10, %rdi, %rax
    addq  %rsi, %rax
    ret

.size muladd10, .-muladd10
