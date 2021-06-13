
{Unit Functions License is https://creativecommons.org/publicdomain/zero/1.0/deed.en}
unit Functions; //Extract words from text

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus,LazFileUtils, LCLProc, LazUtils, LazUtf8, Variants, strutils;


  function ArrayValueCount(const InputArray: Array of string): Integer;
  function StripOffNonCharacter(const aString: string): string;
  function ReplaceCarriageReturn(s: string) : string;
  function FindInMemo(AMemo: TMemo; AString: String; StartPos: Integer): Integer;

implementation

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
//This function must be solved using UTF8
begin
  Result := PosEx(AString, AMemo.Text, StartPos);//It copied one character (UTF8) less need to be solved
  //Result := UTF8Pos(AString, AMemo.Text, StartPos); // needs to be tested
  If Result > 0 then
  begin
    AMemo.SelStart := UTF8Length(PChar(AMemo.Text), Result -1);
    AMemo.SelLength := UTF8Length(AString);
    AMemo.SetFocus;
    end;
  end;


end.

