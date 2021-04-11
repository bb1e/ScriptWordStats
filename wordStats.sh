#?/usr/bin/env bash

set -u



# ---- COLORS ----

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
RED='\033[0;31m'
ORANGE='\033[1;31m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m'  # goes back to normal color (no color)
BLINK='\e[5m'





# arguments and language check

if [[ $# < 2 ]]; then 

	echo -e "${RED}${BLINK} [ERROR]${RED} insufficient parameters"
    echo -e "${NC} ./word_stats.sh Cc|Pp|Tt INPUT [iso3166]"
    exit
    
elif [[ $# == 2 ]]; then

	stopwords=StopWords/en.stop_words.txt
	sw=en
	language=english
	
else

	if [[ $3 == pt || $3 == Pt || $3 == PT || $3 == pT ]]; then
	
		stopwords=StopWords/pt.stop_words.txt
		sw=pt
		language=portuguese
	
	elif [[ $3 == en || $3 == En || $3 == EN || $3 == eN ]]; then
	
		stopwords=StopWords/en.stop_words.txt
		sw=en
		language=english
		
	fi
    
fi


 
 # file check
 
if [[ -e "$2" ]]; then

	file=$2

else

	echo -e "${RED}${BLINK} [ERROR]${RED} can't find file '$2'"
	exit
	
fi



# mode check

if [[ $1 != c && $1 != C && $1 != p && $1 != P && $1 != t && $1 != T ]]; then

  echo -e "${RED}${BLINK} [ERROR]${RED} unknown command '$1'"
  exit
  
fi

 
# file type check and convertion

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


# check WORD_STATS_TOP 

if [ -z ${WORD_STATS_TOP+x} ]; then 
	
	message="Environment variable 'WORD_STATS_TOP' is empty (using default 10)"
	export WORD_STATS_TOP=10
	
elif [[ $WORD_STATS_TOP != *[[:digit:]]* ]]; then 

	message="'$WORD_STATS_TOP' not a number (using default 10)"
	export WORD_STATS_TOP=10
	
else

	message="WORD_STATS_TOP = $WORD_STATS_TOP"

fi




# result files

resultFile="result--"$2.txt
resultFilePng="result--"$2.png
resultFileHtml="result--"$2.html
dat="result--"$2.dat




# --------------------- FUNCTIONS ---------------------------


# break count order list and save file with stop-words

function counting() {
	
	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	sort -nr | \
	sed -e 's/ \+/\t/g' | \
	nl > $resultFile
	
}



# break count order list and save file without stop-words

function withoutSw() {

	cat $file | \
	egrep -o -e "\b\w+\b" | \
	sort | \
	uniq -ci | \
	cat > aux-new_file.txt
	grep -viwf $stopwords aux-new_file.txt | \
	sort -nr | \
	sed -e 's/ \+/\t/g' | \
	nl > $resultFile
	
}




# create word chart

function chart() {

	head -n $WORD_STATS_TOP $resultFile > $dat
	
	echo " " > bar.gnuplot
	
	{
	
	echo "set terminal png"
	echo "set output \"$resultFilePng\""
	echo "set xlabel \"words\""
	echo "set ylabel \"number of occurrences\""
	echo "set xtics rotate"
	echo "set boxwidth 0.5"
	echo "set style fill solid"
	echo "plot \"$dat\" using 1:2:xtic(3) with boxes title \"# of occurrences\""
		
	}>> bar.gnuplot
	
	gnuplot < bar.gnuplot
	
}



# create html file

function htmlfile() {

	echo " " > $resultFileHtml
	data=$(date)

	{
	echo "<!DOCTYPE html>"
	echo "<html>"
	echo "<head>"
	echo "<title>Word Stats Chart</title>"
	echo "</head>"
	echo "<body style=\"background-color: #FFC0CB;margin: 100px\">" 
	echo "<h1 style=\"color: #FF1493;text-align: center;font-size: 40px;line-height: 150px;font-family: Courier\">Top 5 words-'ficha01.pdf'</h1>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Top words for 'ficha01.pdf'</p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Created: $data</p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> (with stop words)</p>"
	echo "<p style=\"text-align: center\"><img src=\"$resultFilePng\"></p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Authors: Bruna Leal, Pedro Sousa</p>"
	echo "<p style=\"text-align: center;font-family: Courier\"> Created: $data</p>"
	echo "</body>"
	echo "</html>"
	}>> $resultFileHtml

}


	
	


# main menu ----------------------------------------


if [[ $1 == c ]]; then

	echo " "
	echo " "
  	echo -e "${NC} '$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e "${NC} STOP WORDS will be filtered out"
  	echo " "
  	echo -e "${PINK}${BLINK} COUNT MODE${PURPLE}"
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
  	echo " "
  	echo " "
  	
  	
  
elif [[ $1 == C ]]; then
	
	echo " "
	echo " "
  	echo -e "${NC} '$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e "${NC}STOP WORDS will be counted"
  	echo " "
  	echo -e "${PINK}${BLINK} COUNT MODE${PURPLE}"
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
  	echo " "
  	echo " "
  	
  	
  
elif [[ $1 == p ]]; then
	
	echo " "
	echo " "
  	echo -e "'$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e STOP-WORDS will be filtered out
  	echo "StopWords file '$sw': '$stopwords' ( $( wc -l < $stopwords ) words )"
  	echo " "
  	echo $( ls -l -a $dat )
  	echo $( ls -l -a $resultFilePng )
  	echo $( ls -l -a $resultFileHtml )
  	echo " "
  	echo -e "${ORANGE}Description: Plot Mode / remove stop-words mode ($language) ........ analyzing file "$2""
  	echo -e Files produced: $resultFilePng and $resultFileHtml ${NC}
  	echo " "
  	echo " "
  
    withoutSw
    chart
  	htmlfile
  	firefox $resultFileHtml 2> /dev/null

  
  
elif [[ $1 == P ]]; then
	
	echo " "
	echo " "
 	echo -e "'$2'" : $fileType
 	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e STOP-WORDS will be counted
  	counting
  	chart
  	htmlfile
  	echo " "
  	echo $( ls -l -a $dat ) #ver porque é q não assume
  	echo $( ls -l -a $resultFilePng )
  	echo $( ls -l -a $resultFileHtml )
  	echo " "
  	echo -e "${ORANGE}Description: Plot Mode / stop-words included ........ analyzing file "$2""
  	echo -e Files produced: $resultFilePng and $resultFileHtml ${NC}
  	echo " "
  	echo " "
  
  	firefox $resultFileHtml 2> /dev/null

  
  
elif [[ $1 == t ]]; then
	
	echo " "
	echo " "
	echo  "'$2'" : $fileType
	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
 	echo  STOP WORDS will be filtered out
 	echo "StopWords file '$sw': '$stopwords' ( $( wc -l < $stopwords ) words )"
 	echo $message
  	withoutSw
  	echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo "             # TOP $WORD_STATS_TOP elements"
	echo " "
	echo " "
	head -n $WORD_STATS_TOP $resultFile
	echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo -e ${NC} $( ls -l -a $resultFile )
	echo " "
	echo " "
	
  
  
elif [[ $1 == T ]]; then
	
	echo " "
	echo " "
	echo "'$2'" : $fileType
	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
	echo STOP WORDS will be counted
	echo $message
    counting
    echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo "             # TOP $WORD_STATS_TOP elements"
	echo " "
	echo " "
	head -n $WORD_STATS_TOP $resultFile
	echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo -e ${NC} $( ls -l -a $resultFile )
	echo " "
	echo " "
  

fi






