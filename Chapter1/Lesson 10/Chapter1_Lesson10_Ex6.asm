; bytes (one common encoding):
; 83 45 FC 07
; 83 /0 ib     => ADD r/m32, imm8 (sign-extended imm8)
; 45           => ModRM: mod=01 (disp8), reg=000 (/0 for ADD), r/m=101 (RBP base)
; FC           => disp8 = -4
; 07           => imm8 = 7
