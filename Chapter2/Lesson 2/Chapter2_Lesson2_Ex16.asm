; file: node_offsets.inc (conceptual include)
%define NODE_NEXT   0
%define NODE_VALUE  8
%define NODE_SIZE   16

; file: use_node.asm
%include "node_offsets.inc"

; rdi = node*
mov rax, [rdi + NODE_NEXT]
mov ecx, [rdi + NODE_VALUE]
