# Lazspell
Lazspell - Lazspell is an example of simple spellcheker application for Lazarus ide.

<img src="https://raw.githubusercontent.com/Raf20076/Lazspell/master/Lazspell.PNG"/>

Lazspell is based on example from 

https://wiki.lazarus.freepascal.org/spelling#Demo_3_-_Spellchecker_-_non_characters.2C_carriage_return.2C_split_string

Lazspell uses a few dictionaries coded in UTF8 like de_De, en_GB, es_ES, fr_FR, it_IT, pl_PL, pt_PT and ru_RU
wich are dict folder. Put any dictionary in dict folder and it will be listed.

Lazspell uses libhunspell.dll library which was compiled with Microsoft Visual C++ 2010. 
From http://sourceforge.net/projects/hunspell/files/Hunspell/1.3.2/hunspell-1.3.2.tar.gz/download

Lazspell

1. Choose dictionary (Check spelling button will be enabled)
2. Type text in memo box
3. Click Check spelling button
4. If errors found, click an error in Errors box, the error will be highlighted in memo box
5. Click a word in Suggestions box to change highlighted error for suggested word
