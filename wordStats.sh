#?/usr/bin/env bash

set -u


# ---- COLORS ----

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
RED='\033[0;31m'
BLINK='\e[5m'
ORANGE='\033[1;31m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m'  # goes back to normal color ( no color )

# https://misc.flogisoft.com/bash/tip_colors_and_formatting



echo $#



# verifica a ausência de parâmetros---------------------

if [[ $# < 3 ]]; then 

	echo -e "${RED}${BLINK} [ERROR]${RED} insufficient parameters"
    echo -e "${NC} ./word_stats.sh Cc|Pp|Tt INPUT [iso3166]"
    exit
    
fi


 
 # verifica se o ficheiro existe ------------------------
 
if [[ -e "$2" ]]; then

	file=$2

else

	echo -e "${RED}${BLINK} [ERROR]${RED} can't find file '$2'"
	exit
	
fi



# verifica se o comando existe----------------------------

if [[ $1 != c && $1 != C && $1 != p && $1 != P && $1 != t && $1 != T ]]; then

  echo -e "${RED}${BLINK} [ERROR]${RED} unknown command '$1'"
  exit
  
fi

 
# verifica o formato do ficheiro e converte pdf para txt --

if [[ $file != *.pdf && $file != *.txt ]]; then

	echo -e "${RED}${BLINK} [ERROR]${RED} Invalid file format. Make sure the file is .pdf or .txt"
	exit

elif [[ $file == *.pdf ]]; then

	pdftotext -layout $file new_file.txt
	file=new_file.txt
	fileType="PDF file"
	
else
	fileType="TEXT file"

fi

# result files

resultFile="result--"$2.txt
resultFilePng="result--"$2.png
resultFileHtml="result--"$2.html
dat="result--"$2.dat




# --------------------- FUNCTIONS ---------------------------


# conta ordena lista e guarda num ficheiro com stop-words

function counting() {
	
	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	sort -nr | \
	sed -e 's/ \+/\t/g' | \
	nl > $resultFile
	
}



# conta ordena lista e guarda num ficheiro sem stop-words

function withoutSw() {

	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	cat > aux-new_file.txt
	grep -viwFf $stopwords aux-new_file.txt | \
	sort -nr | \
	sed -e 's/ \+/\t/g' | \
	nl > $resultFile
	
}




# menu de verificação da lingua 


	if [[ $3 == pt ]]; then
	stopwords=StopWords/pt.stop_words.txt
	#echo -e "${NC} StopWords file 'pt': 'StopWords/pt.stop_words.txt' (205 words)"
	
elif [[ $3 == en ]]; then
	stopwords=StopWords/en.stop_words.txt
	echo -e "${NC} StopWords file 'en': 'StopWords/en.stop_words.txt' (ir ver)"
	
else
	#echo -e "${RED} [ERROR] Invalid language! Only avaliable in portuguese (pt) or english (en)"
	exit
	
fi











function chart() {

	head -n 5 result--so.pdf.txt > result---ficha01.pdf.txt.dat
	
	{
	
	echo "set terminal png"
	echo "set output \"out.png\""
	echo "set boxwidth 0.5"
	echo "set style fill solid"
	echo "plot \"result---ficha01.pdf.txt.dat\" using 1:2:xtic(3) with boxes title \"# of occurrences\""
		
	}>> bar.gnuplot
	
	gnuplot < bar.gnuplot
	
}



function htmlfile() {

	echo " " > $resultFileHtml

	{
	echo "<!DOCTYPE html>"
	echo "<html>"
	echo "<head>"
	echo "<title>Word Stats Chart</title>"
	echo "</head>"
	echo "<body style=\"background-color: #FFC0CB;margin: 100px\">" 
	echo "<h1 style=\"color: #FF1493;font-size: 40px;line-height: 150px;font-family: Courier\">Top 5 words-'ficha01.pdf'</h1>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Top words for 'ficha01.pdf'</p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Created: </p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> (with stop words)</p>"
	echo "<img src=\"out.png\">"
	echo "<p> Authors: Bruna Leal, Pedro Sousa</p>"
	echo "<p> Created: </p>"
	echo "</body>"
	echo "</html>"
	}>> $resultFileHtml

}


	
	


# menu de opções ----------------------------------------


if [[ $1 == c ]]; then

  	echo -e "${NC} '$2'" : $fileType
  	echo -e "${NC} [INFO] Processing '$file'"
  	echo -e "${NC} STOP WORDS will be filtered out"
  	echo " "
  	echo -e "${PURPLE}${BLINK} COUNT MODE${PURPLE}"
  	echo -e "${PINK} ----------------------------------------------------- ${PURPLE}"
  	echo " "
  	withoutSw
  	head -n 10 $resultFile
  	echo " "
  	echo -e "${PURPLE}    (...)"
  	echo " "
  	echo -e "${PINK} ----------------------------------------------------- "
  	echo " "
  	echo -e ${NC} RESULTS: "'$resultFile'"

  	echo -e $( ls -l -a $resultFile )  
  	echo -e $( wc -l < $resultFile ) distinct words
  	
  	
  
elif [[ $1 == C ]]; then

  	echo -e "${NC} '$2'" : $fileType
  	echo -e "${NC} [INFO] Processing '$file'"
  	echo -e "${NC}STOP WORDS will be counted"
  	echo -e "${PURPLE}${BLINK} COUNT MODE${PURPLE}"
  	echo -e "${PINK} ----------------------------------------------------- ${PURPLE}"
  	echo " "
  	counting 
  	head -n 10 $resultFile
  	echo " "
  	echo -e "${PURPLE}    (...)"
  	echo " "
  	echo -e "${PINK} ----------------------------------------------------- "
  	echo " "
  	echo -e ${NC} RESULTS: "'$resultFile'"
  
  	echo -e $( ls -l -a $resultFile )
  	echo -e $( wc -l < $resultFile ) distinct words
  	
  	
  
elif [[ $1 == p ]]; then

  	echo -e "'$2'" : $fileType
  	echo -e [INFO] Processing "'$file'"
  	echo -e STOP WORDS will be filtered out
  	# stopwords
  	#echo $( ls -l -a $dat )
  	#echo $( ls -l -a $resultFilePng )
  	#echo $( ls -l -a $resultFileHtml )
  	echo -e "Description: Execution in plot / remove stop words mode (lingua) to analyse the file "$2""
  	echo -e Files produced: $resultFilePng and $resultFileHtml
  
    withoutSw
    chart
  	htmlfile
  	firefox $resultFileHtml

  
  
elif [[ $1 == P ]]; then

 	echo -e "'$2'" : $fileType
 	echo -e [INFO] Processing "'$file'"
  	echo -e STOP WORDS will be counted
  	# stopwords
  	#echo $( ls -l -a $dat )
  	#echo $( ls -l -a $resultFilePng )
  	#echo $( ls -l -a $resultFileHtml )
  
    counting
  	chart
  	htmlfile
  	firefox $resultFileHtml

  
  
elif [[ $1 == t ]]; then

	echo -e "'$2'" : $fileType
	echo -e [INFO] Processing "'$file'"
 	echo -e STOP WORDS will be filtered out
  	withoutSw
  	echo " "
	echo -e "${PINK}*************************************"
	echo " "
	#echo "# TOP $WORD_STATS_TOP elements"
	#head -n $WORD_STATS_TOP $resultFile
	echo " "
	echo -e "${PINK}*************************************"
	echo " "
	echo -e ${NC} $( ls -l -a $resultFile )
	
  
  
elif [[ $1 == T ]]; then

	echo "'$2'" : $fileType
	echo [INFO] Processing "'$file'"
	echo STOP WORDS will be counted
    counting
    echo " "
	echo -e "${PINK}*************************************"
	echo " "
	#echo "# TOP $WORD_STATS_TOP elements"
	#head -n $WORD_STATS_TOP $resultFile
	echo " "
	echo -e "${PINK}*************************************"
	echo " "
	echo -e ${NC} $( ls -l -a $resultFile )
  

fi






