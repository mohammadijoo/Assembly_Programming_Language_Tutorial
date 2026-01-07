# Makefile (scalable NASM build)
NASM      := nasm
NASMFLAGS := -f elf64 -g -F dwarf -I include/
LD        := ld

SRCDIR := src
BUILDDIR := build

SOURCES := main_nasm.asm print_nasm.asm
OBJS := $(SOURCES:%.asm=$(BUILDDIR)/%.o)

APP := $(BUILDDIR)/app_nasm

.PHONY: all clean run
all: $(APP)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCDIR)/%.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@

$(APP): $(OBJS)
	$(LD) -o $@ $^

run: $(APP)
	./$(APP)

clean:
	rm -rf $(BUILDDIR)
