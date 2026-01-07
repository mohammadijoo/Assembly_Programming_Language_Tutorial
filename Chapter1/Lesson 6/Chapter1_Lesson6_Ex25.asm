# tools/trace6.gdb
set disassembly-flavor intel
set pagination off
break _start
run
info registers
x/6i $rip
si
si
si
si
si
si
info registers
quit
