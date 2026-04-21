
{$ZEROBASEDSTRINGS ON}                   // auch unter Windows 0-Basis
{ $SCOPEDENUMS ON}                        // Enums brauchen TypNamen
{$DEFINE PseudoFile}

//  ------------------------------------------------------------------------------------------------

{$DEFINE HelpersHide}                     // vom Helper verdeckte Deklarationen nicht zeigen

{ $DEFINE SystemReduzieren}                // reduziert die SystemId-Verkettung für schnellere Tree-Navigation
                                          // bei unklaren Problemen man ausschalten
                                          // zZ AUS wegen uSystem.DeleteSystemInserts

{$DEFINE UnitPrefixe}                     // Ausschalten wenn die mal ausgestorben sein werden

{---------------------------------------------------------------------------------------------------------}

{$IFDEF SaveTree}
  {$DEFINE TestKompatibel}                  // Prüfung auf Typ-Kompatibilität: Zuweisungen / ParseExpression
  {$DEFINE FinalChecks}                      // alle Acs und Ids am Ende nochmal auf Konsistenz checken
  { $DEFINE FilterProt}                       // Filter-Ergebnis (für Vergleich) in Datei schreiben
{$ENDIF}

