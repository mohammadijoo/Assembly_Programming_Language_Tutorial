# Assembly Programming Language — Full Course (Code Repository)

This repository contains the **code exercises** for a comprehensive Assembly Programming Language course. The material is organized as a large, progressive curriculum: it starts with low-level fundamentals and tooling, builds into core instruction/CPU/memory concepts, and then moves through interoperability, debugging, performance, security, and systems-level development—culminating in a substantial OS-building track.

The repository is intended to be used alongside the companion **YouTube playlist** (linked at the end of this README).

---

## What this course covers (high-level)

You will work through a broad and practical set of topics, including:

- **Tooling and workflow**
  - Assembler/linker/debugger roles; build pipelines; reading ISA/ABI documentation; repeatable project structure
- **CPU and ISA fundamentals**
  - Registers, addressing modes, flags/condition codes, instruction forms, encoding intuition, and performance implications
- **Data representation**
  - Integer ranges and overflow, two’s complement, endianness, bitfields/masks, alignment and layout, strings, and floating-point concepts needed to reason about real code
- **Core instruction patterns**
  - Data movement, arithmetic/logic, shifts/rotates, comparisons, branching, loops, stack usage, extension idioms, and common pitfalls (implicit operands, partial registers, flag clobbering)
- **Control-flow engineering**
  - Structured assembly patterns, jump constraints, jump tables, predictability and layout considerations, defensive flow and error paths
- **Procedures and ABI discipline**
  - Calling conventions, stack alignment, callee/caller-saved registers, prolog/epilog discipline, tail calls, variadics, multi-value returns
- **Memory management concepts**
  - Stack vs heap behavior, allocator models, safety patterns, and conceptual diagnosis of memory bugs
- **I/O and OS interaction**
  - Console and file I/O concepts, syscall vs library tradeoffs, buffering/performance, argument/environment layouts
- **Interoperability**
  - Mixed C/ASM linkage, name mangling and visibility, relocations, PIC/PIE concepts, mixed-language debugging
- **Executable formats and loaders**
  - Object file internals, static vs dynamic linking, relocation categories, debug metadata formats
- **Debugging and profiling**
  - GDB workflows, disassembly/source mapping, watchpoints, post-mortem debugging, microbenchmark design, perf/VTune/WPT concepts
- **Macro systems and maintainability**
  - Conditional assembly, macro hygiene, compile-time computation, large-codebase conventions
- **Advanced instructions and performance**
  - SIMD mental models (alignment, lanes, shuffles), timing pitfalls, prefetching, latency/throughput reasoning, counters, code-size vs speed tradeoffs
- **Concurrency and atomics**
  - Atomic primitives and memory ordering concepts, synchronization strategies, scalability pitfalls
- **Analysis and reverse engineering**
  - CFG reasoning, compiler idioms, binary triage, patch/diff workflows
- **Security and cryptography (defensive and engineering-focused)**
  - Secure coding patterns, modern mitigations, constant-time awareness, side-channel concepts, and common failure modes
- **Systems and platform domains**
  - Networking concepts and API differences, GUI message loop patterns, embedded/bare-metal startup logic, virtualization/emulation workflows
- **Capstone systems track**
  - Boot flow and staged bootloaders, CPU mode transitions, minimal kernel runtime, interrupts/IDT, timers/keyboard input, paging and memory allocators, task switching, syscalls and user mode, simple filesystem/storage, program loading, and validation under virtualization

---

## Repository layout

The code follows a consistent hierarchy:

- `ChapterN/Lesson M/ChapterN_LessonM_ExK.asm`

Example:

```text
Chapter1/
  Lesson 1/
    Chapter1_Lesson1_Ex1.asm
    Chapter1_Lesson1_Ex2.asm
    ...
  Lesson 2/
    ...
Chapter2/
  ...
```

Each lesson folder contains multiple focused exercises (typically ~10) designed to reinforce one concept at a time.

---

## How to use this repository

### 1) Pick a chapter and lesson
Start early if you are new to assembly, or jump to later topics if you already know the basics. The folder names are designed to make it easy to follow the same order as the video lessons.

### 2) Build and run an exercise
Because assembly tooling differs by OS, ISA, and syntax, **build commands may vary** across folders. Most learners use one of these flows:

- **NASM/YASM + LD/LLD** (common on Linux/macOS and in cross toolchains)
- **GAS (GNU as) + LD** (AT&T syntax often; widely available on Unix-like systems)
- **MASM** (common on Windows for certain workflows)
- **LLVM tools** (useful for cross-target work)

If your exercises are written for **NASM (Intel syntax)** on x86-64, a typical Linux example looks like:

```bash
# Assemble
nasm -f elf64 "Chapter1/Lesson 1/Chapter1_Lesson1_Ex1.asm" -o ex1.o

# Link
ld -o ex1 ex1.o

# Run
./ex1
```

If you are on Windows, you can use WSL for a Unix-like toolchain, or use a Windows-native assembler/linker setup.

### 3) Debug when needed
For low-level learning, debugging is part of the workflow:

```bash
gdb ./ex1
```

---

## Recommended learning workflow

- Read the comments in each `.asm` file and run the program at least once.
- Use a debugger to inspect registers, flags, and memory rather than “guessing.”
- Modify each exercise:
  - Change constants and observe flag behavior
  - Replace branches with conditional moves where appropriate
  - Try alternative addressing modes and measure code size differences
- Keep notes on ABI rules (stack alignment, preserved registers, argument passing) and enforce them consistently.

---

## Notes on portability

This course intentionally discusses multiple architectures and platforms at a conceptual level. However, **individual exercises may target a specific ISA/toolchain** (commonly x86 or x86-64, and often Intel syntax). If you port examples:

- Confirm calling convention and stack alignment rules for your target ABI
- Audit implicit clobbers (flags, special registers, vector state)
- Re-check alignment requirements and endianness assumptions
- Validate under a debugger/emulator before benchmarking

---

## Contributing

Contributions are welcome, especially:

- Fixes to typos and comments
- Additional build/run instructions per OS/toolchain
- Tests and expected-output notes for exercises
- Ports to additional assemblers or ISAs (clearly separated by folder)

Please open an issue describing the change and the toolchain used to validate it.

---

# Course Playlist (YouTube)

# YouTube Course Playlist in English Language.

<a href="https://www.youtube.com/playlist?list=PLdUBuoJCa2BxXoJMpe_iQBNQ8YS9HjE2y" target="_blank">
  <img
    src="https://i.ytimg.com/vi/yOacJ9_1H5E/maxresdefault.jpg"
    alt="Assembly Programming Language Tutorial"
    style="max-width: 100%; border-radius: 10px; box-shadow: 0 6px 18px rgba(0,0,0,0.18); margin-top: 0.5rem;"
  />
</a>

# YouTube Course Playlist in Persian Language.

<a href="https://www.youtube.com/playlist?list=PLdUBuoJCa2Byn0ZGtOFgJTUk2wD1r4Q-f" target="_blank">
  <img
    src="https://i.ytimg.com/vi/VLe1-gegENc/maxresdefault.jpg"
    alt="Assembly Programming Language Tutorial"
    style="max-width: 100%; border-radius: 10px; box-shadow: 0 6px 18px rgba(0,0,0,0.18); margin-top: 0.5rem;"
  />
</a>
