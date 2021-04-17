#?/usr/bin/env bash

set -u



# ---- COLORS ----

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
LIGHTGREEN='\033[1;32m'
RED='\033[0;31m'
ORANGE='\033[1;31m'
NC='\033[0m'  # goes back to normal color (no color)
BLINK='\e[5m'





# arguments and language check

if [[ $# < 2 ]]; then 
	
	echo " "
	echo -e "${RED}${BLINK} [ERROR]${RED} insufficient parameters"
    echo -e "${NC} ./word_stats.sh Cc|Pp|Tt INPUT [iso3166]"
    echo " "
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




# mode check

if [[ $1 != c && $1 != C && $1 != p && $1 != P && $1 != t && $1 != T ]]; then
	
    echo " "
 	echo -e "${RED}${BLINK} [ERROR]${RED} unknown command '$1'${NC}"
 	echo " "
 	exit
  
fi




 
 # file check
 
if [[ -e "$2" ]]; then

	file=$2

else
	
	echo " "
	echo -e "${RED}${BLINK} [ERROR]${RED} can't find file '$2'${NC}"
	echo " "
	exit
	
fi



 
# file type check and convertion

if [[ $file != *.pdf && $file != *.txt ]]; then

	echo " "
	echo -e "${RED}${BLINK} [ERROR]${RED} Invalid file format. Make sure the file is .pdf or .txt ${NC}"
	echo " "
	exit

elif [[ $file == *.pdf ]]; then

	pdftotext -layout $file $2.txt
	file=$2.txt
	fileType="PDF file"
	
else
	fileType="TEXT file"

fi


# check WORD_STATS_TOP 

if [ -z ${WORD_STATS_TOP+x} ]; then 
	
	message="Environment variable 'WORD_STATS_TOP' is empty (using default 10)"
	WORD_STATS_TOP=10
	
elif [[ $WORD_STATS_TOP != *[[:digit:]]* ]]; then 

	message="'$WORD_STATS_TOP' is not a number (using default 10)"
	WORD_STATS_TOP=10
	
else

	message="WORD_STATS_TOP = $WORD_STATS_TOP"

fi




# result files

resultFile="result---"$2.txt
resultFilePng="result---"$2.png
resultFileHtml="result---"$2.html
dat="result---"$2.dat




# --------------------- FUNCTIONS ---------------------------


# break count order list and save file with stop-words

function counting() {
	
	cat $file |
	egrep -oe "\b\w+\b" |
	sort |
	uniq -ci |
	sort -nr |
	sed 's/ \+/\t/g' |
	nl
	
}



# break count order list and save file without stop-words

function withoutSw() {

	cat $file |
	egrep -oe "\b\w+\b" |
	sort |
	uniq -ci |
	grep -viwf $stopwords |
	sort -nr |
	sed 's/ \+/\t/g' |
	nl
	
}




# create word chart

function chart() {

	head -n $WORD_STATS_TOP $resultFile > $dat
	
	echo " " > bar.gnuplot #makes sure the file is empty before sending the information
	
	{
	
	echo "set terminal png
	set output \"$resultFilePng\"
	set title \"Top word occurrence chart\" font \"courrier, 20px\" textcolor \"#800080\" 
	set xlabel \"words\"
	set ylabel \"number of occurrences\"
	set xtics rotate
	set boxwidth 0.5
	set grid
	set tics nomirror out scale 0.75
	set style fill solid
	plot \"$dat\" using 1:2:xtic(3) title \"# of occurrences\" with boxes, \
	      \"$dat\" using 1:(2):2 notitle with labels"
		
	}>> bar.gnuplot
	
	gnuplot < bar.gnuplot
	
}



# create html file

function htmlfile() {

	echo " " > $resultFileHtml #makes sure the file is empty before sending the information
	data=$(date)
	

	{
	echo "<!DOCTYPE html>
	      <html>
		  <head>
		  <title>Word Stats Chart</title>
		  </head>
		  <body style=\"background-color: #FFC0CB;margin: 100px\"> 
		  <h1 style=\"color: #FF1493;text-align: center;font-size: 40px;line-height: 150px;font-family: Courier\">Top 5 words-'$1'</h1>
		  <p style=\"text-align: center;font-family: Courier\"> Top words for '$1'</p>
		  <p style=\"text-align: center;font-family: Courier\"> Created: $data</p>
		  <p style=\"text-align: center;font-family: Courier\"> ($message)</p>
		  <p style=\"text-align: center\"><img src=\"$resultFilePng\"></p>
		  <p style=\"text-align: center;font-family: Courier\"> Authors: Barbie Chan</p>
		  <p style=\"text-align: center;font-family: Courier\"> Created: $data</p>
		  </body>
		  </html>"
	}>> $resultFileHtml

}


	
	


# main menu ----------------------------------------


if [[ $1 == c ]]; then

	echo " "
	echo " "
  	echo -e "${CYAN} '$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e "${NC} STOP WORDS will be filtered out"
  	echo " StopWords file '$sw': '$stopwords' ( $( wc -l < $stopwords ) words )"
  	echo " "
  	echo -e "${PINK}${BLINK} COUNT MODE${PURPLE}"
  	echo -e "${PINK} ----------------------------------------------------- ${PURPLE}"
  	echo " "
  	withoutSw > $resultFile
  	head -n 8 $resultFile
  	echo " "
  	echo -e "${PURPLE}    (...)"
  	echo " "
  	echo -e "${PINK} ----------------------------------------------------- "
  	echo " "
  	echo -e ${NC} RESULTS: "'$resultFile'"

  	ls -la $resultFile
  	echo $( wc -l < $resultFile ) distinct words
  	echo " "
  	echo " "
  	
  	
  
elif [[ $1 == C ]]; then
	
	echo " "
	echo " "
  	echo -e "${CYAN} '$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$file'"
  	echo -e "${NC} STOP WORDS will be counted"
  	echo " "
  	echo -e "${PINK}${BLINK} COUNT MODE${PURPLE}"
  	echo -e "${PINK} ----------------------------------------------------- ${PURPLE}"
  	echo " "
  	counting > $resultFile
  	head -n 8 $resultFile
  	echo " "
  	echo -e "${PURPLE}    (...)"
  	echo " "
  	echo -e "${PINK} ----------------------------------------------------- "
  	echo " "
  	echo -e ${NC} RESULTS: "'$resultFile'"
  
  	ls -la $resultFile
  	echo $( wc -l < $resultFile ) distinct words
  	echo " "
  	echo " "
  	
  	
  
elif [[ $1 == p ]]; then
	
	message="'$sw' stop-words removed"
	echo " "
	echo " "
  	echo -e "${CYAN}'$2'" : $fileType
  	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$2'"
  	echo " STOP WORDS will be filtered out"
  	echo " StopWords file '$sw': '$stopwords' ( $( wc -l < $stopwords ) words )"
  	withoutSw > $resultFile
    chart
  	htmlfile "$2"
  	echo " "
  	ls -la $dat
  	ls -la $resultFilePng
  	ls -la $resultFileHtml
  	echo " "
  	echo -e "${ORANGE}Description: Plot Mode / remove stop-words mode ($language) ........ analyzing file "$2""
  	echo -e Files produced: $resultFilePng and $resultFileHtml ${NC}
  	echo " "
  	echo " "
  

  	firefox $resultFileHtml 2> /dev/null
	#redirects critical messages to void
  
  
elif [[ $1 == P ]]; then
	
	message="with stop-words"
	echo " "
	echo " "
 	echo -e "${CYAN} '$2'" : $fileType
 	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$2'"
  	echo " STOP-WORDS will be counted"
  	counting > $resultFile
  	chart
  	htmlfile "$2"
  	echo " "
  	ls -la $dat
  	ls -la $resultFilePng
  	ls -la $resultFileHtml
  	echo " "
  	echo -e "${ORANGE}Description: Plot Mode / stop-words included ........ analyzing file "$2""
  	echo -e Files produced: $resultFilePng and $resultFileHtml ${NC}
  	echo " "
  	echo " "
  
  	firefox $resultFileHtml 2> /dev/null
  	#redirects critical messages to void

  
  
elif [[ $1 == t ]]; then
	
	echo " "
	echo " "
	echo -e "${CYAN} '$2'" : $fileType
	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$2'"
 	echo " STOP WORDS will be filtered out"
 	echo " StopWords file '$sw': '$stopwords' ( $( wc -l < $stopwords ) words )"
 	echo " $message"
  	withoutSw | \
  	head -n $WORD_STATS_TOP > $resultFile
  	echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo "             # TOP $WORD_STATS_TOP elements"
	echo " "
	echo " "
	cat $resultFile 
	echo " "
	echo -e "${PINK}**********************************************${NC}"
	echo " "
	ls -l -a $resultFile
	echo " "
	echo " "
	
  
  
elif [[ $1 == T ]]; then
	
	echo " "
	echo " "
	echo -e "${CYAN} '$2'" : $fileType
	echo -e "${LIGHTGREEN}[INFO]${NC} Processing '$2'"
	echo " STOP WORDS will be counted"
	echo " $message"
    counting | \
    head -n $WORD_STATS_TOP > $resultFile
    echo " "
	echo -e "${PINK}**********************************************"
	echo " "
	echo "             # TOP $WORD_STATS_TOP elements"
	echo " "
	echo " "
	cat $resultFile
	echo " "
	echo -e "${PINK}**********************************************${NC}"
	echo " "
	ls -l -a $resultFile
	echo " "
	echo " "
  

fi






