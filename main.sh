#!/bin/bash

#
#control if files exist
#

check=$(ls vcluster | wc -l); #check executable

if [ $check -eq 1 ]; then
	echo "vcluster: OK";
else
	echo "ERROR: cannot find vcluster";
	exit;
fi

check=$(ls re[0-1].mat | wc -l); #check mat files

if [ $check -eq 2 ]; then
	echo "mat files: OK";
else
	echo "ERROR: cannot find re0.mat and re1.mat";
	exit;
fi

check=$(ls re[0-1].mat.rclass | wc -l); #check class files

if [ $check -eq 2 ]; then
	echo "class files: OK";
else
	echo "ERROR: cannot find re0.mat.class and re1.mat.class";
	exit;
fi

#remove previous results 
file="resultados_re0.txt"
[[ -f "$file" ]] && rm -f "$file"
file="resultados_re1.txt"
[[ -f "$file" ]] && rm -f "$file"


#
#select number of clusters
#

echo "Calculating optimal number of clusters for re0:"

clusters=("5" "7" "8" "9" "10" "11" "12" "13")

for i in ${clusters[@]}; do
	cmd="./vcluster re0.mat $i | grep -o 'Entropy: 0.[0-9][0-9][0-9]' | sed 's/\Entropy: //g'"
	entropy=$(eval $cmd)
	echo "Entropy for $i clusters: $entropy"
done

echo "Calculating optimal number of clusters for re1:"

clusters=("5" "10" "15" "20" "21" "22" "23" "24" "25")

for i in ${clusters[@]}; do
	cmd="./vcluster re1.mat $i | grep -o 'Entropy: 0.[0-9][0-9][0-9]' | sed 's/\Entropy: //g'"
	entropy=$(eval $cmd)
	echo "Entropy for $i clusters: $entropy"
done

#
#command
#

echo -n "Enter number of clusters for re0 [ENTER]: "
read nclusters
algorithm=("direct" "agglo")
similarity=("cos" "corr")
criteria=("i2" "h1")

echo -ne "Calculating re0"
for i in ${algorithm[@]}; do
  for j in ${similarity[@]}; do
    for k in ${criteria[@]}; do
	cmd="./vcluster -rclassfile=re0.mat.rclass -clmethod=$i -sim=$j -crfun=$k re0.mat $nclusters";
	eval $cmd>>resultados_re0.txt;
	echo -ne ".";
    done
  done
done
echo "Finish"

echo -n "Enter number of clusters for re1 [ENTER]: "
read nclusters

echo -ne "Calculating re1"
for i in ${algorithm[@]}; do
  for j in ${similarity[@]}; do
    for k in ${criteria[@]}; do
	cmd="./vcluster -rclassfile=re1.mat.rclass -clmethod=$i -sim=$j -crfun=$k re1.mat $nclusters";
	eval $cmd>>resultados_re1.txt;
	echo -ne ".";
    done
  done
done

echo "Finish"

exit 0;
