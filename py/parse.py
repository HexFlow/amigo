import re

def parse_type(s):
    if re.match(r'^struct \{.*\}$', s):
        return parse_struct(s)
    elif re.match(r'^\[\].*$', s):
        return ('slice', parse_type(re.findall(r'^\[\](.*)$', s)[0]))
    elif re.match(r'^\[.*?\].*$', s):
        out = re.findall(r'^\[(.*?)\](.*)$', s)
        size = int(out[0])
        subt = parse_type(out[1])
        return ('array', size, subt)
    elif s[:3] == 'map':
        counter, i, tp = 1, 0, ""
        s = s[4:]
        while counter is not 0:
            tp += s[i]
            i += 1
            if s[i] == '[': counter += 1
            elif s[i] == ']': counter -= 1
        return ('map', parse_type(tp), parse_type(s[i:]))

def parse_symbol_table(stfile):
    contents = open(stfile).read().split('\n')
    contents = [ k.split(" :: ") for k in contents ]
    contents = [ (k[0], parse_type(k[1])) for k in contents ]


