
unit uFunctions;

interface

uses
  uGlobalsParser;

type
  TFncIdentifier = record
    class function Rename( pId: pIdInfo; const new: string ): string; static;
    end;


implementation

uses
  System.SysUtils,
  System.IOUtils;

class function TFncIdentifier.Rename( pId: pIdInfo; const new: string ): string;
var pAc: pAcInfo;
    pos: tFilePos;
    old,
    s  : string;
    SpaltenKorrektur: integer;
begin
  pAc := pId^.AcList;
  old := pId^.Name.ToLower;
  SpaltenKorrektur := 0;

  while pAc <> nil do {with DateiListe[pAc^.Position.Datei]^ do } begin
    if pAc^.Position.Datei <> cFirstFileV then begin
      s := DateiListe[pAc^.Position.Datei]^.StrList[pAc^.Position.Zeile];       // zu bearbeitende Zeile
      if ( pAc^.Position.Datei <> pos.Datei ) or ( pAc^.Position.Zeile <> pos.Zeile ) then
        SpaltenKorrektur := 0;
      pos := pAc^.Position;                                                     // merken um mit nächsten pAc vergleichen zu können

      { Stimmt Id-Name mit Name in Access überein: }
      if ( length( old ) <> pos.Laenge ) or
         ( old           <> s.Substring( pos.Spalte + SpaltenKorrektur, pos.Laenge ).ToLower ) then
        { z.B. inherited, initialisierte Vars }
      else begin
        s := s.Remove( pos.Spalte + SpaltenKorrektur, pos.Laenge );             // alt raus
        s := s.Insert( pos.Spalte + SpaltenKorrektur, new );                    // neu rein
        DateiListe[pos.Datei]^.StrList[pos.Zeile] := s;     // und in die StrList
        inc( SpaltenKorrektur, Length( new ) - Length( old ));                  // falls mehrere Vorkommen in dieser Zeile diesen Offset beachten!
        include( DateiListe[pos.Datei]^.fiFlags, tFileFlags.isNotLatest )
        end
      end;
    pAc := pAc^.NextAc
    end;

  pId^.Name := new;

  { 5. save! }
  for var i := cFirstFile to high( DateiListe ) do with DateiListe[i]^ do if tFileFlags.isNotLatest in fiFlags then begin
    Result := Result + sLineBreak + FileName;    // Liste der geänderten Dateien
    TFile.WriteAllLines( Filename, StrList, TEncoding.ANSI );  // Encoding der Original-Source wäre hier besser, wo kriege ich das her?
    end;
end;

end.
