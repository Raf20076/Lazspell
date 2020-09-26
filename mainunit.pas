{Lazspell by Raf20076, Poland, 2020}
{Please improve this code and and share it

Lazspell is an example of simple spellcheker application for Lazarus ide.

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
5. Click a word in Suggestions box to change highlighted error for suggested word}

unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus,LazFileUtils, LCLProc, LazUtils, LazUtf8, Variants, strutils;

type

  { TMainForm }

  TMainForm = class(TForm)
    ButtonCheckSpelling: TButton;
    ChooseDictionary: TComboBox;
    LabelErrors: TLabel;
    LabelSuggestions: TLabel;
    ListBoxSuggestions: TListBox;
    ListBoxErrors: TListBox;
    MemoText: TMemo;
    StatusBar: TStatusBar;
    procedure ButtonCheckSpellingClick(Sender: TObject);
    procedure ChooseDictionaryChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxErrorsClick(Sender: TObject);
    procedure ListBoxSuggestionsClick(Sender: TObject);
    procedure SetDefaultDicPath();
    function CheckForDict(): boolean;
    function FindDictionary(const Dict : TStrings; const DPath : AnsiString) : boolean;

  private

  public

  end;

var
  MainForm: TMainForm;

implementation

uses hunspell;//place hunspell.pas in your application folder
              //or create one and fill in with Hunspell wrapper

var
SpellCheck: THunspell;
DictPath : AnsiString;


{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
   SetDefaultDicPath();
   SpellCheck := THunspell.Create();
   if SpellCheck.ErrorMessage = '' then begin
        StatusBar.SimpleText := 'Library Loaded =' + SpellCheck.LibraryFullName;
        ButtonCheckSpelling.enabled := CheckForDict();
        CheckForDict();
    end else
        StatusBar.SimpleText := (SpellCheck.ErrorMessage);
end;

procedure TMainForm.ChooseDictionaryChange(Sender: TObject);
begin
    if ChooseDictionary.ItemIndex > -1 then
        ButtonCheckSpelling.enabled := SpellCheck.SetDictionary( AppendPathDelim(DictPath) + ChooseDictionary.Items.Strings[ChooseDictionary.ItemIndex]);
    if SpellCheck.ErrorMessage = '' then begin
        StatusBar.SimpleText := 'Good To Go =' + booltostr(SpellCheck.GoodToGo, True);
        StatusBar.SimpleText := 'Dictionary set to ' + AppendPathDelim(DictPath) + ChooseDictionary.Items.Strings[ChooseDictionary.ItemIndex];
    end else
        StatusBar.SimpleText := 'ERROR ' + SpellCheck.ErrorMessage;

end;

function TMainForm.FindDictionary(const Dict : TStrings; const DPath : AnsiString) : boolean;
var
    Info : TSearchRec;
begin
    Dict.Clear;
    if FindFirst(AppendPathDelim(DPath) + '*.dic', faAnyFile and faDirectory, Info)=0 then begin
        repeat
            Dict.Add(Info.Name);
        until FindNext(Info) <> 0;
    end;
    FindClose(Info);
    Result := Dict.Count >= 1;
end;

function TMainForm.CheckForDict(): boolean;
begin

    Result := False;
    DictPath := DictPath;
    if not FindDictionary(ChooseDictionary.Items,DictPath) then
        StatusBar.SimpleText := 'ERROR - no dictionaries found in ' + DictPath;
    if ChooseDictionary.Items.Count = 1 then begin                   // Exactly one returned.
        if not SpellCheck.SetDictionary(AppendPathDelim(DictPath) + ChooseDictionary.Items.Strings[0]) then
            StatusBar.SimpleText := 'ERROR ' + SpellCheck.ErrorMessage
        else
            StatusBar.SimpleText := 'Dictionary set to ' + DictPath + ChooseDictionary.Items.Strings[0];
    end;
    Result := SpellCheck.GoodToGo;   // only true if count was exactly one or FindDict failed and nothing changed
end;

procedure TMainForm.SetDefaultDicPath();
begin
    {$ifdef LINUX}
    DictPath := '/usr/share/hunspell/';
    {$ENDIF}
    {$ifdef WINDOWS}
    DictPath := ExtractFilePath(Application.ExeName) + 'dict\'; // dictionaries in dict folder
    {$ENDIF}
    {$ifdef DARWIN}
    //DictPath := '/Applications/Firefox.app/Contents/Resources/dictionaries/';
    DictPathAlt := ExtractFilePath(Application.ExeName);
    {$endif}

end;

{Functions}

{Extract words from string: non characters, spaces, carriagereturn aware}

function ArrayValueCount(const InputArray: Array of string): Integer;
{Count elements in array}
var
    i:Integer;
    begin
        result := 0;
        for i := low(InputArray) to high(InputArray) do
        if InputArray[i] <> ' ' then  // 'between them one space'
            inc(result);
    end;

function StripOffNonCharacter(const aString: string): string;
{Remove non characters from string}

var
  a: Char;
begin
  Result := '';
  for a in aString do begin //below punctuation marks, numbers to remove from string
      if not CharInSet(a, ['.', ',', ';', ':', '!', '/',
      '?', '@', '#', '$', '%', '&', '*', '(', ')', '{',
      '}', '[', ']', '-', '\', '|', '<', '>', '''', '"', '^',
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '_', '+',
      '=', '~'])  then //'„', '”'])these marks make error: Ordinal expression expected, need to be fixed
      begin
        Result := Result + a;
      end;
    end;

end;

function ReplaceCarriageReturn(s: string) : string;
{Replace carriagereturn with one space}
var
  i: Integer;

begin
  Result:=s;
  for i := 1 to Length(Result) do
  if Result[i] in [#3..#13] then
  Result[i] := ' ';//'Between them one space'
  end;

function FindInMemo(AMemo: TMemo; AString: String; StartPos: Integer): Integer;
{Find clicked error (word) from ListBoxErrors and highligh it}
begin
  Result := PosEx(AString, AMemo.Text, StartPos);
  If Result > 0 then
  begin
    AMemo.SelStart := UTF8Length(PChar(AMemo.Text), Result -1);
    AMemo.SelLength := UTF8Length(AString);
    AMemo.SetFocus;
    end;
  end;


procedure TMainForm.ButtonCheckSpellingClick(Sender: TObject);
var
     i : Integer;
     MAX : Integer;
     FillInStringWithTextFromMemo: String;
     FillInStringWithNonCharacters: String;
     FillInArrayWithWords:TStringArray;
begin
    ListBoxErrors.clear;
    ListBoxErrors.Items.Clear;

    FillInStringWithTextFromMemo := ReplaceCarriageReturn(MemoText.Lines.Text);
    {Take text from MemoText; replace carriage return with one space,
    using ReplaceCarriageReturn function and put into FillInStringWithTextFromMemo}

    FillInStringWithNonCharacters := StripOffNonCharacter(FillInStringWithTextFromMemo);
    {Remove all non characters from FillInStringWithTextFromMemo,
    using StripOffNonCharacter function and put string without non charachters
    into FillInStringWithNonCharacters}

    FillInArrayWithWords := FillInStringWithNonCharacters.split(' ');
    {Split string into words with ' ' one space,
    using .split and put separate words into array FillInArrayWithWords}

    MAX := ArrayValueCount(FillInArrayWithWords);
    {Give how many elements are in array,using function ArrayValueCount}

    for i := 0 to MAX - 1 do  //-1

    if not SpellCheck.Spell(FillInArrayWithWords[i]) then ListBoxErrors.Items.add(FillInArrayWithWords[i]);
    {Take word from array and check in dictionary through hunspell (using SpellCheck.Spell function)
    if word is not in dictionary, show it in ListboxErrors as an error }

end;

procedure TMainForm.ListBoxErrorsClick(Sender: TObject);
{Get suggestions}
var
     Selected : String;
     SearchStart: Integer;

begin
    SearchStart := 0;

    if ListBoxErrors.ItemIndex >= 0 then begin
    Selected := ListBoxErrors.Items.Strings[ListBoxErrors.ItemIndex];
    FindInMemo(MemoText,Selected,SearchStart +1); //Show an error in MemoText
    SpellCheck.Suggest(Selected,ListBoxSuggestions.Items);

    end;

end;

procedure TMainForm.ListBoxSuggestionsClick(Sender: TObject);
{Change for suggestion}
var
    Selected : String;
begin
    if ListBoxSuggestions.ItemIndex >= 0 then begin
    Selected := ListBoxSuggestions.Items.Strings[ListBoxSuggestions.ItemIndex];
    MemoText.SelText:= Selected;
    ListBoxSuggestions.Clear;
    end;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SpellCheck.free;
  SpellCheck := nil;
end;


end.
