#!/bin/bash
pressure=40
#compound=UP2
press=$[${pressure}*10]
pressurelast=$[${pressure}-5]

dircurrent=/netdisk/home/kyxu/scratch/U12_plusU/lp
for compound in UAs2 UP2 USb2 UBi2
do
dirnameFM=${compound}_${pressure}GPa_FM
dirnameAFM=${compound}_${pressure}GPa_AFM
dirname=${compound}_0GPa_FM
if ((${pressure}==0))
then
{}
else
cp ${compound}_${pressurelast}GPa_FM/relax/CONTCAR ./${dirnameFM}/relax/POSCAR
fi
echo "${dirnameFM}CONTCAR is copied"
cd ${dircurrent}/${dirnameFM}/relax/
qsub job.submit
echo "${dirnameFM}Relax is submitted"
cd ${dircurrent}
if ((${pressure}==0))
then
{}
else
cp ${compound}_${pressurelast}GPa_AFM/relax/CONTCAR ./${dirnameAFM}/relax/POSCAR
fi
echo "${dirnameAFM}CONTCAR is copied"
cd ${dircurrent}/${dirnameAFM}/relax/
qsub job.submit
echo "${dirnameAFM}Relax is submitted"
cd ${dircurrent}
done
cd ${dircurrent}
qstat -u kyxu