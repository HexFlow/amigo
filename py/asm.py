import random
import string

class Register:
    regs = {
        '%rax': False,
        '%rbx': False,
        '%rcx': False,
        '%rdx': False,
        '%rx': False,
        '%r8': False,
        '%r9': False,
        '%r10': False,
        '%r11': False,
        '%r12': False,
        '%r13': False,
        '%r14': False,
        '%r15': False
    }

    locations = {}

    def __init__(self):
        print('')

    def get_reg(self, var):
        if var in self.locations:
            return self.locations[var]
        for reg in self.regs:
            if not self.regs[reg]:
                self.regs[reg] = True
                self.locations[var] = reg
                return reg
        print("ERROR")
        print("NO REGISTER")
        exit(1)

class ASM:
    ins = []
    consts = []

    registers = Register()

    def __init__(self, parsed):
        self.parsed = parsed

    def gen(self):
        self.ins.append('\t.global main')
        self.ins.append('\t.text')
        self.ins.append('')

        self.tac_init_fxns()

        self.ins.append('')

        self.tac_ins_convert(self.parsed.tac)

        self.ins.append('')
        self.ins.append('.data')
        for const in self.consts:
            self.ins.append(const)

    # def default_functions(self):

    def tac_ins_convert(self, taclist):
        i = 0
        while i < len(taclist):
            tac = taclist[i]
            if tac[0] == 'LABL':
                tmp = tac[1].split('-')[-1]
                # tmp = 'func' + helpers.labelToName(tac[1])
                self.ins.append(tmp + ':')
            elif tac[0] == 'PUSH':
                self.ins.append('\tpush' + self.arg_parse(tac[1:]))
            elif tac[0] == 'STOR':
                self.ins.append('\tmov' + self.arg_parse(tac[1:]))
            elif tac[0] == 'CALL':
                self.ins.append('\tcall' + self.arg_parse(tac[1:]))
            elif tac[0] == 'ADD':
                self.ins.append('\tadd' + self.arg_parse(tac[1:]))
            elif tac[0] == 'EXIT':
                self.ins += """
\tmov $60, %rax
\txor %rdi, %rdi
\tsyscall""".split('\n')

            i = i + 1

    def str_const(self, op):
        name = ''.join([ random.choice(string.ascii_lowercase)
                         for _ in range(8) ])
        self.consts.append(name + ':')
        self.consts.append('\t.asciz\t' + op)
        return '$' + name

    def arg_parse(self, args):
        st = []
        for arg in args:
            if arg.startswith('"'):
                st.append('\t' + self.str_const(arg))
            elif '.' in arg:
                # This is a struct selector object
                tmp = arg.split('.')
                struct = tmp[0]
                select = tmp[1]
                if struct in self.parsed.tt:
                    st.append('\ts' + struct.upper() + 'f' + select.upper())
                else:
                    print("ERROR:")
                    print("Unknown type used as struct")
                    exit(1)
            elif ( arg[0].isdigit() or arg[0] == '*' ) and '-' in arg:
                # Is a variable from symbol table
                st.append('\t' + self.registers.get_reg(arg))
            elif arg[0].isdigit():
                # Is a number
                st.append('\t$' + arg + ' ')
            else:
                # Immediate
                st.append('\t' + arg)
        return ','.join(st)

    def tac_init_fxns(self):
        self.ins += """
sFMTfPRINTSTRING:
\tpush %rbp
\tmov %rsp, %rbp
\tmov $1, %rax
\tmov $1, %rdi
\tmov 16(%rbp), %rsi
\tmov $1024, %rdx
\tsyscall
\tmov %rbp, %rsp
\tpop %rbp
\tret""".split('\n')

    def print_asm(self):
        for asm in self.ins:
            print(asm)

    def write_asm(self, f):
        for asm in self.ins:
            f.write(asm + '\n')
