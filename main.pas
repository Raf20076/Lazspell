{Unit Main License is https://creativecommons.org/publicdomain/zero/1.0/deed.en}  
unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus,LazFileUtils, LCLProc, LazUtils, LazUtf8, Variants;

  type

  { TMainForm }

  TMainForm = class(TForm)
    CheckButton: TButton;
    ComboBoxDictionary: TComboBox;
    LabelErrors: TLabel;
    LabelSuggestions: TLabel;
    ListBoxErrors: TListBox;
    ListBoxSuggestions: TListBox;
    MainMenu: TMainMenu;
    Memo: TMemo;
    mExit: TMenuItem;
    mOpen: TMenuItem;
    mNew: TMenuItem;
    mAbout: TMenuItem;
    mHelp: TMenuItem;
    mTools: TMenuItem;
    mFile: TMenuItem;
    StatusBar: TStatusBar;
    procedure CheckButtonClick(Sender: TObject);
    procedure ComboBoxDictionaryChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxErrorsClick(Sender: TObject);
    procedure ListBoxSuggestionsClick(Sender: TObject);
    procedure mAboutClick(Sender: TObject);
    procedure SetDefaultDicPath();
    function CheckForDict(): boolean;
    function FindDictionary(const Dict : TStrings; const DPath : AnsiString) : boolean;
  private

  public


  end;

var
  MainForm: TMainForm;

implementation

uses Hunspell,Functions;//Hunspell.pas Functions.pas


var
SpellCheck: THunspell;
DictPath : AnsiString;
{$R *.lfm}

{ TMainForm }

//OnCreate
procedure TMainForm.FormCreate(Sender: TObject);
begin

   SetDefaultDicPath();
   SpellCheck := THunspell.Create(True);
   if SpellCheck.ErrorMessage = '' then begin
        StatusBar.SimpleText := 'Library Loaded =' + SpellCheck.LibraryFullName;
        CheckButton.enabled := CheckForDict();
        CheckForDict();
    end else
        StatusBar.SimpleText := (SpellCheck.ErrorMessage);
end;

//onDestroy
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SpellCheck.free;
  SpellCheck := nil;
end;



//OnClick CheckButton
procedure TMainForm.CheckButtonClick(Sender: TObject);
var
     i : Integer;
     MAX : Integer;
     ArrayWordsList:TStringArray;
     MemoString: String;
     NoCharacters: String;

begin
    ListBoxErrors.clear;
    ListBoxErrors.Items.Clear;
    MemoString := ReplaceCarriageReturn(Memo.Lines.Text); // replace carriage return with one space
    NoCharacters := StripOffNonCharacter(MemoString);// remove all non characters
    ArrayWordsList := NoCharacters.split(' '); // split string into words with ' ' one space
    MAX := ArrayValueCount(ArrayWordsList); // give how many elements are in array
    for i := 0 to MAX - 1 do
    if not SpellCheck.Spell(ArrayWordsList[i]) then ListBoxErrors.Items.add(ArrayWordsList[i]);
    //Take word from array and check in dictionary

end;

//onChange ComboBoxDictionary
procedure TMainForm.ComboBoxDictionaryChange(Sender: TObject);
begin
    if ComboBoxDictionary.ItemIndex > -1 then
        CheckButton.enabled := SpellCheck.SetDictionary( AppendPathDelim(DictPath) + ComboBoxDictionary.Items.Strings[ComboBoxDictionary.ItemIndex]);
    if SpellCheck.ErrorMessage = '' then begin
        StatusBar.SimpleText := 'Good To Go =' + booltostr(SpellCheck.GoodToGo, True);
        StatusBar.SimpleText := 'Dictionary set to ' + AppendPathDelim(DictPath) + ComboBoxDictionary.Items.Strings[ComboBoxDictionary.ItemIndex];
    end else
        StatusBar.SimpleText := 'ERROR ' + SpellCheck.ErrorMessage;
    end;

//onClick ListBoxErrors
procedure TMainForm.ListBoxErrorsClick(Sender: TObject);
var
     Selected : AnsiString;

begin

    if ListBoxErrors.ItemIndex >= 0 then begin
    Selected := ListBoxErrors.Items.Strings[ListBoxErrors.ItemIndex];
    FindInMemo(Memo,Selected,0+1); //Show an error in MemoText
    SpellCheck.Suggest(Selected,ListBoxSuggestions.Items);

    end;

end;

//onClick ListBoxSuggestions
procedure TMainForm.ListBoxSuggestionsClick(Sender: TObject);
var
    Selected : AnsiString;
begin
    if ListBoxSuggestions.ItemIndex >= 0 then begin
    Selected := ListBoxSuggestions.Items.Strings[ListBoxSuggestions.ItemIndex];
    Memo.SelText:= Selected;
    ListBoxSuggestions.Clear;
    end;

end;
//onClick About
procedure TMainForm.mAboutClick(Sender: TObject);
begin
   ShowMessage('Lazspell (by Raf20076, Poland 2020)  - an example of speller. Lazspell uses hunspell.pas and hunspell.inc from https://github.com/davidbannon/hunspell4pas . Lazspell is under license: Unit Main License is https://creativecommons.org/publicdomain/zero/1.0/deed.en . Unit Functions License is https://creativecommons.org/publicdomain/zero/1.0/deed.en . Dictionaries coded in UTF-8 from https://github.com/wooorm/dictionaries/blob/master/license');
end;

//Begin Dictionary
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
    if not FindDictionary(ComboBoxDictionary.Items,DictPath) then
        StatusBar.SimpleText := 'ERROR - no dictionaries found in ' + DictPath;
    if ComboBoxDictionary.Items.Count = 1 then begin                   // Exactly one returned.
        if not SpellCheck.SetDictionary(AppendPathDelim(DictPath) + ComboBoxDictionary.Items.Strings[0]) then
            StatusBar.SimpleText := 'ERROR ' + SpellCheck.ErrorMessage
        else
            StatusBar.SimpleText := 'Dictionary set to ' + DictPath + ComboBoxDictionary.Items.Strings[0];
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
//End Dictionary
end.

