# Lazspell
Lazspell by Raf20076, Poland, 2020

Lazspell is an example of spelling checker written in Lazarus ide.

<img src="https://raw.githubusercontent.com/Raf20076/Lazspell/master/Screenshot.PNG"/>

Lazspell is an example of a speller which checks spelling in German, English, Spanish,
French, Italian, Portugues, Polish and Russian.

All dictionaries are coded in UTF-8 in dict folder from https://github.com/wooorm/dictionaries
You must distribute dict folder with your program.

Lazspell uses hunspell.pas and hunspell.inc from https://github.com/davidbannon/hunspell4pas
To call Application in hunspell.pas add Forms to uses in implementation. 
In hunspell.pas it should look like

```pascal 
uses LazUTF8, SysUtils, {$ifdef linux}Process,{$endif} LazFileUtils, {Forms,} lazlogger, Forms;
// LazUTF8 requires lazutils be added to dependencies
// Forms needed so we can call Application.~   , add LCLBase to dependencies
// lazlogger for the debug lines. 
```
Lazspell is under license: 

Unit Main License is https://creativecommons.org/publicdomain/zero/1.0/deed.en 

Unit Functions License is https://creativecommons.org/publicdomain/zero/1.0/deed.en

libhunspell.dll was compiled with Microsoft Visual C++ 2010. from the original source from 
http://sourceforge.net/projects/hunspell/files/Hunspell/1.3.2/hunspell-1.3.2.tar.gz/download

You must distribute this file with your program. 

Lazspell

1. Choose dictionary (Check button will be enabled)
2. Type text in memo box
3. Click Check button
4. If errors found, click an error in Errors box, the error will be highlighted in memo box
5. Click a word in Suggestions box to change highlighted error for suggested word
