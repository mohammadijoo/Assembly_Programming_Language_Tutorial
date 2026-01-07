# Chapter 2 - Lesson 5 - Ex16 (AT&T syntax, GAS)
# Very hard exercise solution: bounds-checked dispatch through a RIP-relative function-pointer table.
# long dispatch(long idx, long x)
.data
.globl fn_table
fn_table:
    .quad f0, f1, f2, f3

.text
.globl dispatch
.type dispatch, @function

dispatch:
    # idx=%rdi, x=%rsi
    cmpq $3, %rdi
    ja .Lbad

    leaq fn_table(%rip), %rdx
    movq (%rdx,%rdi,8), %rax
    movq %rsi, %rdi
    call *%rax
    ret

.Lbad:
    movq $-1, %rax
    ret

.size dispatch, .-dispatch

.type f0, @function
f0:
    movq %rdi, %rax
    ret

.type f1, @function
f1:
    leaq 1(%rdi), %rax
    ret

.type f2, @function
f2:
    leaq (%rdi,%rdi), %rax
    ret

.type f3, @function
f3:
    imulq $3, %rdi, %rax
    ret
