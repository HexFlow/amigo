import random
from hashlib import md5
import string
import re
import amigo_types


def genHash(a):
    return 'a' + md5(a.encode('utf-8')).hexdigest()[:8]


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

    regEIP = None
    allTmpList = {}

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
        ins.append("#" + str(self.regs))
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
            self.count += 1
            self.regs[self.locations[var][0]][1] = self.count
            return (self.locations[var][0], [])

        reg = self.get_lru()
        ins = self.wb([reg])

        self.count += 1
        self.regs[reg][0] = var
        self.regs[reg][1] = self.count

        if var in self.locations:
            # If it was not a temporary variable
            self.locations[var][0] = reg
            ins.append('\t# Swapping out {} for {}'.format(reg, var))
            ins.append('\tmov\t{}, {}'.format(self.locations[var][1], reg))
        else:
            # This is temporary
            self.locations[var] = [reg, '---']
            #TODO
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
        self.ins.append('.global main')
        self.ins.append('')
        self.ins.append('.bss')
        for key in self.st:
            p = key.split('-')
            if len(p) == 2 and p[0] == '0':
                if isinstance(self.st[key], amigo_types.FuncType):
                    continue
                self.ins.append(p[1] + ":")
                self.ins.append("\t.space {}".format(self.st[key].size))
                self.registers.locations[key] = ["", "(" + p[1] + ")"]
        self.ins.append('')
        self.ins.append('.text')
        self.ins.append('')

        self.tac_ins_convert(self.parsed.tac)

        self.ins.append('')
        self.ins.append('.data')
        for const in self.consts:
            self.ins.append(const)

        self.ins.append('.bss')
        for key in self.registers.allTmpList:
            self.ins.append(self.registers.allTmpList[key] + ":")
            self.ins.append("\t.space 8")

    def tac_ins_convert(self, taclist):
        i = 0
        arglist = []
        offs = 16
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
            elif tac[0] == 'NEW':
                label = tac[2]
                _type = tac[1]
                _sz = self.tt[_type].size
                self.ins.append("\tmov ${}, %rdi".format(_sz))
                self.ins += self.registers.wb()
                self.ins.append("\tcall malloc")
                self.ins.append("\tmov %rax,{}".format(self.arg_parse([label])))
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
                    if int(tac[1]) == 0:
                        self.ins.append("# WB without flush")
                        self.ins += self.registers.wb_without_flush()
                    tac[1] = self.registers.argRegister[tac[1]]
                    self.ins.append(
                        '\tmov ' + self.arg_parse([tac[2], tac[1]]))
                else:
                    arglist.append('\tpush' + self.arg_parse([tac[2]]))
            elif tac[0] == 'ARGDECL':
                argNo = int(tac[1])
                if argNo < 6:
                    tac[1] = self.registers.argRegister[tac[1]]
                    self.ins.append('\tmov {}, {}'.format(
                        tac[1], self.arg_parse([tac[2]])))
                else:
                    self.ins.append('\tmov {}(%rbp), {}'.format(
                        offs, self.arg_parse([tac[2]])))
                    offs += self.st[tac[2]].size

            elif tac[0] == 'STOR':
                # Check if we need complex lvalue
                # TODO ensure both are not memory locations
                if "[" in tac[1] and "[" not in tac[2]:
                    where_mem_is = self.arg_parse([tac[1]]).strip()
                    where_to_write = self.arg_parse([tac[2]]).strip()
                    self.ins.append('\tmov\t{},\t{}'.format(
                                    where_mem_is, where_to_write))
                elif len(tac) > 2 and ("[" in tac[2] or "." in tac[2]):
                    what_to_write = self.arg_parse([tac[1]]).strip()
                    where_to_write = self.arg_parse([tac[2]], False).strip()
                    self.ins.append('\tmovq\t{}, ({})'.
                                    format(what_to_write, where_to_write))
                else:
                    self.ins.append('\tmov ' + self.arg_parse(tac[1:]))
            elif tac[0] == 'CALL':
                self.ins += self.registers.wb()
                self.ins += list(reversed(arglist))
                self.ins.append('\txor\t%eax,\t%eax')
                self.ins.append('\tcall' + self.arg_parse(["#" + tac[1]]))
                if tac[1].startswith("ffi"):
                    self.ins.append('\tpush %rax')
                arglist = []
            elif tac[0] == 'ADD':
                self.ins.append('\tadd' + self.arg_parse(tac[1:]))
            elif tac[0] == 'MUL':
                self.ins.append('\timul' + self.arg_parse(tac[1:]))
            elif tac[0] == 'SUB':
                self.ins.append('\tsub' + self.arg_parse(tac[1:]))
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
                offs = 16
                j = i
                offset = 0
                while taclist[j][0] != 'NEWFUNCEND':
                    if taclist[j][0] == 'DECL':
                        curtype = self.st[taclist[j][1]]
                        _size = curtype.size
                        if curtype.__str__() in self.tt:
                            _size = self.tt[curtype.__str__()].size

                        offset += _size
                        self.registers.locations[taclist[j][1]] = [
                            "", str(-offset) + "(%rbp)"]
                        self.ins.append('\t# Variable of size ' + str(_size) + ' and name ' + taclist[j][1] +
                                        ' will be at ' + self.registers.locations[taclist[j][1]][1])
                    elif taclist[j][0] == 'ARGDECL':
                        offset += (self.st[taclist[j][2]].size)
                        self.registers.locations[taclist[j][2]] = ["",
                                                                   str(-offset) + "(%rbp)"]
                        self.ins.append('\t# Variable ' + taclist[j][2] +
                                        ' will be at ' + self.registers.locations[taclist[j][2]][1])
                    else:
                        _tac = taclist[j]
                        for t in _tac:
                            if t.startswith('*-tmp'):
                                self.registers.allTmpList[t] = genHash(t)
                                self.registers.locations[t] = [
                                    "", "(" + self.registers.allTmpList[t] + ")"]
                                self.ins.append('\t# Variable ' + t +
                                                ' will be at ' + self.registers.locations[t][1])
                    j += 1
                self.ins.append('\tsub ${}, %rsp'.format(offset))

            elif tac[0] == 'RET':
                self.ins += self.registers.wb()
                self.ins.append('')
                self.ins.append('\tmov %rbp, %rsp')
                self.ins.append('\tpop %rbp')
                self.ins.append('\tret' + self.arg_parse(tac[1:]))
            elif tac[0] == 'RETSETUP':
                self.ins.append('')
                self.ins += self.registers.wb()
                self.ins.append('\tmov %rbp, %rsp')
                self.ins.append('\tpop %rbp')
                r, inst = self.registers.get_reg()
                self.ins += inst
                self.registers.regEIP = r
                self.ins.append('\tpop ' + r)
            elif tac[0] == 'PUSHRET':
                self.ins.append('\tpush' + self.arg_parse(tac[1:]))
            elif tac[0] == 'POP':
                self.ins.append('\tpop' + self.arg_parse(tac[1:]))
            elif tac[0] == 'RETEND':
                r = self.registers.regEIP
                self.ins.append('\tpush ' + r)
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
                    self.ins.append(
                        '\timulq\t${}, {}'.format(basetype.size, index))
                    self.ins.append('\taddq\t{}, {}'.format(index, basereg))

                if need_rval:
                    self.ins.append('\tmov\t({0}), {0}'.format(basereg))
                parsed_args.append(basereg)
            elif '#' in arg:
                if '.' not in arg:
                    parsed_args.append('\t' + arg.split('-')[-1])
                else:
                    arg = arg[1:]
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
            elif '.' in arg:
                # This is a struct selector object
                tmp = arg.split('.')
                struct = self.parsed.st[tmp[0]]
                if isinstance(struct, amigo_types.BasicType):
                    if struct.name in self.parsed.tt:
                        struct = struct.name
                select = tmp[1]
                if struct == "ffi":
                    parsed_args.append('\t' + select)
                elif struct in self.parsed.tt:
                    r, ins = self.registers.get_reg()
                    self.ins += ins
                    loc = self.registers.locations[tmp[0]][1]
                    print(struct)
                    print(self.parsed.tt[struct])
                    self.ins.append('\tlea\t{},\t{}'.format(loc, r))
                    self.ins.append('\tlea\t{}({}),\t{}'.format(
                                    self.parsed.tt[struct].get_offset(select),
                                    r, r))
                    if need_rval:
                        self.ins.append('\tmov\t({0}), {0}'.format(r))
                    parsed_args.append(r)
                else:
                    # This may be a pointer to a struct
                    struct = self.parsed.st[tmp[0]]
                    if isinstance(struct, amigo_types.PointerType):
                        name = struct.base.__str__().strip()
                        if name in self.parsed.tt:
                            struct = name
                        else:
                            print("Searching for ", name)
                            for key in self.parsed.tt:
                                if self.parsed.tt[key].__str__().strip() == name:
                                    struct = key
                                    break
                                else:
                                    print(self.parsed.tt[key].__str__())

                        self.ins += self.registers.wb_without_flush()
                        r, ins = self.registers.get_reg()
                        self.ins += ins
                        loc = self.registers.locations[tmp[0]][1]
                        self.ins.append("# HERE" + loc)
                        print(struct)
                        self.ins.append('\tmov\t{},\t{}'.format(loc, r))
                        # self.ins.append('\tmov\t({}),\t{}'.format(r, r))
                        self.ins.append('\tlea\t{}({}),\t{}'.format(
                                        self.parsed.tt[struct].get_offset(select),
                                        r, r))
                        if need_rval:
                            self.ins.append('\tmov\t({0}), {0}'.format(r))
                        parsed_args.append(r)
                    else:
                        print("ERROR:")
                        print("Unknown type used as struct")
                        print(struct)
                        exit(1)
            elif (arg[0].isdigit() or arg[0] == '*') and '-' in arg:
                # Is a variable from symbol table
                print('Testing for argument', arg, '!!!!!', self.st)
                if arg not in self.st:
                    assert('*-tmp' in arg)
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

    def print_asm(self):
        for asm in self.ins:
            print(asm)

    def write_asm(self, f):
        for asm in self.ins:
            f.write(asm + '\n')
