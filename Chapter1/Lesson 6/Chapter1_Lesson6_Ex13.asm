# inside gdb
set disassembly-flavor intel
break _start
run
info registers
x/16gx $rsp
x/i $rip
si
si
x/8i $rip
