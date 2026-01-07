# Makefile (minimal NASM project)
NASM      := nasm
NASMFLAGS := -f elf64 -g -F dwarf -I include/
LD        := ld

BUILD := build
OBJS  := $(BUILD)/main_nasm.o $(BUILD)/print_nasm.o
APP   := $(BUILD)/app_nasm

.PHONY: all clean
all: $(APP)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/main_nasm.o: src/main_nasm.asm | $(BUILD)
	$(NASM) $(NASMFLAGS) $< -o $@

$(BUILD)/print_nasm.o: src/print_nasm.asm include/syscalls_linux_x86_64.inc | $(BUILD)
	$(NASM) $(NASMFLAGS) $< -o $@

$(APP): $(OBJS)
	$(LD) -o $@ $^

clean:
	rm -rf $(BUILD)
