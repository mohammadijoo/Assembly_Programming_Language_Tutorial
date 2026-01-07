# Makefile (x86-64 Linux, NASM + ld)
NASM      = nasm
LD        = ld
NASMFLAGS = -f elf64 -g -F dwarf
LDFLAGS   =

BUILD_DIR = build
SRC_DIR   = src

TARGET    = $(BUILD_DIR)/hello_syscall
OBJS      = $(BUILD_DIR)/hello_syscall.o

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

run: $(TARGET)
	./$(TARGET)

disasm: $(TARGET)
	objdump -d -Mintel $(TARGET)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run disasm clean
