#!/bin/bash
# for change the name of the spacers you need
# 1) Spacers in fasta file
# 2) Spacers name in form of ">"

for i in F5_*_Spacers*.fa
  do
  filenoextension=$(echo ${i%.fa})
  sed -i "s/spacer/$filenoextension/g" $i
done

echo "Done. Exiting."
