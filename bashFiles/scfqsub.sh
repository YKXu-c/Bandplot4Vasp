#!/bin/bash
pressure=40
dircurrent=/netdisk/home/kyxu/scratch/U12_plusU/lp
for compound in UAs2 UP2 USb2 UBi2
do
dirnameFM=${compound}_${pressure}GPa_FM
dirnameAFM=${compound}_${pressure}GPa_AFM

cp ${dircurrent}/${dirnameFM}/relax/CONTCAR ${dircurrent}/${dirnameFM}/POSCAR
cp ${dircurrent}/${dirnameAFM}/relax/CONTCAR ${dircurrent}/${dirnameAFM}/POSCAR

cd ${dircurrent}/${dirnameFM}/
qsub job.submit
echo "${dirnameFM}scf is submitted"

cd ${dircurrent}/${dirnameAFM}/
qsub job.submit
echo "${dirnameAFM}scf is submitted"

done
cd ${dircurrent}
qstat -u kyxu