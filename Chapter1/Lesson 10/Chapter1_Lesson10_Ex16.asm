/* Example (conceptual): disassemble bytes with Capstone (x86-64)
 * Header: capstone/capstone.h
 */
#include <capstone/capstone.h>

void disasm_example(const unsigned char* code, size_t size) {
    csh handle;
    cs_insn* insn;
    size_t count;

    if (cs_open(CS_ARCH_X86, CS_MODE_64, &handle) != CS_ERR_OK) return;

    count = cs_disasm(handle, code, size, 0x1000, 0, &insn);
    for (size_t i = 0; i < count; i++) {
        /* insn[i].mnemonic, insn[i].op_str, insn[i].size are key fields */
    }
    cs_free(insn, count);
    cs_close(&handle);
}
