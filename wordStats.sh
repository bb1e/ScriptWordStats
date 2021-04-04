#?/usr/bin/env bash

set -u

echo $#

file=$2


if [[ $1 == NULL && $2 == NULL && $3 == NULL ]]; then # ver isto

	echo [ERROR] insufficient parameters
    echo "./word_stats.sh Cc|Pp|Tt INPUT [iso3166]"
    exit
    
fi

 
 # verificar de o ficheiro existe


if [[ $file != *.pdf && $file != *.txt ]]; then

	echo "ERROR: Invalid file format. Make sure the file is .pdf or .txt"
	exit

elif [[ $file == *.pdf ]]; then

	pdftotext -layout $file new_file.txt
	#echo "converting $file to new_file"
	file=new_file.txt
	fileType="PDF file"
	
else
	fileType="TEXT file"

fi

resultFile="result--"$2.txt



function counting() {
	
	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	sort -nr | \
	sed -e 's/ \+/\t/g' | \
	nl > fileTester.txt > $resultFile
	
}


function isoMenu() {

	if [[ $3 == pt ]]; then
	stopwords=StopWords/pt.stop_words.txt
	echo "StopWords file 'pt': 'StopWords/pt.stop_words.txt' (205 words)"
	
elif [[ $3 == en ]]; then
	stopwords=StopWords/en.stop_words.txt
	echo "StopWords file 'en': 'StopWords/en.stop_words.txt' (ir ver)"
	
else
	echo "ERROR: Invalid language! Only avaliable in portuguese (pt) or english (en)"
	exit
	
fi

}



#function withoutSw() {

	#entra o ficheiro result compara as palavras com o ficheiro stop_wordse cria nova listagem e guarda       em result

#}



if [[ $1 != c && $1 != C && $1 != p && $1 != P && $1 != t && $1 != T ]]; then
  echo "[ERROR] unknown command '$1'"
  exit
  
elif [[ $1 == c ]]; then
  #echo "count without stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be filtered out
  #chamar função das stop words
  echo COUNT MODE

  withoutSw

  echo $( ls -l -a $resultFile )  
  echo $( wc -l < $resultFile ) distinct words
  
elif [[ $1 == C ]]; then
  #echo "count with stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be counted
  echo COUNT MODE
  counting 
  head -n 10 $resultFile
  echo RESULTS: "'$resultFile'"
  
  echo $( ls -l -a $resultFile )
  echo $( wc -l < $resultFile ) distinct words
  
elif [[ $1 == p ]]; then
  #echo "plot without stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be filtered out
  # ls .dat
  # ls .png
  # ls .html
  echo "Description: Execution in plot / remove stop words mode (lingua) to analyse the file "$2""
  echo Files produced: #png e html
  
  # abrir/apresentar gráfico
  
  #echo $( ls -l -a $resultFile )
  #echo $( wc -l < $resultFile ) distinct words
  
elif [[ $1 == P ]]; then
  #echo "plot with stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be counted
  # ls .dat
  # ls .png
  # ls .html
  
  # abrir/apresentar gráfico
  
  #echo $( ls -l -a $resultFile )
  #echo $( wc -l < $resultFile ) distinct words
  
elif [[ $1 == t ]]; then
  #echo "top without stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be filtered out
  # environment variable
  
  echo "*************************************"
  echo "# TOP 10 elements"
  head -n 10 $resultFile
  echo "*************************************"
  
  
  echo $( ls -l -a $resultFile )
  #echo $( wc -l < $resultFile ) distinct words
  
  # fazer top (10)
  
elif [[ $1 == T ]]; then
  #echo "top with stop-words"
  echo "'$2'" : $fileType
  echo [INFO] Processing "'$file'"
  echo STOP WORDS will be filtered out
  # environment variable
  
  echo "*************************************"
  echo "# TOP 10 elements"
  counting 
  head -n 10 $resultFile
  echo "*************************************"
  
  echo $( ls -l -a $resultFile )
  #echo $( wc -l < $resultFile ) distinct words
  
  # fazer top (10)

fi






