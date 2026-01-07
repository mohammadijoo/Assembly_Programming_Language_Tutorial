# gdb ./app
# (gdb) break broken_sum
# (gdb) run
# (gdb) info registers rbx rdi rsi
# (gdb) si
# (gdb) info registers rbx
# Observe: rbx changes inside broken_sum and is not restored before ret
