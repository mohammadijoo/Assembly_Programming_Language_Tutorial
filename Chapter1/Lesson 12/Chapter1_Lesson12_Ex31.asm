# Show encodings:
# llvm-mc --triple=x86_64-pc-linux-gnu --show-encoding encoding_target.s
#
# Explanation target:
# - r8 and r9 require REX prefixes because they are extended registers.
# - You should see bytes indicating REX presence (commonly 0x4? prefixes).