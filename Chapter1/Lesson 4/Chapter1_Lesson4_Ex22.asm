; GAS-style (conceptual examples; exact directives vary by target)
; .arch or .cpu may exist on some targets
; .text / .global are common across many GAS ports

; x86/x86-64 (GAS)
; .intel_syntax noprefix   ; if you want Intel syntax in GAS

; AArch64 (GAS/LLVM)
; .text
; .global my_func

; RISC-V (GAS/LLVM)
; .option norvc            ; disable compressed extension (if desired)
; .text
