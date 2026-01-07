# Example workflows (conceptual; flags may vary by installation)
# Assemble to an object:
# llvm-mc --triple=x86_64-pc-linux-gnu --filetype=obj encode_demo.s -o encode_demo.o
#
# Show encodings (for many targets):
# llvm-mc --triple=x86_64-pc-linux-gnu --show-encoding encode_demo.s
#
# Disassemble the resulting object:
# llvm-objdump -d encode_demo.o