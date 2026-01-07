; typical bytes (one valid encoding):
; 48 B8 88 77 66 55 44 33 22 11
; 48        => REX.W (select 64-bit operand)
; B8+r      => opcode "mov reg, imm" where r encodes which register (rax here)
; imm64     => 8-byte immediate (little-endian)
