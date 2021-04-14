# Word Stats

> This script analyzes all the words in a file and makes a statistical analysis of it.

![](https://raw.githubusercontent.com/bbarbie/ScriptWordStats/main/wsimg.jpg?token=APGWS3DU5FQKIS5PN2RKH4LAO3VDC)

## Installation

Linux:

Only need to download the script, the StopWords folder and then make it executable by writing in the terminal
```sh
"chmod u+x wordStats.sh"
```
Ps: make sure you are in the same directory of the script

## Usage example

Command:

```sh
./wordStats.sh <MODE> <INPUT> <ISO3166>
```

```sh
./word_stats.sh Cc|Pp|Tt INPUT [iso3166]
```

Modes:
+ C : performs the count of occurrences of each word with stop-words, saving the list in a text file 
+ c : performs the count of occurrences of each word without stop-words, saving the list in a text file
+ P : performs the count of occurrences of each word, producing a bar chart with the N words that occur most frequently (stop-words included)
+ p : performs the count of occurrences of each word, producing a bar chart with the N words that occur most frequently (without stop-words)
+ T : performs the count of occurrences of each word showing the Top words with stop-words
+ t : performs the count of occurrences of each word showing the Top words withot stop-words

The last 4 modes need an environment variable called WORD_STATS_TOP so you can define it in your machine with the value you want (digit) or if you dont the script will assume 10 by default.

Input:
+ the file you want to be analyzed

ISO:
+ pt : portuguese stop-words
+ en : english stop-words

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

[![Bash Shell](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
