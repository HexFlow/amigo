import parse
import sys
import asm

if len(sys.argv) != 3:
    print("Usage: python main.py <tacPath> <stPath>")
    exit(1)

parsed = parse.Parse(sys.argv[1], sys.argv[2])

print(parsed.tt)

print("Tac parsed:")
parsed.print_tac()

print()

print("Type table:")
parsed.print_tt()

print()

print("Symbol table:")
parsed.print_st()

print()

asm = asm.ASM(parsed)
asm.gen()
# asm.print_asm()
with open('out.s', 'w') as f:
    asm.write_asm(f)
