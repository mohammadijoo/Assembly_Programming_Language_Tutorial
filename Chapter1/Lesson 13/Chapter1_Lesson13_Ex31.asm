APP := build/app_nasm

.PHONY: audit
audit: $(APP)
	@echo "== Symbols =="
	nm -n $(APP)
	@echo "== Sections =="
	readelf -S $(APP)
	@echo "== Disasm _start =="
	objdump -d -Mintel --disassemble=_start $(APP)
	@echo "== Checks =="
	@readelf -h $(APP) | grep -q "Class:.*ELF64" || (echo "ERROR: not ELF64" && exit 1)
	@nm $(APP) | grep -q " _start$$" || (echo "ERROR: _start missing" && exit 1)
