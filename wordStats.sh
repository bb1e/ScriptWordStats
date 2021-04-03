#?/usr/bin/env bash

set -u

echo $#

file=$2

if [[ $file != *.pdf && $file != *.txt ]]; then
	echo "ERROR: Invalid file format. Make sure the file is .pdf or .txt"
	exit
elif [[ $file == *.pdf ]]; then
	pdftotext -layout $file ~/project/new_file.txt
	echo "converting $file to new_file"
	file=new_file.txt
fi

resultFile="result--"$file



function counting() {
	
	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	sort -nr | \
	sed -e 's/ \+/\t/g' > $resultFile
	
}

function withoutSw() {

	#entra o ficheiro result compara as palavras com o ficheiro stop_wordse cria nova listagem e guarda       em result

}



if [[ $1 != c && $1 != C && $1 != p && $1 != P && $1 != t && $1 != T ]]; then
  echo "mode not valid"
  exit
  
elif [[ $1 == c ]]; then
  echo "count without stop-words"
  echo total words: $( wc -w $file )
  withoutSw
  
elif [[ $1 == C ]]; then
  echo "count with stop-words"
  echo total words: $( wc -w $file )
  counting 
  cat $resultFile
  
elif [[ $1 == p ]]; then
  echo "plot without stop-words"
  echo total words: $( wc -w $file )
  
elif [[ $1 == P ]]; then
  echo "plot with stop-words"
  echo total words: $( wc -w $file )
  
elif [[ $1 == t ]]; then
  echo "top without stop-words"
  echo total words: $( wc -w $file )
  
elif [[ $1 == T ]]; then
  echo "top with stop-words"
  echo total words: $( wc -w $file )
  # ex: agarra nas 10 primeiras e faz o top ten

fi




# vai ter q ser uma função
if [[ $3 != pt && $3 != en ]]; then
	echo "ERROR: Invalid language! Only avaliable in portuguese (pt) or english (en)"
	exit
elif [[ $3 == pt ]]; then
	stopwords=StopWords/pt.stop_words.txt
	echo using portuguese stop-words
elif [[ $3 == en ]]; then
	stopwords=StopWords/en.stop_words.txt
	echo using english stop-words
fi


