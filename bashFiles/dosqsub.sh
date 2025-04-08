#!/bin/bash
pressure=40
dircurrent=/netdisk/home/kyxu/scratch/U12_plusU/lp
for compound in UAs2 UP2 USb2 UBi2
do
dirnameFM=${compound}_${pressure}GPa_FM
dirnameAFM=${compound}_${pressure}GPa_AFM
echo "Copying CHGCAR..."
cp ${dircurrent}/${dirnameFM}/POSCAR ${dircurrent}/${dirnameFM}/WAVECAR ${dircurrent}/${dirnameFM}/CHGCAR ${dircurrent}/${dirnameFM}/dos
cp ${dircurrent}/${dirnameAFM}/POSCAR ${dircurrent}/${dirnameAFM}/WAVECAR ${dircurrent}/${dirnameAFM}/CHGCAR ${dircurrent}/${dirnameAFM}/dos

cd ${dircurrent}/${dirnameFM}/dos
qsub job.submit
echo "${dirnameFM}dos is submitted"


cd ${dircurrent}/${dirnameAFM}/dos
qsub job.submit
echo "${dirnameAFM}dos is submitted"

done
cd ${dircurrent}
qstat -u kyxu