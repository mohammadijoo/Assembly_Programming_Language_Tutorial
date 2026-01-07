NASM      := nasm
NASMFLAGS := -f elf64 -g -F dwarf -I include/
LD        := ld

SRCDIR := src
BUILDDIR := build

SOURCES := main_nasm.asm print_nasm.asm
OBJS := $(SOURCES:%.asm=$(BUILDDIR)/%.o)
DEPS := $(SOURCES:%.asm=$(BUILDDIR)/%.d)

APP := $(BUILDDIR)/app_nasm

.PHONY: all clean
all: $(APP)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Include deps if they exist (do not error on first build)
-include $(DEPS)

# Compile + generate deps
$(BUILDDIR)/%.o: $(SRCDIR)/%.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@
	$(NASM) -M -I include/ $< > $(BUILDDIR)/$*.d

$(APP): $(OBJS)
	$(LD) -o $@ $^

clean:
	rm -rf $(BUILDDIR)
