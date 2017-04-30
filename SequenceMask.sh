#!/bin/bash

# for masking a part of a seqeunce you need:
# 1) Sequence fasta file format
# 2) Initial and final position to cut

echo "Suggested fasta files in current working directory: "
ls *.fa*

# enter sequencing file
echo "Requiring the file containing genome sequence. Input the file of your choice (fasta format required), followed by [ENTER]:"
read readsfile

# enter the name of the output file
echo "Enter the name of the strain, followed by [ENTER]:"
read strain

# enter cut position no 1
echo "Cut position number one"
echo "Enter cut start position number one, followed by [ENTER]:"
read PosCut1Start
echo "Enter cut end position number one, followed by [ENTER]:"
read PosCut1End

# enter cut position no 2
echo "Cut position number two"
echo "Enter cut start position number two (omit if a second cut is not required, followed by [ENTER]:"
read PosCut2Start
echo "Enter cut  end position number two (omit if a second cut is not required, followed by [ENTER]:"
read PosCut2End

# enter cut position no 3
echo "Cut position number three"
echo "Enter cut start position number three (omit if a third cut is not required, followed by [ENTER]:"
read PosCut3Start
echo "Enter cut end position number three (omit if a third cut is not required, fo
llowed by [ENTER]:"
read PosCut3End

# create cut position file
echo "creating cut position file..."
touch tmp_cut_start_position.txt
touch tmp_cut_end_position.txt
touch tmp_cut_position.txt
echo "$PosCut1Start" >> tmp_cut_start_position.txt
echo "$PosCut1End" >> tmp_cut_end_position.txt
echo "$PosCut2Start" >> tmp_cut_start_position.txt
echo "$PosCut2End" >> tmp_cut_end_position.txt
echo "$PosCut3Start" >> tmp_cut_start_position.txt
echo "$PosCut3End" >> tmp_cut_end_position.txt
paste tmp_cut_start_position.txt tmp_cut_end_position.txt | column -s $'\t' -t >> tmp_cut_position.txt

# sort cut position file
echo "sorting cut position file.."
sort -k 1n tmp_cut_position.txt > tmp_cut_sort_position.txt

# sort cut position variables
Start1=$(cat tmp_cut_sort_position.txt | awk 'NR==3 {print $1}')
End1=$(cat tmp_cut_sort_position.txt | awk 'NR==3 {print $2}')
Start2=$(cat tmp_cut_sort_position.txt | awk 'NR==2 {print $1}')
End2=$(cat tmp_cut_sort_position.txt | awk 'NR==2 {print $2}')
Start3=$(cat tmp_cut_sort_position.txt | awk 'NR==1 {print $1}')
End3=$(cat tmp_cut_sort_position.txt | awk 'NR==1 {print $2}')

# prepare file to be cut
echo "file preparation..."
cat $readsfile | grep -v '^>' | sed ':a;N;$!ba;s/\n//g' > tmp_NoHeader_Noline.fasta

# cut sequence(s) and masking first and last position
echo "Cuting out sequence(s)..."
cat tmp_NoHeader_Noline.fasta | awk -v var1="$Start1" -v var2="$End1" '{print substr($0,1,var1) substr($0,var2)}' > tmp_Cut1.fasta
echo "Masking first and last position..."
Count1=1
Count2=2
MaskStart1=$(($Start1-$Count1))
MaskEnd1=$(($Start1+$Count2))
cat tmp_Cut1.fasta | awk -v var7="$MaskStart1" -v var8="$MaskEnd1" '{print substr($0,1,var7) "XX" substr($0,var8)}' > tmp_mask1.fasta
cat tmp_mask1.fasta | awk -v var3="$Start2" -v var4="$End2" '{print substr($0,1,var3) substr($0,var4)}' > tmp_Cut2.fasta
MaskStart2=$(($Start2-$Count1))
MaskEnd2=$(($Start2+$Count2))
cat tmp_Cut2.fasta | awk -v var9="$MaskStart2" -v var10="$MaskEnd2" '{print substr($0,1,var9) "XX" substr($0,var10)}' > tmp_mask2.fasta
cat tmp_mask2.fasta | awk -v var5="$Start3" -v var6="$End3" '{print substr($0,1,var5) substr($0,var6)}' > tmp_Cut3.fasta
MaskStart3=$(($Start3-$Count1))
MaskEnd3=$(($Start3+$Count2))
cat tmp_Cut3.fasta | awk -v var11="$MaskStart3" -v var12="$MaskEnd3" '{print substr($0,1,var11) "XX" substr($0,var12)}' > tmp_mask3.fasta

# finalize
echo "creating final cut fasta file..."
cat $readsfile | grep '^>' > tmp_header.fasta
cat tmp_header.fasta tmp_mask3.fasta > $strain

# removing tmp file
rm tmp_*
echo "Done. Exiting."
