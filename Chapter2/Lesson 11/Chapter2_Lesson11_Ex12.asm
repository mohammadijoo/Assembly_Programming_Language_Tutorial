; File A: export a data label; demonstrates global with data symbols.

BITS 64
global shared_value

section .data
shared_value: dq 123456789
