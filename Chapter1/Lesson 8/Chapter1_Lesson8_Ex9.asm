# nasm -f elf64 -g -F dwarf crash_demo.asm -o crash_demo.o
# ld -o crash_demo crash_demo.o
# gdb ./crash_demo
#
# (gdb) break _start
# (gdb) run
# (gdb) si                # step one instruction
# (gdb) info registers
# (gdb) x/8gx $rsp         # examine stack memory
# (gdb) x/i $rip           # show instruction at current RIP
# (gdb) si                # step into the faulting load
