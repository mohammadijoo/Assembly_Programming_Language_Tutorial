# Chapter 2 - Lesson 5 - Ex4 (AT&T syntax, GAS)
# long sum_i32(const int* arr, long n) => sum_{i=0..n-1} (long)arr[i]
.text
.globl sum_i32
.type sum_i32, @function

sum_i32:
    xorl %eax, %eax         # sum = 0
    xorl %ecx, %ecx         # i = 0

.Lloop:
    cmpq %rsi, %rcx
    jge .Ldone

    movslq (%rdi,%rcx,4), %rdx   # sign-extend int32 -> int64
    addq %rdx, %rax

    incq %rcx
    jmp .Lloop

.Ldone:
    ret

.size sum_i32, .-sum_i32
