; file: record_layout.inc
%define REC_TAG         0
%define REC_LEN         4
%define REC_KIND        6
%define REC_FLAGS       7
%define REC_PAYLOAD_PTR 8
%define REC_SIZE        16

; file: record_ops.asm
%include "record_layout.inc"

; Input:
;   RDI = record*
; Output:
;   EAX = tag XOR (flags<<24) XOR (kind<<16) XOR len
;   RDX = payload_ptr
; Clobbers:
;   RCX, R8

; Load tag (u32)
mov eax, dword [rdi + REC_TAG]

; Load len (u16) -> zero-extend
movzx ecx, word [rdi + REC_LEN]

; Load kind (u8)
movzx r8d, byte [rdi + REC_KIND]

; Load flags (u8)
movzx edx, byte [rdi + REC_FLAGS]   ; temporary in EDX for shifts

; Mix into EAX:
; EAX ^= (flags<<24)
shl edx, 24
xor eax, edx

; EAX ^= (kind<<16)
shl r8d, 16
xor eax, r8d

; EAX ^= len
xor eax, ecx

; Return payload_ptr in RDX
mov rdx, qword [rdi + REC_PAYLOAD_PTR]
ret
