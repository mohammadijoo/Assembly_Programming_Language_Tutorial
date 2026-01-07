CC := gcc
CFLAGS := -O2 -g -Wall -Wextra

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf

BUILD := build
APP := $(BUILD)/mix_app
OBJS := $(BUILD)/main.o $(BUILD)/add_u64.o

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/main.o: src/main.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/add_u64.o: src/add_u64.asm | $(BUILD)
	$(NASM) $(NASMFLAGS) $< -o $@

$(APP): $(OBJS)
	$(CC) -o $@ $^

.PHONY: run
run: $(APP)
	./$(APP)
