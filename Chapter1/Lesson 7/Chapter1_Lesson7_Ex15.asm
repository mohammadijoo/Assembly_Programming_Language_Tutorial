; Check runtime syscall behavior
strace ./hello

; Check that msg points to mapped memory and length is correct
objdump -d -M intel ./hello
readelf -S ./hello
