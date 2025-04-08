#!/bin/bash
pressure=40
dircurrent=/netdisk/home/kyxu/scratch/U12_plusU/lp
#compound=USb2
#dirnameFM=${compound}_${pressure}GPa_FM
#dirnameAFM=${compound}_${pressure}GPa_AFM

press=$[${pressure}*10]
pressurelast=$[${pressure}+5]
echo "fix pressure ${pressure}"
for compound in UAs2 UP2 USb2 UBi2
do
dirnameFM=${compound}_${pressure}GPa_FM
dirnameAFM=${compound}_${pressure}GPa_AFM

echo "Copying CHGCAR..."
cp ${dircurrent}/${dirnameFM}/POSCAR ${dircurrent}/${dirnameFM}/WAVECAR ${dircurrent}/${dirnameFM}/CHGCAR ${dircurrent}/${dirnameFM}/band
cp ${dircurrent}/${dirnameAFM}/POSCAR ${dircurrent}/${dirnameAFM}/WAVECAR ${dircurrent}/${dirnameAFM}/CHGCAR ${dircurrent}/${dirnameAFM}/band

cd ${dircurrent}/${dirnameFM}/band
qsub job.submit
echo "${dirnameFM}band is submitted"


cd ${dircurrent}/${dirnameAFM}/band
qsub job.submit
echo "${dirnameAFM}band is submitted"
done

cd ${dircurrent}
qstat -u kyxu