# Assemble and link with gcc as the driver:
# gcc -c hello_gas_att.s -o hello_gas_att.o
# gcc hello_gas_att.o -o hello_gas_att

# If you use a .S file, the C preprocessor runs first:
# gcc -c file.S -o file.o