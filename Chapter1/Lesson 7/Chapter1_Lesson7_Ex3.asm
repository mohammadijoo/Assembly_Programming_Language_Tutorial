; Inspect ELF headers, entry point, and sections
readelf -h hello
readelf -S hello

; Inspect symbols (note _start should exist)
nm -n hello

; Disassemble the executable (Intel syntax output)
objdump -d -M intel hello
