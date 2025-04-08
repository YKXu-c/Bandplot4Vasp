echo "type the pressure u want to change in GPa(should be able to mod5)"
read newpressure

for file in bandqsub.sh generate.sh relaxqsub.sh scfqsub.sh dosqsub.sh
do

echo -n "Change pressure in ${file} from " 
sed -n '/pressure=/p' ${file}
echo "to ${newpressure}GPa"
sed -i '/pressure=/d' ${file}
sed -i "/#!\/bin\/bash/a pressure=${newpressure}" ${file}
done