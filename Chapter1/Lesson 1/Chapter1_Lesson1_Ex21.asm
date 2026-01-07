; Option A: XOR-zeroing (modifies flags)
xor eax, eax

; Option B: MOV immediate (does not set flags on x86 for MOV)
mov eax, 0

; Option C: SUB self (modifies flags)
sub eax, eax