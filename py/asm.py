import random
import string
import re


class Register:
    regs = {
        '%rax': [None, 0],
        '%rbx': [None, 0],
        # '%rcx': [None, 0],
        # '%rdx': [None, 0],
        # '%r8' : [None, 0],
        # '%r9' : [None, 0],
        '%r10': [None, 0],
        '%r11': [None, 0],
        '%r12': [None, 0],
        '%r13': [None, 0],
        '%r14': [None, 0],
        '%r15': [None, 0]
    }

    argRegister = {
        '0': '%rdi',
        '1': '%rsi',
        '2': '%rdx',
        '3': '%rcx',
        '4': '%r8',
        '5': '%r9'
    }

    byteMap = {
        '%rax': '%al',
        '%rbx': '%bl',
        '%rcx': '%cl',
        '%rdx': '%dl',
        '%r8': '%r8b',
        '%r9': '%r9b',
        '%r10': '%r10b',
        '%r11': '%r11b',
        '%r12': '%r12b',
        '%r13': '%r13b',
        '%r14': '%r14b',
        '%r15': '%r15b'
    }

    locations = {}
    tmps_in_use = []

    count = 0

    def __init__(self):
        print('')

    def get_lru(self):
        minval = 10000000000
        minreg = 'NOREG'
        for reg in self.regs:
            if self.regs[reg][1] <= minval:
                minreg = reg
                minval = self.regs[reg][1]
        return minreg

    def wb(self, arr=None):
        if arr:
            print('Requested wb of ', arr, self.regs[arr[0]][0])
        if arr is None:
            arr = self.regs.keys()
        ins = []
        for k in arr:
            if self.regs[k][0]:
                loc = self.locations[self.regs[k][0]][1]
                print("FREEING THE SOUL OF " + k + " " + loc)
                if loc != "---":
                    ins.append("\tmov {},\t{}".format(k, loc))
                self.locations[self.regs[k][0]][0] = ''
                self.regs[k][0] = None
                self.regs[k][1] = 0
        print("Flush instructions: ", ins)
        return ins

    def wb_without_flush(self, arr=None):
        if arr is None:
            arr = self.regs.keys()
        ins = []
        for k in arr:
            if self.regs[k][0]:
                loc = self.locations[self.regs[k][0]][1]
                if loc != "---":
                    ins.append("\tmov {},\t{}".format(k, loc))
        return ins

    def get_reg(self, var=None):
        if var is None:
            var = ''.join([random.choice(string.ascii_lowercase)
                           for _ in range(8)])

        if var in self.locations and self.locations[var][0] != "":
            return (self.locations[var][0], [])

        reg = self.get_lru()
        ins = self.wb([reg])

        self.count += 1
        self.regs[reg][0] = var
        self.regs[reg][1] = self.count

        if var in self.locations:
            # If it was not a temporary variable
            self.locations[var][0] = reg
            ins.append('\tmov\t{}, {}'.format(self.locations[var][1], reg))
        else:
            # This is temporary
            self.locations[var] = [reg, '---']
        return (reg, ins)


class ASM:
    ins = []
    consts = []

    registers = Register()

    def __init__(self, parsed):
        self.parsed = parsed
        self.tt = parsed.tt
        self.st = parsed.st

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
        arglist = []
        while i < len(taclist):
            tac = taclist[i]
            self.ins.append('')
            self.ins.append('\t# ' + ';'.join(tac))
            if tac[0] == 'LABL':
                tmp = tac[1].split('-')[-1]
                self.ins += self.registers.wb()
                self.ins.append(tmp + ':')
            elif tac[0] == 'PUSH':
                self.ins.append('\tpush' + self.arg_parse(tac[1:]))
            elif tac[0] == 'JMP':
                self.ins += self.registers.wb()
                self.ins.append('\tjmp' + self.arg_parse(tac[1:]))
            elif tac[0] == 'JE':
                self.ins += self.registers.wb()
                self.ins.append('\tje' + self.arg_parse(tac[1:]))
            elif tac[0] == 'JEQZ':
                arg1 = self.arg_parse([tac[1]])
                self.ins.append('\tcmp {}, {}'.format("$0", arg1))
                self.ins += self.registers.wb()
                self.ins.append('\tje' + self.arg_parse([tac[2]]))
            elif tac[0] == 'PUSHARG':
                if int(tac[1]) < 6:
                    tac[1] = self.registers.argRegister[tac[1]]
                    self.ins.append('\tmov ' + self.arg_parse([tac[2], tac[1]]))
                else:
                    arglist.append('\tpush' + self.arg_parse([tac[2]]))
            elif tac[0] == 'STOR':
                # Check if we need complex lvalue
                # TODO ensure both are not memory locations
                if "[" in tac[1] and "[" not in tac[2]:
                    where_mem_is = self.arg_parse([tac[1]]).strip()
                    where_to_write = self.arg_parse([tac[2]]).strip()
                    self.ins.append('\tmov\t{},\t{}'.format(
                                    where_mem_is, where_to_write))
                elif len(tac) > 2 and "[" in tac[2]:
                    what_to_write = self.arg_parse([tac[1]]).strip()
                    where_to_write = self.arg_parse([tac[2]], False).strip()
                    self.ins.append('\tmovq\t{}, ({})'.
                                    format(what_to_write, where_to_write))
                else:
                    self.ins.append('\tmov' + self.arg_parse(tac[1:]))
            elif tac[0] == 'CALL':
                self.ins += self.registers.wb()
                self.ins += list(reversed(arglist))
                self.ins.append('\txor\t%eax,\t%eax')
                self.ins.append('\tcall' + self.arg_parse(tac[1:]))
                arglist = []
            elif tac[0] == 'ADD':
                self.ins.append('\tadd' + self.arg_parse(tac[1:]))
            elif tac[0] == 'ADDR':
                self.ins.append('\tlea {}, '.format(self.registers.locations[
                                tac[1]][1]) + self.arg_parse(tac[2:]))
            elif tac[0] == 'DEREF':
                self.ins += self.registers.wb_without_flush()
                self.ins.append('\tmov ({}), '.format(
                    self.arg_parse(tac[1:2])) + self.arg_parse(tac[2:]))
            elif tac[0] == 'EQ':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsete ' + self.registers.byteMap[reg])
            elif tac[0] == 'GE':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsetge ' + self.registers.byteMap[reg])
            elif tac[0] == 'GT':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsetg ' + self.registers.byteMap[reg])
            elif tac[0] == 'LE':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsetle ' + self.registers.byteMap[reg])
            elif tac[0] == 'LT':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsetl ' + self.registers.byteMap[reg])
            elif tac[0] == 'NE':
                reg = self.arg_parse(tac[1:]).strip()
                self.ins.append('\tmov $0,' + reg)
                self.ins.append('\tsetne ' + self.registers.byteMap[reg])
            elif tac[0] == 'CMP':
                self.ins.append('\tcmp ' + self.arg_parse(tac[1:]))
            elif tac[0] == 'NEWFUNC':
                self.ins += self.registers.wb()
                self.ins.append('\tpush %rbp')
                self.ins.append('\tmov %rsp, %rbp')
                self.ins.append('')
                j = i
                offset = 0
                while taclist[j][0] != 'NEWFUNCEND':
                    if taclist[j][0] == 'DECL':
                        offset += (self.st[taclist[j][1]].size)
                        self.registers.locations[taclist[j][1]] = [
                            "", str(-offset) + "(%rbp)"]
                        self.ins.append('\t# Variable ' + taclist[j][1] +
                                        ' will be at ' +
                                        self.registers.locations[taclist[j][1]][1])
                    j += 1
                self.ins.append('\tsub ${}, %rsp'.format(offset))

            elif tac[0] == 'RET':
                self.ins += self.registers.wb()
                self.ins.append('')
                self.ins.append('\tmov %rbp, %rsp')
                self.ins.append('\tpop %rbp')
                self.ins.append('\tret' + self.arg_parse(tac[1:]))

            elif tac[0] == 'NEWFUNCEND':
                print("GRIM REAPER IS COMING")
                self.ins += self.registers.wb()
                self.ins.append('')
                self.ins.append('\tmov %rbp, %rsp')
                self.ins.append('\tpop %rbp')
                self.ins.append('\tret')
            elif tac[0] == 'EXIT':
                self.ins += self.registers.wb()
                self.ins += """
\tmov $60, %rax
\txor %rdi, %rdi
\tsyscall""".split('\n')
            elif tac[0] == 'DECL':
                pass
            elif tac[0] == 'NEG':
                self.ins.append('\tneg' + self.arg_parse(tac[1:]))
            else:
                print("Unknown TAC ", tac[0])
                exit(1)

            i = i + 1

    def str_const(self, op):
        name = ''.join([random.choice(string.ascii_lowercase)
                        for _ in range(8)])
        self.consts.append(name + ':')
        self.consts.append('\t.asciz\t' + op)
        return '$' + name

    def arg_parse(self, args, need_rval=True):
        parsed_args = []
        for arg in args:
            if arg.startswith('"'):
                parsed_args.append('\t' + self.str_const(arg))
            elif "[" in arg:
                tmp = re.findall(r'\[.*?\]', arg)
                base = arg.split('[')[0]
                basetype = self.st[base]

                base = self.registers.locations[base][1]
                basereg, ins = self.registers.get_reg()
                self.ins += ins
                indexreg, ins = self.registers.get_reg()
                self.ins += ins
                self.ins.append('\tlea\t{}, {}'.format(base, basereg))

                for index in tmp:
                    basetype = basetype.base
                    index = self.arg_parse([index[1:-1]]).strip()
                    self.ins.append('\tmov\t{}, {}'.format(index, indexreg))
                    index = indexreg
                    # Now load index*scale into index
                    self.ins.append('\timulq\t${}, {}'.format(basetype.size, index))
                    self.ins.append('\taddq\t{}, {}'.format(index, basereg))

                if need_rval:
                    self.ins.append('\tmov\t({0}), {0}'.format(basereg))
                parsed_args.append(basereg)
            elif '.' in arg:
                # This is a struct selector object
                tmp = arg.split('.')
                struct = tmp[0]
                select = tmp[1]
                if struct == "ffi":
                    parsed_args.append('\t' + select)
                elif struct in self.parsed.tt:
                    parsed_args.append(
                        '\ts' + struct.upper() + 'f' + select.upper())
                else:
                    print("ERROR:")
                    print("Unknown type used as struct")
                    exit(1)
            elif (arg[0].isdigit() or arg[0] == '*') and '-' in arg:
                # Is a variable from symbol table
                r, ins = self.registers.get_reg(arg)
                self.ins += ins
                parsed_args.append('\t' + r)
            elif arg[0].isdigit():
                # Is a number
                parsed_args.append('\t$' + arg + ' ')
            else:
                # Immediate
                parsed_args.append('\t' + arg)
        return ','.join(parsed_args)

    def tac_init_fxns(self):
        self.ins += """
sFMTfPRINTF:
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
