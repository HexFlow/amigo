import amigo_types
import helpers

class Parse:
    st = {}
    tt = {}
    tac = []

    def __init__(self, tacPath, stPath):
        with open(stPath) as f:
            stRaw = f.readlines()
        with open(tacPath) as f:
            tacRaw = f.readlines()[1:]
        self.parse_st(stRaw)
        self.parse_tac(tacRaw)

    def parse_st(self, stRaw):
        """
        Takes as input lines of symbol table output file.
        Populates self.st and self.tt with usable-in-python content
        """

        # Helper for splitting on '::' and stripping whitespace
        def split_strip_and_parse(lis):
            splits = [ x.split('::') for x in lis ]
            return dict([ (k[0].strip(), amigo_types.parse_type(k[1].strip()))
                          for k in splits ])

        i = 0
        for i in range(1, len(stRaw)):
            # There is a blank line before type table
            if stRaw[i].strip() == '':
                break
        self.tt = split_strip_and_parse(stRaw[i+2:len(stRaw)-1])  # Type table
        self.st = split_strip_and_parse(stRaw[1:i])               # Symbol table

    def parse_tac(self, tacRaw):
        """
        Takes as input the Intermediate code.
        Populates self.tac with usable-in-python content.
        """
        self.tac = [ helpers.custom_split(instr) for instr in tacRaw ]

    def print_tac(self):
        for t in self.tac:
            print(t)

    def print_st(self):
        for k in self.st:
            print('{0:15}'.format(k), self.st[k])

    def print_tt(self):
        for k in self.tt:
            print('{0:15}'.format(k), self.tt[k])
