# Script to automate compilation flow for yacc.
# Procedure: open PowerShell, enter in this directory and execute:
# .\make.ps1
$proj = "xyz"
win_flex $proj'.l'
win_bison -d $proj'.y'
gcc -o $proj'.exe' $proj'.tab.c'
rm lex.yy.c 
rm $proj'.tab.c'
rm $proj'.tab.h'
echo "* Wrote $proj.exe"