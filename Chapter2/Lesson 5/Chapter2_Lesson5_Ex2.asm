# Chapter 2 - Lesson 5 - Ex2 (AT&T syntax, GAS)
# long add3(long a, long b, long c) => a + b + c
.text
.globl add3
.type add3, @function

add3:
    # SysV AMD64 ABI: a=%rdi, b=%rsi, c=%rdx
    leaq (%rdi,%rsi), %rax
    addq %rdx, %rax
    ret

.size add3, .-add3
