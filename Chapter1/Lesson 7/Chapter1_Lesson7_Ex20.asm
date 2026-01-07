; 1) Confirm ELF entry point
readelf -h hello | grep -i "Entry point"

; 2) Confirm symbol exists (static symbol table view)
nm -n hello | grep -E " _start$"

; 3) Confirm syscall instructions appear in disassembly
objdump -d -M intel hello | grep -n "syscall"

; 4) Confirm string is present (strings is coarse; readelf/objdump are stricter)
strings -a hello | grep -F "Hello from x86-64 assembly!"

; Optional: show data section bytes containing the message
objdump -s -j .data hello
