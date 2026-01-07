; add dword [rbp-4], 7
; One common encoding:
; 83 45 FC 07
; 83 => opcode group for r/m32, imm8 (sign-extended)
; 45 => ModRM: mod=01 (disp8), reg=000 (/0 = ADD), r/m=101 (base=RBP)
; FC => disp8 = -4
; 07 => imm8 = 7
