; mov qword [rdi+rcx*8+16], rax
; One valid encoding (conceptual breakdown):
; 48 89 44 CF 10
;
; 48 => REX.W (64-bit operand)
; 89 => opcode: mov r/m64, r64
; 44 => ModRM: mod=01 (disp8), reg=000 (RAX), r/m=100 (SIB follows)
; CF => SIB: scale=3 (x8), index=001 (RCX), base=111 (RDI)
; 10 => disp8 = 16
