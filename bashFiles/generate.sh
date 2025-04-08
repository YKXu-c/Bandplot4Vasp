#!/bin/bash
pressure=40
#compound=UP2
press=$[${pressure}*10]
pressurelast=$[${pressure}-5]
for compound in UAs2 UP2 USb2 UBi2
do
#kbar=0.1gpa
dirname=${compound}_0GPa_FM
dirnameFM=${compound}_${pressure}GPa_FM
dirnameAFM=${compound}_${pressure}GPa_AFM
echo "Handling with ${compound}_${pressure}GPa copying"
mkdir ${dirnameFM}
mkdir ./${dirnameFM}/relax
mkdir ./${dirnameFM}/band
mkdir ./${dirnameFM}/dos
cp ${dirname}/relax/INCAR ${dirname}/relax/job.submit ${dirname}/relax/KPOINTS ${dirname}/relax/POTCAR ./${dirnameFM}/relax

cp ${dirname}/INCAR ${dirname}/job.submit ${dirname}/relax/KPOINTS ${dirname}/POTCAR ./${dirnameFM}

cp ${dirname}/band/INCAR ${dirname}/band/job.submit ${dirname}/band/KPOINTS ${dirname}/band/POTCAR ./${dirnameFM}/band

cp ${dirname}/dos/INCAR ${dirname}/dos/job.submit ${dirname}/dos/KPOINTS ${dirname}/dos/POTCAR ./${dirnameFM}/dos

sed -i '/PSTRESS/d' ./${dirnameFM}/relax/INCAR
echo "PSTRESS=${press}" >> ./${dirnameFM}/relax/INCAR

sed -i '/MAGMOM/d' ./${dirnameFM}/relax/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 2 0 0 2 0 0 2 24*0' ./${dirnameFM}/relax/INCAR

sed -i '/MAGMOM/d' ./${dirnameFM}/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 2 0 0 2 0 0 2 24*0' ./${dirnameFM}/INCAR

sed -i '/MAGMOM/d' ./${dirnameFM}/band/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 2 0 0 2 0 0 2 24*0' ./${dirnameFM}/band/INCAR

sed -i '/MAGMOM/d' ./${dirnameFM}/dos/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 2 0 0 2 0 0 2 24*0' ./${dirnameFM}/dos/INCAR

mkdir ${dirnameAFM}
mkdir ./${dirnameAFM}/relax
mkdir ./${dirnameAFM}/band
mkdir ./${dirnameAFM}/dos
cp ${dirname}/relax/INCAR ${dirname}/relax/job.submit ${dirname}/relax/KPOINTS ${dirname}/relax/POTCAR ./${dirnameAFM}/relax

cp ${dirname}/INCAR ${dirname}/job.submit ${dirname}/relax/KPOINTS ${dirname}/POTCAR ./${dirnameAFM}

cp ${dirname}/band/INCAR ${dirname}/band/job.submit ${dirname}/band/KPOINTS ${dirname}/band/POTCAR ./${dirnameAFM}/band

cp ${dirname}/dos/INCAR ${dirname}/dos/job.submit ${dirname}/dos/KPOINTS ${dirname}/dos/POTCAR ./${dirnameAFM}/dos

sed -i '/PSTRESS/d' ./${dirnameAFM}/relax/INCAR
echo "PSTRESS=${press}" >> ./${dirnameAFM}/relax/INCAR

sed -i '/MAGMOM/d' ./${dirnameAFM}/relax/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 -2 0 0 -2 0 0 2 24*0' ./${dirnameAFM}/relax/INCAR

sed -i '/MAGMOM/d' ./${dirnameAFM}/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 -2 0 0 -2 0 0 2 24*0' ./${dirnameAFM}/INCAR

sed -i '/MAGMOM/d' ./${dirnameAFM}/band/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 -2 0 0 -2 0 0 2 24*0' ./${dirnameAFM}/band/INCAR

sed -i '/MAGMOM/d' ./${dirnameAFM}/dos/INCAR
sed -i '/LNONCOLLINEAR/a MAGMOM = 0 0 2 0 0 -2 0 0 -2 0 0 2 24*0' ./${dirnameAFM}/dos/INCAR
echo "MAGMOM changed"
done