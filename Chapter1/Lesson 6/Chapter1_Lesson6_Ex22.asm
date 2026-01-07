# Makefile (debug + release + disasm artifact)
NASM   = nasm
LD     = ld
OBJDMP = objdump
STRIP  = strip

BUILD_DIR = build
SRC_DIR   = src

DEBUG_FLAGS   = -f elf64 -g -F dwarf
RELEASE_FLAGS = -f elf64

TARGET_DEBUG   = $(BUILD_DIR)/hello_dbg
TARGET_RELEASE = $(BUILD_DIR)/hello_rel

OBJ_DEBUG   = $(BUILD_DIR)/hello_dbg.o
OBJ_RELEASE = $(BUILD_DIR)/hello_rel.o

DISASM_DEBUG   = $(BUILD_DIR)/hello_dbg.disasm.txt
DISASM_RELEASE = $(BUILD_DIR)/hello_rel.disasm.txt

all: debug release disasm

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

debug: $(TARGET_DEBUG)
release: $(TARGET_RELEASE)

$(OBJ_DEBUG): $(SRC_DIR)/hello_syscall.asm | $(BUILD_DIR)
	$(NASM) $(DEBUG_FLAGS) -o $@ $<

$(OBJ_RELEASE): $(SRC_DIR)/hello_syscall.asm | $(BUILD_DIR)
	$(NASM) $(RELEASE_FLAGS) -o $@ $<

$(TARGET_DEBUG): $(OBJ_DEBUG)
	$(LD) -o $@ $(OBJ_DEBUG)

$(TARGET_RELEASE): $(OBJ_RELEASE)
	$(LD) -o $@ $(OBJ_RELEASE)
	$(STRIP) $@

disasm: $(TARGET_DEBUG) $(TARGET_RELEASE)
	$(OBJDMP) -d -Mintel $(TARGET_DEBUG) | tee $(DISASM_DEBUG) > /dev/null
	$(OBJDMP) -d -Mintel $(TARGET_RELEASE) | tee $(DISASM_RELEASE) > /dev/null

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all debug release disasm clean
