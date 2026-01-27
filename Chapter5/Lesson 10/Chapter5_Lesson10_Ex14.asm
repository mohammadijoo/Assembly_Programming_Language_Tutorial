; Chapter5_Lesson10_Ex14.asm
; Programming Exercise Solution — safe_2d_index_ptr (bounds + overflow checked addressing)
; SysV AMD64 ABI
;
; int safe_2d_index_ptr_u64(const uint64_t* base, uint64_t rows, uint64_t cols,
;                           uint64_t row,  uint64_t col,  const uint64_t** out);
;   rdi = base
;   rsi = rows
;   rdx = cols
;   rcx = row
;   r8  = col
;   r9  = out (pointer to pointer)
; Returns:
;   rax = 0 success
;   rax = -1 invalid (null pointers or out-of-range indices)
;   rax = -2 overflow (address arithmetic overflow)
;
; Layout assumes a row-major array of uint64_t with element size 8 bytes.

BITS 64
default rel

global safe_2d_index_ptr_u64
section .text

safe_2d_index_ptr_u64:
    test rdi, rdi
    jz   .invalid
    test r9,  r9
    jz   .invalid

    ; bounds checks (unsigned)
    cmp  rcx, rsi                  ; row >= rows
    jae  .invalid
    cmp  r8,  rdx                  ; col >= cols
    jae  .invalid

    ; idx = row*cols + col, with overflow checks
    mov  rax, rcx
    mul  rdx                       ; RDX:RAX = row*cols
    test rdx, rdx
    jnz  .overflow
    add  rax, r8
    jc   .overflow

    ; offset_bytes = idx * 8, ensure shift doesn't overflow
    cmp  rax, 0x1FFFFFFFFFFFFFFF   ; max before << 3 without overflow
    ja   .overflow
    shl  rax, 3

    ; addr = base + offset_bytes, detect pointer overflow
    mov  r10, rdi
    add  r10, rax
    jc   .overflow

    mov  [r9], r10                 ; store resulting pointer
    xor  eax, eax
    ret

.invalid:
    mov  eax, -1
    ret

.overflow:
    mov  eax, -2
    ret
