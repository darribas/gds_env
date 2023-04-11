#!/opt/conda/bin/python

welcome = '''
                          ################
                          ### texBuild ###
                          ################

Helper file to automate the compilation of both .otl (through otl2latex) and
.tex files

### For .tex files ###
    
    1. Checks weather you have a bibliography included in the .tex file

    2. Compiles the appropriate number of times and includes bibtex in the
    compilation

### For .otl files ###

    Helper file to expedite the use of otl2latex for building presentations in
    Beamer.  It performs the following tasks:

    1. Checks for the presence of four spaces instead of actual tabs in the file.
    This will generate a warning and stop the script.

    2. Allows the user to subset the presentation by inserting the strings
    '@start@' and '@end@' (on their own lines) at the beginning and end of a block 
    of the OTL the user wants to compile.  This allows for quickly compiling small
    portions of the presentation without having to build the entire thing.  The
    presentation built is called temp.otl, temp.tex and temp.pdf.

    3. Compiles the presentation appropriately (i.e. executes pdflatex the correct 
    number of times) and deletes out all the temporary files created by Beamer.
    It only leaves behind the .otl, .tex and .pdf.

Usage:

    texbuild file.otl
    texbuild file.tex [-minted]

    If -minted added, then runs the appropriate command to compile LaTeX
    documents that make use of the minted packaged for code-syntax
    highlighting

Authors:

    David C. Folch <david.folch@asu.edu>

    Daniel Arribas-Bel <daniel.arribas.bel@gmail.com>
'''

import os
import sys

nargs=len(sys.argv)
if nargs>1:
    file = sys.argv[1]
    fileType = file.split('.')[-1]
    name = file[:-4]

def subset(test):
    '''
    create temp.otl which is a subset of the full presentation;
    insert '@start@' into main OTL file to begin subset and 
    '@end@' to end subset
    '''
    temp = []
    for i in test:
        if i != '\n':
            temp.append(i)
        else:
            temp.append('\n')
            break
    start = None
    stop = None
    for i in range(len(test)):
        if '@start@' in test[i]:
            start = i+1
        if '@end@' in test[i]:
            stop = i
            break
    temp.extend(test[start:stop])
    outFile = open('temp.otl','w')
    for i in temp:
        outFile.write(i)
    outFile.close()

def compileOTL(name):
    '''
    --converts file from otl to Latex
    --then runs pdflatex appropriate number of times
    --deletes out intermediate files created by Beamer
    --finally, opens the PDF file
    '''
    os.system('python set_folder_path_here/otl2latexR18.py -p ' + name + '.otl ' + name + '.tex')
    os.system('pdflatex ' + name)
    os.system('pdflatex ' + name)
    os.system('pdflatex ' + name)
    os.system('rm ' + name + '.toc')
    os.system('rm ' + name + '.aux')
    os.system('rm ' + name + '.log')
    os.system('rm ' + name + '.snm')
    os.system('rm ' + name + '.nav')
    os.system('rm ' + name + '.out')
    os.system('rm ' + name + '.lot')
    os.system('rm ' + name + '.lof')
    os.system('open ' + name + '.pdf')

def bibGetter(file):
    bibFile=None
    texLines=open(file)
    texLines=texLines.readlines()
    for line in texLines:
        if '\\bibliography{' in line:
            beg=None
            end=None
            for i in range(len(line)):
                if line[i]=='{':
                    beg=i+1
                if line[i]=='}':
                    end=i
            bibFile=line[beg:end]
    return bibFile

def bibCheck(file):
    bibYes=0
    texLines=open(file)
    texLines=texLines.readlines()
    for line in texLines:
        if '\\bibliography{' in line:
            bibYes=1
    return bibYes

def compileTEX(name):
    '''
    --runs pdflatex
    --runs bibtex
    --runs twive pdflatex
    --deletes out side-files created when compiling the tex file
    '''
    os.system('pdflatex ' + name)
    if bibCheck(file):
        os.system('bibtex ' + name)
    os.system('pdflatex ' + name)
    os.system('pdflatex ' + name)
    os.system('rm ' + name + '.aux')
    os.system('rm ' + name + '.bbl')
    os.system('rm ' + name + '.blg')
    os.system('rm ' + name + '.log')
    os.system('rm ' + name + '.out')
    os.system('rm ' + name + '.toc')
    os.system('rm ' + name + '.spl')
    os.system('rm ' + name + '.lot')
    os.system('rm ' + name + '.lof')
    os.system('rm ' + name + '.nav')
    os.system('rm ' + name + '.snm')
    os.system('open ' + name + '.pdf')

def compileTEXminted(name):
    os.system('pdflatex -shell-escape ' + name)
    os.system('pdflatex -shell-escape ' + name)
    os.system('rm ' + name + '.aux')
    os.system('rm ' + name + '.bbl')
    os.system('rm ' + name + '.blg')
    os.system('rm ' + name + '.log')
    os.system('rm ' + name + '.out')
    os.system('rm ' + name + '.toc')
    os.system('open ' + name + '.pdf')

if nargs==1:
    print(welcome)
else:
    if fileType=='otl':
        test = open(file)
        test = test.readlines()
        for i in test:
            # check for four-spaces instead of \t in the OTL file
            if '    ' in i:
                print('\n')
                print('****************************************')
                print('Fix the tabs')
                print('****************************************')
                print('\n')
                break
        else:
            # check to see if the user wants to subset to presentation
            for i in test:
                if '@start@' in i:
                    subset(test)
                    compileOTL('temp')
                    break
            # run the full presentation as the default
            else:
                compileOTL(name)
    if fileType=='tex':
        if sys.argv[-1] == '-minted':
            compileTEXminted(name)
            print('Run with compileTEXminted')
        else:
            compileTEX(name)
            print('Run with compileTEX')

if nargs>1:
    if fileType=='tex':
        if bibCheck(file):
            print('The bibliography used may be found in ',bibGetter(file),'\n')
        else:
            print('\n There is no bibliography to use with bibTeX \n')
    print('\n Your ',fileType,' file has been processed successfully!!!\n')

