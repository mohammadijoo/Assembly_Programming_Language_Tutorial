AS      := as
ASFLAGS := --64
LD      := ld

BUILDDIR := build
APP_GAS := $(BUILDDIR)/app_gas
OBJS_GAS := $(BUILDDIR)/main_gas.o $(BUILDDIR)/print_gas.o

$(BUILDDIR)/main_gas.o: src/main_gas.S | $(BUILDDIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILDDIR)/print_gas.o: src/print_gas.S include/syscalls_linux_x86_64_gas.inc | $(BUILDDIR)
	$(AS) $(ASFLAGS) -I include/ $< -o $@

$(APP_GAS): $(OBJS_GAS)
	$(LD) -o $@ $^
