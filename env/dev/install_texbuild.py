"""
Script to install 'texbuild' in a machine
"""

import os

wd = os.getcwd() + '/'
machine = os.uname()[1].split('.')[0]

foo = open(wd + 'texBuild.py')
fo = open(wd + 'texBuild_' + machine + '.py', 'w')
for line in foo:
    line = line.replace('set_folder_path_here/', wd)
    fo.write(line)
fo.close()
foo.close()

cmd = 'chmod 777 texBuild_%s.py'%machine
os.system(cmd)

bin = """#!/opt/conda/bin/python

import os, sys

args = sys.argv
if len(args)>1:
    print('Going on...')
    path = args[1]

    if args[-1] == '-minted':
        path+=' -minted'

    cmd = 'python /bin/texBuild.py ' + path
    print(cmd)
    os.system(cmd)
else:
    print('''
                          ################
                          ### texBuild ###
                          ################

Helper file to automate the compilation of both .otl (through otl2latex) and
.tex files

Usage:

    texbuild file.otl
    texbuild file.tex [-minted]

    If -minted added, then runs the appropriate command to compile LaTeX
    documents that make use of the minted packaged for code-syntax
    highlighting

''')
"""

bin_file = wd + 'texbuild'
fo = open(bin_file, 'w')
fo.write(bin)
fo.close()

cmd = 'chmod +x %s'%bin_file
os.system(cmd)

cmd = 'sudo mv %s /bin/'%bin_file
os.system(cmd)

print('Successfully installed!!!')

