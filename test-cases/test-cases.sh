#!/bin/bash

verboseMode=0
diffMode=0
# check flags, and change defaults appropriately
while getopts "dv" OPTION
do
 case $OPTION in 
  v)    
   echo "Verbose mode on..."
   verboseMode=1
   ;;
  d)    
   echo "Showing diffs..."
   diffMode=1
   ;;
  ?)    printf "Usage: %s [-v -d]\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

# loop through the test files
for FILE in tn-test1 tn-test2 exam-test1 exam-test2 ab-test1 ab-test2 icma-test1 icma-test2 abtemplate examtemplate icmatemplate tntemplate
do
  if [ $verboseMode == 1 ]; then
    latex $FILE
    dvips $FILE.dvi -o $FILE.ps
  else
    echo "latex $FILE"
    latex $FILE > /dev/null
    echo "dvips $FILE.dvi -o $FILE.ps"
    dvips $FILE.dvi -o $FILE.ps
  fi
done

# remove date-specific data from post-script files to allow easy output from diff and git status
perl -pi -e 's/%%CreationDate.*/%%/' *.ps

# always use the same date for DVIPSSource date
perl -pi -e 's/%DVIPSSource.*/%DVIPSSource:  TeX output 2017.11.24:1118/' *.ps
perl -pi -e 's/%DVIPSCommandLine:.*/%DVIPSCommandLine/' *.ps

# if the diff mode is active, then show the differences between files
if [ $diffMode == 1 ]; then
    echo $'============\ndiff tn-test1.ps tn-test2.ps\n----------------' && diff tn-test1.ps tn-test2.ps
    echo $'============\ndiff exam-test1.ps exam-test2.ps\n----------------' && diff exam-test1.ps exam-test2.ps
    echo $'============\ndiff ab-test1.ps ab-test2.ps\n----------------' && diff ab-test1.ps ab-test2.ps
    echo $'============\ndiff icma-test1.ps icma-test2.ps\n----------------' && diff icma-test1.ps icma-test2.ps
fi
git status
exit
