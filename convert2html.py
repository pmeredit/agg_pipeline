#!/usr/bin/env python

import sys

out = open('agg_pipeline.html', 'w')

HEADER = '''
<html>
<style type="text/css">
p {
    font-family: monospace;
    white-space: pre;
}
</style>
<p>
'''

FOOTER = '''</p></html>'''

class Token(object):
    def __init__(self, value, ty):
            self.value = value
            self.ty = ty

    def __str__(self):
        if self.ty == "Nt":
            return "<a href='#" + self.value + "'>" + self.value + "</a>"
        elif self.ty == 'Space':
            return " "
        else:
            return self.value

    def __repr__(self):
        return self.ty + "('" + self.value + "')"

def tokenize(line):
    ret = []
    buff = ['']
    in_string = False
    def flush(ty):
        if buff[0] == "::=":
            ret.append(Token("::=", "Op"))
            buff[0] = ''
        elif buff[0] != '':
            ret.append(Token(buff[0], ty))
            buff[0] = ''
    def append(c):
        buff[0] += c 
    for i, c in enumerate(line):
        if in_string:
            append(c)
            if c == '"':
                in_string = False
                flush("Term")
        elif c == '"':
            flush('Nt')
            append(c)
            in_string = True
        elif c in '|{}()*+?':
            flush('Nt')
            ret.append(Token(c, 'Op'))
        elif c == '/':
            ret.append(Token(line[i:], 'Comment'))
            break
        elif c == ' ':
            flush('Nt')
            ret.append(Token(' ', 'Space'))
        else:
            append(c)
    return ret

is_new_nt = True
print >> out, HEADER
for line in sys.stdin:
    line = tokenize(line)
    #print map(repr, line)
    if line == []:
        print >> out, ""
        is_new_nt = True
        continue
    if is_new_nt:
        print >> out, "<a name='" + line[0].value + "'/>"
        is_new_nt = False
    print >> out, "".join(map(str, line)) 

print >> out, FOOTER

