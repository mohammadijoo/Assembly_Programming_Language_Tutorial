# Assemble both and compare disassembly:
# nasm -f elf64 u64_sum_nasm.asm -o u64_sum_nasm.o
# as --64 u64_sum_gas_intel.s -o u64_sum_gas_intel.o
#
# Compare:
# objdump -d u64_sum_nasm.o
# objdump -d u64_sum_gas_intel.o