; Chapter7_Lesson5_Ex1.asm
; Memory layout, padding, and offset-aware addressing (NASM, x86-64, Linux).
; Assemble: nasm -felf64 Chapter7_Lesson5_Ex1.asm && ld -o ex1 Chapter7_Lesson5_Ex1.o

BITS 64
default rel

%define SYS_exit 60

; ----------------------------
; Two alternative node layouts
; ----------------------------
struc WideNode
  .next   resq 1      ; 8
  .id     resd 1      ; 4
  .flags  resb 1      ; 1
  .pad    resb 3      ; 3  (explicit padding so .value stays 8-aligned)
  .value  resq 1      ; 8
endstruc               ; total: 24 bytes

struc PackedNode
  .next   resq 1      ; 8
  .value  resq 1      ; 8
  .id     resd 1      ; 4
  .flags  resb 1      ; 1
  .pad    resb 3      ; 3
endstruc               ; total: 24 bytes (same here, but different locality for hot fields)

section .bss
align 16
wide_nodes:   resb WideNode_size   * 4
packed_nodes: resb PackedNode_size * 4

section .text
global _start

_start:
  ; Write a few fields using symbolic offsets (zero cost after assembly)
  lea rbx, [wide_nodes]
  mov qword [rbx + WideNode.next], 0
  mov dword [rbx + WideNode.id],  12345
  mov byte  [rbx + WideNode.flags], 1
  mov qword [rbx + WideNode.value], 0x1122334455667788

  lea rcx, [packed_nodes]
  mov qword [rcx + PackedNode.next],  0
  mov qword [rcx + PackedNode.value], 0xAABBCCDDEEFF0011
  mov dword [rcx + PackedNode.id],    7
  mov byte  [rcx + PackedNode.flags], 0x5A

  ; Touch the second element using scaled indexing:
  ; addr = base + i * struct_size + field_offset
  mov edx, 1
  lea rsi, [wide_nodes + rdx*WideNode_size]
  mov qword [rsi + WideNode.value], 0xDEADBEEFCAFEBABE

  mov eax, SYS_exit
  xor edi, edi
  syscall
