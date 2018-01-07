#!/bin/bash

rm -f in_*.txt

for i in {1..7243}
do
 curl http://so.gushiwen.org/type.aspx?p=$i > in_$i.txt
done
exit 0

grep '</textarea' in_*.txt >all.txt
grep 'alt="赞"'  in_*.txt | sed 's/.*nbsp;//' | sed 's/<\/span><\/a><\/div>//' > score.txt
cut -d">" -f2 all.txt | sed 's/http.*//' > all_2.txt
paste -d'~' all_2.txt score.txt | grep '——' > all_3.txt
awk -F'——' 'OFS="——"{$NF="";print}' all_3.txt |sed 's/——$//g' > content.txt
awk -F'——' '{ print $NF }' all_3.txt > dat.txt
awk -F'·' '{ print $1 }' dat.txt> dynasty.txt
awk -F'[·《]' '{ print $2 }' dat.txt> author.txt
awk -F'[《》~]' '{ print $2 }' dat.txt> title.txt
awk -F'[《》~]' '{ print $NF }' dat.txt> score.txt
paste -d'\t' dynasty.txt author.txt title.txt score.txt content.txt > final.txt

